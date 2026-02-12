import 'dart:math';
import 'dart:ui';

import 'package:plane_dash/domain/entities/game_record.dart';
import 'package:plane_dash/domain/enums/difficulty.dart';
import 'package:plane_dash/domain/services/progress_service.dart';
import 'package:plane_dash/domain/services/services_provider.dart';
import 'package:plane_dash/presentation/view_models/game_view_model.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter/scheduler.dart';


class GameState {
  final bool isPlaying;
  final bool isPaused;
  final bool isGameOver;
  final bool isLoading;
  final String? error;

  final int score;
  final int starsCollected;
  final Difficulty difficulty;
  final double planeX; // позиция самолёта

  final List<Star> stars;
  final List<Obstacle> obstacles;

  GameState({
    required this.isPlaying,
    required this.isPaused,
    required this.isGameOver,
    required this.isLoading,
    this.error,
    required this.score,
    required this.starsCollected,
    required this.difficulty,
    required this.planeX,
    required this.stars,
    required this.obstacles,
  });

  GameState.initial()
      : isPlaying = false,
        isPaused = false,
        isGameOver = false,
        isLoading = false,
        error = null,
        score = 0,
        starsCollected = 0,
        difficulty = Difficulty.pilot,
        planeX = 0,
        stars = const [],
        obstacles = const [];

  GameState copyWith({
    bool? isPlaying,
    bool? isPaused,
    bool? isGameOver,
    bool? isLoading,
    String? error,
    int? score,
    int? starsCollected,
    Difficulty? difficulty,
    double? planeX,
    List<Star>? stars,
    List<Obstacle>? obstacles,
  }) {
    return GameState(
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      isGameOver: isGameOver ?? this.isGameOver,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      score: score ?? this.score,
      starsCollected: starsCollected ?? this.starsCollected,
      difficulty: difficulty ?? this.difficulty,
      planeX: planeX ?? this.planeX,
      stars: stars ?? this.stars,
      obstacles: obstacles ?? this.obstacles,
    );
  }
}

// ---------- Контроллер ----------
class GameController extends StateNotifier<GameState> {
  final Ref _ref;
  late final ProgressService _progressService;

  // Параметры игрового цикла
  Ticker? _ticker;
  Duration _lastTime = Duration.zero;
  double _screenWidth = 0;

  static const double planeWidth = 50;
  static const double planeHeight = 50;

  GameController(this._ref) : super(GameState.initial()) {
    _progressService = _ref.read(progressServiceProvider);
  }

  // Геттер скорости в зависимости от сложности
  double get _gameSpeed {
    switch (state.difficulty) {
      case Difficulty.novice:
        return 3.0;
      case Difficulty.pilot:
        return 5.0;
      case Difficulty.ace:
        return 8.0;
    }
  }

  // ---------- Публичные методы ----------
  void startGame({Difficulty? difficulty, required double screenWidth}) {
    _screenWidth = screenWidth;

    state = GameState.initial().copyWith(
      isPlaying: true,
      difficulty: difficulty ?? Difficulty.pilot,
      planeX: screenWidth / 2,
    );

    _startGameLoop();
  }

  void pauseGame() {
    if (state.isPlaying && !state.isPaused) {
      state = state.copyWith(isPaused: true);
      _stopGameLoop();
    }
  }

  void resumeGame() {
    if (state.isPlaying && state.isPaused) {
      state = state.copyWith(isPaused: false);
      _startGameLoop();
    }
  }

  void restartGame({required double screenWidth}) {
    _screenWidth = screenWidth;

    state = GameState.initial().copyWith(
      isPlaying: true,
      difficulty: state.difficulty,
      planeX: screenWidth / 2,
    );

    _stopGameLoop();
    _startGameLoop();
  }

  void movePlaneLeft(double screenWidth) {
    if (!state.isPlaying || state.isPaused || state.isGameOver) return;
    final newX = (state.planeX - 20).clamp(planeWidth / 2, screenWidth - planeWidth / 2);
    state = state.copyWith(planeX: newX);
  }

  void movePlaneRight(double screenWidth) {
    if (!state.isPlaying || state.isPaused || state.isGameOver) return;
    final newX = (state.planeX + 20).clamp(planeWidth / 2, screenWidth - planeWidth / 2);
    state = state.copyWith(planeX: newX);
  }

