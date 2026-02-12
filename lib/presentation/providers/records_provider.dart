import 'package:plane_dash/domain/entities/game_record.dart';
import 'package:plane_dash/domain/services/progress_service.dart';
import 'package:plane_dash/domain/services/services_provider.dart';
import 'package:riverpod/riverpod.dart';


class RecordsState {
  final List<GameRecord> records;
  final int totalStars;
  final int totalFlights;
  final int bestScore;
  final List<int> weeklyScores;
  final bool isLoading;
  final String? error;

  RecordsState({
    required this.records,
    required this.totalStars,
    required this.totalFlights,
    required this.bestScore,
    required this.weeklyScores,
    required this.isLoading,
    this.error,
  });

  RecordsState.initial()
      : records = const [],
        totalStars = 0,
        totalFlights = 0,
        bestScore = 0,
        weeklyScores = const [0, 0, 0, 0, 0, 0, 0],
        isLoading = true,
        error = null;

  RecordsState copyWith({
    List<GameRecord>? records,
    int? totalStars,
    int? totalFlights,
    int? bestScore,
    List<int>? weeklyScores,
    bool? isLoading,
    String? error,
  }) {
    return RecordsState(
      records: records ?? this.records,
      totalStars: totalStars ?? this.totalStars,
      totalFlights: totalFlights ?? this.totalFlights,
      bestScore: bestScore ?? this.bestScore,
      weeklyScores: weeklyScores ?? this.weeklyScores,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class RecordsController extends StateNotifier<RecordsState> {
  final Ref _ref;
  late final ProgressService _progressService;

  RecordsController(this._ref) : super(RecordsState.initial()) {
    _progressService = _ref.read(progressServiceProvider);
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final records = await _progressService.getGameRecords();
      final totalStars = await _progressService.getTotalStars();
      final totalFlights = await _progressService.getTotalFlights();
      final bestScore = await _progressService.getBestScore();
      final weeklyScores = await _progressService.getWeeklyScores();

      state = state.copyWith(
        records: records,
        totalStars: totalStars,
        totalFlights: totalFlights,
        bestScore: bestScore,
        weeklyScores: weeklyScores,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Не удалось загрузить данные',
      );
    }
  }

  Future<void> resetProgress() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _progressService.resetAllProgress();
      await loadData(); // перезагрузит с нулями
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка сброса прогресса',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final recordsProvider = StateNotifierProvider<RecordsController, RecordsState>((ref) {
  return RecordsController(ref);
});