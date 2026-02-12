enum Difficulty {
  novice,
  pilot,
  ace,
}

extension DifficultyExtension on Difficulty {
  String get displayName {
    switch (this) {
      case Difficulty.novice:
        return 'Новичок';
      case Difficulty.pilot:
        return 'Пилот';
      case Difficulty.ace:
        return 'Ас';
    }
  }

  String get iconAsset {
    switch (this) {
      case Difficulty.novice:
        return 'assets/icons/turtle.png';
      case Difficulty.pilot:
        return 'assets/icons/plane.png';
      case Difficulty.ace:
        return 'assets/icons/lightning.png';
    }
  }
}
