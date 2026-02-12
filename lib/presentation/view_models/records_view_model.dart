import 'package:flutter/foundation.dart';
import 'package:plane_dash/domain/entities/game_record.dart';
import 'package:plane_dash/domain/services/progress_service.dart';

class RecordsViewModel extends ChangeNotifier {
  final ProgressService _progressService = ProgressService();

  List<GameRecord> _records = [];
  List<GameRecord> get records => _records;

  int _totalStars = 0;
  int get totalStars => _totalStars;

  int _totalFlights = 0;
  int get totalFlights => _totalFlights;

  int _bestScore = 0;
  int get bestScore => _bestScore;

  List<int> _weeklyScores = [];
  List<int> get weeklyScores => _weeklyScores;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  RecordsViewModel() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _records = await _progressService.getGameRecords();
      _totalStars = await _progressService.getTotalStars();
      _totalFlights = await _progressService.getTotalFlights();
      _bestScore = await _progressService.getBestScore();
      _weeklyScores = await _progressService.getWeeklyScores();
    } catch (e) {
      _error = 'Не удалось загрузить данные';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNewRecord(GameRecord record) async {
    await loadData();
  }

  Future<void> resetProgress() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _progressService.resetAllProgress();
      await loadData();
    } catch (e) {
      _error = 'Ошибка сброса прогресса';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}