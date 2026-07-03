import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'math_progress.g.dart';

@JsonSerializable()
class MathProgress extends Equatable {
  final String topicId;
  final String lessonId;
  final bool completed;
  final int attempts;
  final double accuracy; // percentage 0-100
  final DateTime lastAttempt;

  const MathProgress({
    required this.topicId,
    required this.lessonId,
    required this.completed,
    required this.attempts,
    required this.accuracy,
    required this.lastAttempt,
  });

  factory MathProgress.fromJson(Map<String, dynamic> json) => _$MathProgressFromJson(json);
  Map<String, dynamic> toJson() => _$MathProgressToJson(this);

  @override
  List<Object?> get props => [topicId, lessonId, completed, attempts, accuracy, lastAttempt];
}
