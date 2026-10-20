import '../models/parental_reward.dart';

abstract class IParentalRewardRepository {
  Stream<List<ParentalReward>> watchRewardsForUser(String userId);
  Future<void> createReward(ParentalReward reward);
  Future<void> updateReward(ParentalReward reward);
  Future<void> claimReward(String rewardId);
}
