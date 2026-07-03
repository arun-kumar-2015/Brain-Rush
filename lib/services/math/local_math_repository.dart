// lib/services/math/local_math_repository.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brain_rush/models/math/math_topic.dart';
import 'package:brain_rush/models/math/math_lesson.dart';
import 'package:brain_rush/models/math/math_question.dart';
import 'package:brain_rush/models/math/math_progress.dart';
import 'package:brain_rush/models/math/math_reward.dart';
import 'package:brain_rush/models/math/math_statistics.dart';
import 'math_repository.dart';

/// Local implementation of [MathRepository] using SharedPreferences.
class LocalMathRepository implements MathRepository {
  final SharedPreferences _prefs;

  LocalMathRepository(this._prefs);

  // Helper keys
  String _topicKey(String id) => 'math_topic_\u001f$id';
  String _lessonKey(String id) => 'math_lesson_\u001f$id';
  String _questionKey(String id) => 'math_question_\u001f$id';
  String _progressKey(String userId, String lessonId) =>
      'math_progress_\u001f$userId_\u001f$lessonId';
  String _rewardKey(String userId, String topicId) =>
      'math_reward_\u001f$userId_\u001f$topicId';
  String _statisticsKey(String userId) => 'math_statistics_\u001f$userId';

  // ---------- Save methods ----------
  @override
  Future<void> saveTopic(MathTopic topic) async {
    await _prefs.setString(_topicKey(topic.id), jsonEncode(topic.toJson()));
  }

  @override
  Future<void> saveLesson(MathLesson lesson) async {
    await _prefs.setString(_lessonKey(lesson.id), jsonEncode(lesson.toJson()));
  }

  @override
  Future<void> saveQuestion(MathQuestion question) async {
    await _prefs.setString(_questionKey(question.id), jsonEncode(question.toJson()));
  }

  // ---------- Retrieval methods ----------
  @override
  Future<List<MathTopic>> getAllTopics() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith('math_topic_'));
    return keys
        .map((k) => MathTopic.fromJson(jsonDecode(_prefs.getString(k)!)))
        .toList();
  }

  @override
  Future<MathTopic?> getTopicById(String id) async {
    final json = _prefs.getString(_topicKey(id));
    return json != null ? MathTopic.fromJson(jsonDecode(json)) : null;
  }

  @override
  Future<List<MathLesson>> getLessonsForTopic(String topicId) async {
    final keys = _prefs
        .getKeys()
        .where((k) => k.startsWith('math_lesson_') && _prefs.getString(k) != null);
    return keys
        .map((k) => MathLesson.fromJson(jsonDecode(_prefs.getString(k)!)))
        .where((lesson) => lesson.topicId == topicId)
        .toList();
  }

  @override
  Future<MathLesson?> getLessonById(String lessonId) async {
    final json = _prefs.getString(_lessonKey(lessonId));
    return json != null ? MathLesson.fromJson(jsonDecode(json)) : null;
  }

  @override
  Future<List<MathQuestion>> getQuestionsForLesson(String lessonId) async {
    final keys = _prefs
        .getKeys()
        .where((k) => k.startsWith('math_question_') && _prefs.getString(k) != null);
    return keys
        .map((k) => MathQuestion.fromJson(jsonDecode(_prefs.getString(k)!)))
        .where((q) => q.lessonId == lessonId)
        .toList();
  }

  @override
  Future<MathQuestion?> getQuestionById(String questionId) async {
    final json = _prefs.getString(_questionKey(questionId));
    return json != null ? MathQuestion.fromJson(jsonDecode(json)) : null;
  }

  @override
  Future<MathProgress?> getProgress(String userId, String lessonId) async {
    final json = _prefs.getString(_progressKey(userId, lessonId));
    return json != null ? MathProgress.fromJson(jsonDecode(json)) : null;
  }

  @override
  Future<void> saveProgress(MathProgress progress) async {
    await _prefs.setString(
        _progressKey(progress.userId, progress.lessonId), jsonEncode(progress.toJson()));
  }

  @override
  Future<MathReward?> getReward(String userId, String topicId) async {
    final json = _prefs.getString(_rewardKey(userId, topicId));
    return json != null ? MathReward.fromJson(jsonDecode(json)) : null;
  }

  @override
  Future<void> updateReward(MathReward reward) async {
    await _prefs.setString(
        _rewardKey(reward.userId, reward.topicId), jsonEncode(reward.toJson()));
  }

  @override
  Future<MathStatistics?> getStatistics(String userId) async {
    final json = _prefs.getString(_statisticsKey(userId));
    return json != null ? MathStatistics.fromJson(jsonDecode(json)) : null;
  }

  @override
  Future<void> saveStatistics(MathStatistics stats) async {
    await _prefs.setString(_statisticsKey(stats.userId), jsonEncode(stats.toJson()));
  }
}
