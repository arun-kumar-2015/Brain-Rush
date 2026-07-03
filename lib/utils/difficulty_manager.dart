class DifficultyManager {
  static int calculateNextDifficulty(int currentLevel, bool wasSuccessful, {int maxLevel = 10}) {
    if (wasSuccessful) {
      return (currentLevel < maxLevel) ? currentLevel + 1 : maxLevel;
    } else {
      return (currentLevel > 1) ? currentLevel - 1 : 1;
    }
  }

  // Memory Game: returns grid size based on level
  static int getMemoryGridSize(int level) {
    if (level <= 2) return 2; // 2x2
    if (level <= 5) return 4; // 4x4
    return 6; // 6x6
  }

  // Math Game: returns range of numbers based on level
  static int getMathRange(int level) {
    return level * 10;
  }

  // Math Game: returns operators based on level
  static List<String> getMathOperators(int level) {
    if (level <= 3) return ['+', '-'];
    if (level <= 6) return ['+', '-', '*'];
    return ['+', '-', '*', '/'];
  }

  // Pattern Game: returns sequence length
  static int getPatternLength(int level) {
    return level + 2;
  }
}
