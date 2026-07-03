import 'package:brain_rush/models/math/math_topic.dart';
import 'package:brain_rush/models/math/math_lesson.dart';
import 'package:brain_rush/models/math/math_question.dart';
import 'package:brain_rush/models/math/math_progress.dart';
import 'package:brain_rush/models/math/math_reward.dart';
import 'package:brain_rush/models/math/math_statistics.dart';

/// Abstract repository for the Mathematics Learning Hub.
///
/// Implementations may fetch data from remote sources (Firestore) or
/// local persistence (SharedPreferences). For now we provide a local
/// implementation that stores JSON‑encoded strings.
abstract class MathRepository {
  // Save methods for initialization
  Future<void> saveTopic(MathTopic topic);
  Future<void> saveLesson(MathLesson lesson);
  Future<void> saveQuestion(MathQuestion question);
  // Topics
  Future<List<MathTopic>> getAllTopics();
  Future<MathTopic?> getTopicById(String id);

  // Lessons
  Future<List<MathLesson>> getLessonsForTopic(String topicId);
  Future<MathLesson?> getLessonById(String lessonId);

  // Questions
  Future<List<MathQuestion>> getQuestionsForLesson(String lessonId);
  Future<MathQuestion?> getQuestionById(String questionId);

  // Progress
  Future<MathProgress?> getProgress(String userId, String lessonId);
  Future<void> saveProgress(MathProgress progress);

  // Rewards
  Future<MathReward?> getReward(String userId, String topicId);
  Future<void> updateReward(MathReward reward);

  // Statistics for Parent Dashboard
  Future<MathStatistics?> getStatistics(String userId);
  Future<void> saveStatistics(MathStatistics stats);
}
