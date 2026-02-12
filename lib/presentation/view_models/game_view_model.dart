import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:plane_dash/domain/entities/game_record.dart';
import 'package:plane_dash/domain/enums/difficulty.dart';
import 'package:plane_dash/domain/services/progress_service.dart';


class GameViewModel extends ChangeNotifier {
  final ProgressService _progressService = ProgressService();

  // ---------- Параметры игры ----------
  Difficulty _difficulty = Difficulty.pilot;
  Difficulty get difficulty => _difficulty;

  double get gameSpeed {
    switch (_difficulty) {
      case Difficulty.novice:
        return 3.0;
      case Difficulty.pilot:
        return 5.0;
      case Difficulty.ace:
        return 8.0;
    }
  }

  // ---------- Игровое состояние ----------
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  bool _isPaused = false;
  bool get isPaused => _isPaused;

  bool _isGameOver = false;
  bool get isGameOver => _isGameOver;

  // ---------- Игровые параметры ----------
  int _score = 0;
  int get score => _score;

  int _starsCollected = 0;
  int get starsCollected => _starsCollected;

  // ---------- Объекты на поле ----------
  static const double planeWidth = 50;
  static const double planeHeight = 50;
  double planeX = 0.0; // центр экрана (будет задано при старте)

  final List<Star> stars = [];
  final List<Obstacle> obstacles = [];

  // ---------- Игровой цикл ----------
  Ticker? _ticker;
  Duration _lastTime = Duration.zero;

  // ---------- Флаг загрузки / ошибки ----------
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;

  GameViewModel() {
    _init();
  }

  Future<void> _init() async {
    // Ничего не загружаем пока
  }

  // ---------- Управление игрой ----------
  void startGame({Difficulty? difficulty, required double screenWidth}) {
    if (difficulty != null) _difficulty = difficulty;

    _resetGameState();
    planeX = screenWidth / 2; // стартовая позиция по центру
    _isPlaying = true;
    _isGameOver = false;
    _isPaused = false;
    notifyListeners();

    _startGameLoop();
  }

  void _resetGameState() {
    _score = 0;
    _starsCollected = 0;
    stars.clear();
    obstacles.clear();
    _error = null;
  }

  void pauseGame() {
    if (_isPlaying && !_isPaused) {
      _isPaused = true;
      _stopGameLoop();
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_isPlaying && _isPaused) {
      _isPaused = false;
      _startGameLoop();
      notifyListeners();
    }
  }

  void restartGame({required double screenWidth}) {
    _resetGameState();
    planeX = screenWidth / 2;
    _isPlaying = true;
    _isGameOver = false;
    _isPaused = false;
    notifyListeners();

    _stopGameLoop();
    _startGameLoop();
  }


  void _startGameLoop() {
    _ticker?.stop();
    _ticker = Ticker(_update);
    _ticker?.start();
  }

  void _stopGameLoop() {
    _ticker?.stop();
    _ticker = null;
  }

  void _update(Duration timestamp) {
    if (!_isPlaying || _isPaused || _isGameOver) return;

    if (_lastTime == Duration.zero) {
      _lastTime = timestamp;
      return;
    }

    final delta = (timestamp - _lastTime).inMilliseconds / 16.0; // нормализация ~60 FPS
    _lastTime = timestamp;

    // Двигаем объекты
    _moveObjects(delta);
    // Спавним новые
    _spawnObjects();
    // Проверяем коллизии
    _checkCollisions();
    // Удаляем улетевшие за экран
    _removeOffscreen();

    notifyListeners();
  }

  void _moveObjects(double delta) {
    final speed = gameSpeed * delta;
    for (var star in stars) {
      star.y += speed;
    }
    for (var obstacle in obstacles) {
      obstacle.y += speed;
    }
  }

  void _spawnObjects() {
    // С вероятностью 20% за тик спавним звезду
    if (DateTime.now().millisecond % 100 < 20) {
      stars.add(Star(
        x: (DateTime.now().millisecondsSinceEpoch % 300).toDouble() + 50,
        y: -30,
      ));
    }
    // С вероятностью 10% спавним препятствие
    if (DateTime.now().millisecond % 100 < 10) {
      obstacles.add(Obstacle(
        x: (DateTime.now().millisecondsSinceEpoch % 250).toDouble() + 50,
        y: -50,
        width: 40,
        height: 40,
      ));
    }
  }

  void _checkCollisions() {
    final planeRect = Rect.fromLTWH(
      planeX - planeWidth / 2,
      600, // фиксированная позиция по Y (самолёт внизу)
      planeWidth,
      planeHeight,
    );

    // Проверка звёзд
    for (var star in stars.toList()) {
      final starRect = Rect.fromLTWH(star.x, star.y, 30, 30);
      if (planeRect.overlaps(starRect)) {
        stars.remove(star);
        _starsCollected++;
        _score += 10;
      }
    }

    for (var obstacle in obstacles.toList()) {
      final obstacleRect = Rect.fromLTWH(
        obstacle.x,
        obstacle.y,
        obstacle.width,
        obstacle.height,
      );
      if (planeRect.overlaps(obstacleRect)) {
        endGame();
        break;
      }
    }
  }

  void _removeOffscreen() {
    stars.removeWhere((star) => star.y > 800);
    obstacles.removeWhere((obstacle) => obstacle.y > 800);
  }

  // ---------- Управление самолётом (вызывается из UI) ----------
  void movePlaneLeft(double screenWidth) {
    if (!_isPlaying || _isPaused || _isGameOver) return;
    planeX = (planeX - 20).clamp(planeWidth / 2, screenWidth - planeWidth / 2);
    notifyListeners();
  }

  void movePlaneRight(double screenWidth) {
    if (!_isPlaying || _isPaused || _isGameOver) return;
    planeX = (planeX + 20).clamp(planeWidth / 2, screenWidth - planeWidth / 2);
    notifyListeners();
  }

  // ---------- Завершение игры ----------
  Future<void> endGame() async {
    if (!_isPlaying || _isGameOver) return;
    _isPlaying = false;
    _isGameOver = true;
    _stopGameLoop();
    notifyListeners();

    try {
      _isLoading = true;
      notifyListeners();

      if (_starsCollected > 0) {
        await _progressService.addStars(_starsCollected);
      }
      await _progressService.incrementFlights();
      await _progressService.updateBestScore(_score);

      final record = GameRecord(
        playerName: 'Game player',
        score: _score,
        starsCollected: _starsCollected,
        date: DateTime.now(),
        difficulty: _difficulty,
      );
      await _progressService.saveGameRecord(record);
      await _progressService.updateWeeklyScores(_score);

      _error = null;
    } catch (e) {
      _error = 'Не удалось сохранить прогресс';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------- Очистка ошибки ----------
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopGameLoop();
    super.dispose();
  }
}

// ---------- Модели объектов ----------
class Star {
  double x;
  double y;
  Star({required this.x, required this.y});
}

class Obstacle {
  double x;
  double y;
  final double width;
  final double height;
  Obstacle({required this.x, required this.y, required this.width, required this.height});
}