import 'dart:math';
import 'package:brain_rush/models/math/math_topic.dart';
import 'package:brain_rush/models/math/math_lesson.dart';
import 'package:brain_rush/models/math/math_question.dart';

/// Service that programmatically generates math topics, lessons, and questions.
/// The generated data can be persisted via the LocalMathRepository.
class MathGenerationService {
  final Random _rand = Random();

  // -----------------------------------------------------------------
  // Topics
  // -----------------------------------------------------------------
  List<MathTopic> generateTopics() {
    return [
      MathTopic(id: 't1', name: 'Counting', minAge: 3, maxAge: 4, description: 'Learn to count objects 1‑10'),
      MathTopic(id: 't2', name: 'Basic Addition', minAge: 5, maxAge: 6, description: 'Simple addition within 20'),
      MathTopic(id: 't3', name: 'Subtraction', minAge: 6, maxAge: 8, description: 'Subtract numbers up to 20'),
      MathTopic(id: 't4', name: 'Multiplication', minAge: 8, maxAge: 10, description: 'Multiplication tables 2‑5'),
      MathTopic(id: 't5', name: 'Division', minAge: 10, maxAge: 12, description: 'Basic division concepts'),
      MathTopic(id: 't6', name: 'Fractions', minAge: 12, maxAge: 14, description: 'Understanding halves, quarters, etc.'),
    ];
  }

  // -----------------------------------------------------------------
  // Lessons per topic (3 lessons each as a demo)
  // -----------------------------------------------------------------
  List<MathLesson> generateLessons(MathTopic topic) {
    return List.generate(3, (index) {
      return MathLesson(
        id: '${topic.id}_l${index + 1}',
        topicId: topic.id,
        title: '${topic.name} Lesson ${index + 1}',
        content: 'Interactive content for ${topic.name} (Lesson ${index + 1})',
        assetPath: null,
      );
    });
  }

  // -----------------------------------------------------------------
  // Questions per lesson – generates a mixed pool of 20‑30 questions.
  // -----------------------------------------------------------------
  List<MathQuestion> generateQuestions(MathLesson lesson) {
    final List<MathQuestion> questions = [];
    for (int i = 0; i < 20; i++) {
      final qId = '${lesson.id}_q${i + 1}';
      // Simple deterministic pattern based on lesson name.
      if (lesson.title.contains('Counting')) {
        final number = _rand.nextInt(20) + 1;
        questions.add(MathQuestion(
          id: qId,
          topicId: lesson.topicId,
          questionText: 'How many objects are shown? $number',
          correctAnswer: number.toString(),
        ));
      } else if (lesson.title.contains('Addition')) {
        final a = _rand.nextInt(10) + 1;
        final b = _rand.nextInt(10) + 1;
        final result = a + b;
        questions.add(MathQuestion(
          id: qId,
          topicId: lesson.topicId,
          questionText: '$a + $b = ?',
          options: [
            (result - 1).toString(),
            result.toString(),
            (result + 1).toString(),
            (result + 2).toString(),
          ],
          correctOption: result.toString(),
        ));
      } else if (lesson.title.contains('Subtraction')) {
        final a = _rand.nextInt(20) + 10;
        final b = _rand.nextInt(10);
        final result = a - b;
        questions.add(MathQuestion(
          id: qId,
          topicId: lesson.topicId,
          questionText: '$a - $b = ?',
          options: [
            (result - 1).toString(),
            result.toString(),
            (result + 1).toString(),
            (result + 2).toString(),
          ],
          correctOption: result.toString(),
        ));
      } else if (lesson.title.contains('Multiplication')) {
        final a = _rand.nextInt(12) + 1;
        final b = _rand.nextInt(12) + 1;
        final result = a * b;
        questions.add(MathQuestion(
          id: qId,
          topicId: lesson.topicId,
          questionText: '$a × $b = ?',
          options: [
            (result - 2).toString(),
            (result - 1).toString(),
            result.toString(),
            (result + 1).toString(),
          ],
          correctOption: result.toString(),
        ));
      } else if (lesson.title.contains('Division')) {
        final divisor = _rand.nextInt(10) + 1;
        final quotient = _rand.nextInt(10) + 1;
        final dividend = divisor * quotient;
        questions.add(MathQuestion(
          id: qId,
          topicId: lesson.topicId,
          questionText: '$dividend ÷ $divisor = ?',
          options: [
            (quotient - 1).toString(),
            quotient.toString(),
            (quotient + 1).toString(),
            (quotient + 2).toString(),
          ],
          correctOption: quotient.toString(),
        ));
      } else {
        // Fractions – simple representation
        final numerator = _rand.nextInt(9) + 1;
        final denominator = numerator + _rand.nextInt(5) + 1;
        questions.add(MathQuestion(
          id: qId,
          topicId: lesson.topicId,
          questionText: 'What is $numerator/$denominator simplified?',
          correctAnswer: '$numerator/$denominator',
        ));
      }
    }
    return questions;
  }
}
