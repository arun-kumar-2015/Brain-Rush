import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalScoreService {
  static const String _keyBestScores = 'best_scores';
  static const String _keyTotalScore = 'total_score';
  static const String _keyGamesPlayed = 'games_played';

  // Save score locally
  Future<void> saveScoreLocally(String gameName, int score) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Update Best Scores
    Map<String, int> bestScores = await getBestScores();
    if (score > (bestScores[gameName] ?? 0)) {
      bestScores[gameName] = score;
      await prefs.setString(_keyBestScores, jsonEncode(bestScores));
    }

    // Update Total Score
    int total = prefs.getInt(_keyTotalScore) ?? 0;
    await prefs.setInt(_keyTotalScore, total + score);

    // Update Games Played
    int played = prefs.getInt(_keyGamesPlayed) ?? 0;
    await prefs.setInt(_keyGamesPlayed, played + 1);
  }

  // Get all local data
  Future<Map<String, int>> getBestScores() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString(_keyBestScores);
    if (data == null) return {};
    return Map<String, int>.from(jsonDecode(data));
  }

  Future<int> getTotalScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTotalScore) ?? 0;
  }

  Future<int> getGamesPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyGamesPlayed) ?? 0;
  }

  // Clear local data (e.g. on logout)
  Future<void> clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
