import 'package:plane_dash/domain/enums/difficulty.dart';

class GameRecord {
  final String playerName;
  final int score;
  final int starsCollected;
  final DateTime date;
  final Difficulty difficulty;

  GameRecord({
    required this.playerName,
    required this.score,
    required this.starsCollected,
    required this.date,
    required this.difficulty,
  });

  Map<String, dynamic> toJson() => {
    'playerName': playerName,
    'score': score,
    'starsCollected': starsCollected,
    'date': date.toIso8601String(),
    'difficulty': difficulty.index,
  };

  factory GameRecord.fromJson(Map<String, dynamic> json) {
    return GameRecord(
      playerName: json['playerName'],
      score: json['score'],
      starsCollected: json['starsCollected'],
      date: DateTime.parse(json['date']),
      difficulty: Difficulty.values[json['difficulty']],
    );
  }
}