  Future<void> endGame() async {
    if (!state.isPlaying || state.isGameOver) return;

    state = state.copyWith(isPlaying: false, isGameOver: true);
    _stopGameLoop();

    try {
      state = state.copyWith(isLoading: true);
      if (state.starsCollected > 0) {
        await _progressService.addStars(state.starsCollected);
      }
      await _progressService.incrementFlights();
      await _progressService.updateBestScore(state.score);

      final record = GameRecord(
        playerName: 'Лётчик123',
        score: state.score,
        starsCollected: state.starsCollected,
        date: DateTime.now(),
        difficulty: state.difficulty,
      );
      await _progressService.saveGameRecord(record);
      await _progressService.updateWeeklyScores(state.score);

      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Не удалось сохранить прогресс');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // ---------- Игровой цикл ----------
  void _startGameLoop() {
    _ticker?.stop();
    _ticker = Ticker(_update);
    _ticker?.start();
  }

  void _stopGameLoop() {
    _ticker?.stop();
    _ticker = null;
    _lastTime = Duration.zero;
  }

  void _update(Duration timestamp) {
    if (!state.isPlaying || state.isPaused || state.isGameOver) return;

    if (_lastTime == Duration.zero) {
      _lastTime = timestamp;
      return;
    }

    final delta = (timestamp - _lastTime).inMilliseconds / 16.0;
    _lastTime = timestamp;

    _moveObjects(delta);
    _spawnObjects();
    _checkCollisions();
    _removeOffscreen();

    // Обновляем состояние
    state = state.copyWith();
  }

  void _moveObjects(double delta) {
    final speed = _gameSpeed * delta;
    final updatedStars = state.stars.map((s) => Star(x: s.x, y: s.y + speed)).toList();
    final updatedObstacles = state.obstacles.map((o) => Obstacle(x: o.x, y: o.y + speed, width: o.width, height: o.height)).toList();
    state = state.copyWith(stars: updatedStars, obstacles: updatedObstacles);
  }

  void _spawnObjects() {
    final random = Random();

    final List<Star> newStars = List.from(state.stars);
    final List<Obstacle> newObstacles = List.from(state.obstacles);

    // 2% шанс появления звезды в каждом кадре (~1.2 в секунду при 60 FPS)
    if (random.nextInt(100) < 2) {
      newStars.add(Star(
        x: random.nextInt(300).toDouble() + 50,
        y: -30,
      ));
    }
    // 0.8% шанс появления препятствия (~0.5 в секунду)
    if (random.nextInt(100) < 1) {  // 1%
      newObstacles.add(Obstacle(
        x: random.nextInt(250).toDouble() + 50,
        y: -50,
        width: 40,
        height: 40,
      ));
    }

    state = state.copyWith(stars: newStars, obstacles: newObstacles);
  }

  void _checkCollisions() {
    final planeRect = Rect.fromLTWH(
      state.planeX - planeWidth / 2,
      600,
      planeWidth,
      planeHeight,
    );

    // Звёзды
    final remainingStars = <Star>[];
    int starsCollectedDelta = 0;
    int scoreDelta = 0;

    for (var star in state.stars) {
      final starRect = Rect.fromLTWH(star.x, star.y, 30, 30);
      if (planeRect.overlaps(starRect)) {
        starsCollectedDelta++;
        scoreDelta += 10;
      } else {
        remainingStars.add(star);
      }
    }

    if (starsCollectedDelta > 0) {
      state = state.copyWith(
        stars: remainingStars,
        starsCollected: state.starsCollected + starsCollectedDelta,
        score: state.score + scoreDelta,
      );
    }

    // Препятствия
    for (var obstacle in state.obstacles) {
      final obstacleRect = Rect.fromLTWH(obstacle.x, obstacle.y, obstacle.width, obstacle.height);
      if (planeRect.overlaps(obstacleRect)) {
        endGame();
        break;
      }
    }
  }

  void _removeOffscreen() {
    final remainingStars = state.stars.where((s) => s.y <= 800).toList();
    final remainingObstacles = state.obstacles.where((o) => o.y <= 800).toList();
    state = state.copyWith(stars: remainingStars, obstacles: remainingObstacles);
  }

  @override
  void dispose() {
    _stopGameLoop();
    super.dispose();
  }
}

// ---------- Провайдер ----------
final gameProvider = StateNotifierProvider<GameController, GameState>((ref) {
  return GameController(ref);
});