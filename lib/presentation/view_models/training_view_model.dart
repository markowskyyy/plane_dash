import 'package:flutter/foundation.dart';
import 'package:plane_dash/domain/enums/difficulty.dart';
import 'package:plane_dash/domain/services/progress_service.dart';
import 'package:plane_dash/domain/services/settings_service.dart';

class TrainingViewModel extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  final ProgressService _progressService = ProgressService();

  Difficulty? _selectedDifficulty;
  Difficulty? get selectedDifficulty => _selectedDifficulty;

  bool _soundEnabled = true;
  bool get soundEnabled => _soundEnabled;

  bool _vibrationEnabled = true;
  bool get vibrationEnabled => _vibrationEnabled;

  double _sensitivity = 0.5;
  double get sensitivity => _sensitivity;

  int _bestScoreNovice = 0;
  int get bestScoreNovice => _bestScoreNovice;

  int _bestScorePilot = 0;
  int get bestScorePilot => _bestScorePilot;

  int _bestScoreAce = 0;
  int get bestScoreAce => _bestScoreAce;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  TrainingViewModel() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _loadSettings(),
        _loadBestScores(),
      ]);
      _error = null;
    } catch (e) {
      _error = 'Не удалось загрузить настройки';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------- Настройки ----------
  Future<void> _loadSettings() async {
    _soundEnabled = await _settingsService.getSoundEnabled();
    _vibrationEnabled = await _settingsService.getVibrationEnabled();
    _sensitivity = await _settingsService.getSensitivity();
  }

  Future<void> toggleSound(bool value) async {
    await _settingsService.setSoundEnabled(value);
    _soundEnabled = value;
    notifyListeners();
  }

  Future<void> toggleVibration(bool value) async {
    await _settingsService.setVibrationEnabled(value);
    _vibrationEnabled = value;
    notifyListeners();
  }

  Future<void> updateSensitivity(double value) async {
    await _settingsService.setSensitivity(value);
    _sensitivity = value;
    notifyListeners();
  }

  Future<void> _loadBestScores() async {
    final overall = await _progressService.getBestScore();
    _bestScoreNovice = (overall * 0.5).round();
    _bestScorePilot = overall;
    _bestScoreAce = (overall * 1.5).round();
  }

  void selectDifficulty(Difficulty difficulty) {
    if (_selectedDifficulty == difficulty) {
      _selectedDifficulty = null; // повторный тап снимает выбор
    } else {
      _selectedDifficulty = difficulty;
    }
    notifyListeners();
  }

  void startTraining() {
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}