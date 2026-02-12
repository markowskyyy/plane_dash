import 'package:plane_dash/domain/entities/game_record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class ProgressService {
  static const String _totalStarsKey = 'total_stars';

  Future<int> getTotalStars() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalStarsKey) ?? 0;
  }

  Future<void> addStars(int stars) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_totalStarsKey) ?? 0;
    await prefs.setInt(_totalStarsKey, current + stars);
  }

  static const String _totalFlightsKey = 'total_flights';

  Future<int> getTotalFlights() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalFlightsKey) ?? 0;
  }

  Future<void> incrementFlights() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_totalFlightsKey) ?? 0;
    await prefs.setInt(_totalFlightsKey, current + 1);
  }

  static const String _bestScoreKey = 'best_score';

  Future<int> getBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestScoreKey) ?? 0;
  }

  Future<void> updateBestScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_bestScoreKey) ?? 0;
    if (score > current) {
      await prefs.setInt(_bestScoreKey, score);
    }
  }

  static const String _recordsListKey = 'records_list';

  Future<void> saveGameRecord(GameRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    List<GameRecord> records = await getGameRecords();

    records.add(record);
    records.sort((a, b) => b.score.compareTo(a.score));
    if (records.length > 10) records = records.sublist(0, 10);

    final List<Map<String, dynamic>> jsonList =
    records.map((r) => r.toJson()).toList();
    await prefs.setString(_recordsListKey, jsonEncode(jsonList));
  }

  Future<List<GameRecord>> getGameRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_recordsListKey);
    if (jsonString == null) return [];

    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((e) => GameRecord.fromJson(e)).toList();
  }

  static const String _weeklyScoresKey = 'weekly_scores';

  Future<void> updateWeeklyScores(int todayScore) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? stored = prefs.getStringList(_weeklyScoresKey);
    List<int> weekly = stored?.map((e) => int.tryParse(e) ?? 0).toList() ??
        List<int>.filled(7, 0, growable: true);

    weekly.removeAt(0);
    weekly.add(todayScore);
    await prefs.setStringList(_weeklyScoresKey, weekly.map((e) => e.toString()).toList());
  }

  Future<List<int>> getWeeklyScores() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_weeklyScoresKey)?.map((e) => int.parse(e)).toList() ??
        List.filled(7, 0);
  }

  Future<void> resetAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_totalStarsKey);
    await prefs.remove(_totalFlightsKey);
    await prefs.remove(_bestScoreKey);
    await prefs.remove(_recordsListKey);
    await prefs.remove(_weeklyScoresKey);
  }
}