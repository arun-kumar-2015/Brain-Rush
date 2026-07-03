import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const String _keyLessonsCompleted = 'lessonsCompleted';
  static const String _keyCoins = 'coins';

  Future<void> addLessonCompleted(String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> completed = prefs.getStringList(_keyLessonsCompleted) ?? [];
    if (!completed.contains(lessonId)) {
      completed.add(lessonId);
      await prefs.setStringList(_keyLessonsCompleted, completed);
      await addCoins(10); // Reward 10 coins for new lesson
    }
  }

  Future<List<String>> getCompletedLessons() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyLessonsCompleted) ?? [];
  }

  Future<void> addCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    int coins = prefs.getInt(_keyCoins) ?? 0;
    await prefs.setInt(_keyCoins, coins + amount);
  }

  Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCoins) ?? 0;
  }
}
