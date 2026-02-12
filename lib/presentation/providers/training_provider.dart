import 'package:plane_dash/domain/enums/difficulty.dart';
import 'package:plane_dash/domain/services/progress_service.dart';
import 'package:plane_dash/domain/services/services_provider.dart';
import 'package:plane_dash/domain/services/settings_service.dart';
import 'package:riverpod/riverpod.dart';


class TrainingState {
  final Difficulty? selectedDifficulty;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final double sensitivity;
  final int bestScoreNovice;
  final int bestScorePilot;
  final int bestScoreAce;
  final bool isLoading;
  final String? error;

  TrainingState({
    this.selectedDifficulty,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.sensitivity,
    required this.bestScoreNovice,
    required this.bestScorePilot,
    required this.bestScoreAce,
    required this.isLoading,
    this.error,
  });

  TrainingState.initial()
      : selectedDifficulty = null,
        soundEnabled = true,
        vibrationEnabled = true,
        sensitivity = 0.5,
        bestScoreNovice = 0,
        bestScorePilot = 0,
        bestScoreAce = 0,
        isLoading = true,
        error = null;

  TrainingState copyWith({
    Difficulty? selectedDifficulty,
    bool? soundEnabled,
    bool? vibrationEnabled,
    double? sensitivity,
    int? bestScoreNovice,
    int? bestScorePilot,
    int? bestScoreAce,
    bool? isLoading,
    String? error,
  }) {
    return TrainingState(
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      sensitivity: sensitivity ?? this.sensitivity,
      bestScoreNovice: bestScoreNovice ?? this.bestScoreNovice,
      bestScorePilot: bestScorePilot ?? this.bestScorePilot,
      bestScoreAce: bestScoreAce ?? this.bestScoreAce,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TrainingController extends StateNotifier<TrainingState> {
  final Ref _ref;
  late final SettingsService _settingsService;
  late final ProgressService _progressService;

  TrainingController(this._ref) : super(TrainingState.initial()) {
    _settingsService = _ref.read(settingsServiceProvider);
    _progressService = _ref.read(progressServiceProvider);
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    try {
      await Future.wait([
        _loadSettings(),
        _loadBestScores(),
      ]);
      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Не удалось загрузить настройки');
    }
  }

  Future<void> _loadSettings() async {
    final sound = await _settingsService.getSoundEnabled();
    final vibration = await _settingsService.getVibrationEnabled();
    final sens = await _settingsService.getSensitivity();
    state = state.copyWith(
      soundEnabled: sound,
      vibrationEnabled: vibration,
      sensitivity: sens,
    );
  }

  Future<void> _loadBestScores() async {
    final overall = await _progressService.getBestScore();
    state = state.copyWith(
      bestScoreNovice: (overall * 0.5).round(),
      bestScorePilot: overall,
      bestScoreAce: (overall * 1.5).round(),
    );
  }

  Future<void> toggleSound(bool value) async {
    await _settingsService.setSoundEnabled(value);
    state = state.copyWith(soundEnabled: value);
  }

  Future<void> toggleVibration(bool value) async {
    await _settingsService.setVibrationEnabled(value);
    state = state.copyWith(vibrationEnabled: value);
  }

  Future<void> updateSensitivity(double value) async {
    await _settingsService.setSensitivity(value);
    state = state.copyWith(sensitivity: value);
  }

  void selectDifficulty(Difficulty difficulty) {
    if (state.selectedDifficulty == difficulty) {
      state = state.copyWith(selectedDifficulty: null);
    } else {
      state = state.copyWith(selectedDifficulty: difficulty);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final trainingProvider = StateNotifierProvider<TrainingController, TrainingState>((ref) {
  return TrainingController(ref);
});