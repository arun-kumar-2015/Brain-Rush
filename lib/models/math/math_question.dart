import 'package:equatable/equatable.dart';

/// Represents a single math question with optional multimedia support.
/// Supports multiple choice, numeric input, and speech‑to‑text answer verification.
class MathQuestion extends Equatable {
  final String id;
  final String topicId; // reference to MathTopic.id
  final String questionText;
  final List<String>? options; // null for numeric / open‑ended questions
  final String? correctAnswer;
  final String? correctOption; // for multiple‑choice, the exact option string
  final String? audioUrl; // TTS audio for the question if needed
  final String? imageUrl; // Optional illustration

  const MathQuestion({
    required this.id,
    required this.topicId,
    required this.questionText,
    this.options,
    this.correctAnswer,
    this.correctOption,
    this.audioUrl,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        topicId,
        questionText,
        options,
        correctAnswer,
        correctOption,
        audioUrl,
        imageUrl,
      ];

  // Factory for JSON (Firestore / local storage) serialization
  factory MathQuestion.fromJson(Map<String, dynamic> json) => MathQuestion(
        id: json['id'] as String,
        topicId: json['topicId'] as String,
        questionText: json['questionText'] as String,
        options: (json['options'] as List<dynamic>?)?.cast<String>(),
        correctAnswer: json['correctAnswer'] as String?,
        correctOption: json['correctOption'] as String?,
        audioUrl: json['audioUrl'] as String?,
        imageUrl: json['imageUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'topicId': topicId,
        'questionText': questionText,
        'options': options,
        'correctAnswer': correctAnswer,
        'correctOption': correctOption,
        'audioUrl': audioUrl,
        'imageUrl': imageUrl,
      };
}
