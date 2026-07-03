import 'package:equatable/equatable.dart';

/// Represents a math topic (e.g., Counting, Addition) for a specific age range.
class MathTopic extends Equatable {
  final String id;
  final String name;
  final int minAge; // inclusive
  final int maxAge; // inclusive
  final String? description;

  const MathTopic({
    required this.id,
    required this.name,
    required this.minAge,
    required this.maxAge,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, minAge, maxAge, description];

  factory MathTopic.fromJson(Map<String, dynamic> json) => MathTopic(
        id: json['id'] as String,
        name: json['name'] as String,
        minAge: json['minAge'] as int,
        maxAge: json['maxAge'] as int,
        description: json['description'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'minAge': minAge,
        'maxAge': maxAge,
        'description': description,
      };
}
