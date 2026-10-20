import 'package:equatable/equatable.dart';

class ParentalReward extends Equatable {
  final String rewardId;
  final String userId;
  final String title;
  final String description; // e.g. "رحلة إلى الملاهي", "هدية دراجة جديدة", "شراء كتاب مفضل"
  final int targetQuarterMilestone; // e.g. 10 quarters
  final int targetStreakMilestone; // e.g. 14 days
  final bool isUnlocked;
  final bool isClaimed;
  final DateTime createdAt;

  const ParentalReward({
    required this.rewardId,
    required this.userId,
    required this.title,
    required this.description,
    required this.targetQuarterMilestone,
    this.targetStreakMilestone = 0,
    this.isUnlocked = false,
    this.isClaimed = false,
    required this.createdAt,
  });

  ParentalReward copyWith({
    String? rewardId,
    String? userId,
    String? title,
    String? description,
    int? targetQuarterMilestone,
    int? targetStreakMilestone,
    bool? isUnlocked,
    bool? isClaimed,
    DateTime? createdAt,
  }) {
    return ParentalReward(
      rewardId: rewardId ?? this.rewardId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      targetQuarterMilestone: targetQuarterMilestone ?? this.targetQuarterMilestone,
      targetStreakMilestone: targetStreakMilestone ?? this.targetStreakMilestone,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isClaimed: isClaimed ?? this.isClaimed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        rewardId,
        userId,
        title,
        description,
        targetQuarterMilestone,
        targetStreakMilestone,
        isUnlocked,
        isClaimed,
        createdAt,
      ];
}
