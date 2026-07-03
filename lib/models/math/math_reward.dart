import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'math_reward.g.dart';

@JsonSerializable()
class MathReward extends Equatable {
  final String topicId;
  final int xpEarned;
  final int coinsEarned;
  final int starsEarned;
  final int streakDays;

  const MathReward({
    required this.topicId,
    required this.xpEarned,
    required this.coinsEarned,
    required this.starsEarned,
    required this.streakDays,
  });

  factory MathReward.fromJson(Map<String, dynamic> json) => _$MathRewardFromJson(json);
  Map<String, dynamic> toJson() => _$MathRewardToJson(this);

  @override
  List<Object?> get props => [topicId, xpEarned, coinsEarned, starsEarned, streakDays];
}
