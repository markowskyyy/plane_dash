import 'package:riverpod/riverpod.dart';
import 'package:plane_dash/domain/services/progress_service.dart';
import 'package:plane_dash/domain/services/services_provider.dart';

// Модель достижения
class Achievement {
  final String id;
  final String title;
  final String description;
  final int target;
  final int current;
  final String iconAsset;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    required this.current,
    required this.iconAsset,
  });

  double get progress => current / target;
  bool get isCompleted => current >= target;
}

// Состояние достижений
class AchievementsState {
  final List<Achievement> achievements;
  final int totalStars;
  final int totalFlights;
  final int bestScore;
  final bool isLoading;
  final String? error;

  AchievementsState({
    required this.achievements,
    required this.totalStars,
    required this.totalFlights,
    required this.bestScore,
    required this.isLoading,
    this.error,
  });

  AchievementsState.initial()
      : achievements = const [],
        totalStars = 0,
        totalFlights = 0,
        bestScore = 0,
        isLoading = true,
        error = null;

  AchievementsState copyWith({
    List<Achievement>? achievements,
    int? totalStars,
    int? totalFlights,
    int? bestScore,
    bool? isLoading,
    String? error,
  }) {
    return AchievementsState(
      achievements: achievements ?? this.achievements,
      totalStars: totalStars ?? this.totalStars,
      totalFlights: totalFlights ?? this.totalFlights,
      bestScore: bestScore ?? this.bestScore,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AchievementsController extends StateNotifier<AchievementsState> {
  final Ref _ref;
  late final ProgressService _progressService;

  AchievementsController(this._ref) : super(AchievementsState.initial()) {
    _progressService = _ref.read(progressServiceProvider);
    loadAchievements();
  }

  Future<void> loadAchievements() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Загружаем статистику
      final totalStars = await _progressService.getTotalStars();
      final totalFlights = await _progressService.getTotalFlights();
      final bestScore = await _progressService.getBestScore();

      // Формируем список достижений
      final achievements = [
        Achievement(
          id: 'stars_100',
          title: 'Звёздный коллекционер',
          description: 'Собрать 100 звёзд',
          target: 100,
          current: totalStars,
          iconAsset: '⭐',
        ),
        Achievement(
          id: 'stars_500',
          title: 'Галактический магнат',
          description: 'Собрать 500 звёзд',
          target: 500,
          current: totalStars,
          iconAsset: '🌟',
        ),
        Achievement(
          id: 'flights_10',
          title: 'Начинающий пилот',
          description: 'Совершить 10 полётов',
          target: 10,
          current: totalFlights,
          iconAsset: '🛫',
        ),
        Achievement(
          id: 'flights_50',
          title: 'Опытный ас',
          description: 'Совершить 50 полётов',
          target: 50,
          current: totalFlights,
          iconAsset: '🛩️',
        ),
        Achievement(
          id: 'score_1000',
          title: 'Первая тысяча',
          description: 'Набрать 1000 очков за один полёт',
          target: 1000,
          current: bestScore,
          iconAsset: '🎯',
        ),
        Achievement(
          id: 'score_5000',
          title: 'Легенда неба',
          description: 'Набрать 5000 очков за один полёт',
          target: 5000,
          current: bestScore,
          iconAsset: '🏆',
        ),
      ];

      state = state.copyWith(
        achievements: achievements,
        totalStars: totalStars,
        totalFlights: totalFlights,
        bestScore: bestScore,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Не удалось загрузить достижения',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final achievementsProvider = StateNotifierProvider<AchievementsController, AchievementsState>((ref) {
  return AchievementsController(ref);
});