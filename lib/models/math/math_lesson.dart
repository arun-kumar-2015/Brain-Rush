import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'math_lesson.g.dart';

@JsonSerializable()
class MathLesson extends Equatable {
  final String id;
  final String topicId;
  final String title;
  final String content; // textual description or HTML
  final String? assetPath; // optional image/video asset

  const MathLesson({
    required this.id,
    required this.topicId,
    required this.title,
    required this.content,
    this.assetPath,
  });

  factory MathLesson.fromJson(Map<String, dynamic> json) => _$MathLessonFromJson(json);
  Map<String, dynamic> toJson() => _$MathLessonToJson(this);

  @override
  List<Object?> get props => [id, topicId, title, content, assetPath];
}
