import '../../domain/models/parental_reward.dart';
import '../../domain/repositories/i_parental_reward_repository.dart';
import '../datasources/local/database.dart';

class ParentalRewardRepositoryImpl implements IParentalRewardRepository {
  final AppDatabase _db;

  ParentalRewardRepositoryImpl({AppDatabase? db}) : _db = db ?? AppDatabase.instance;

  @override
  Stream<List<ParentalReward>> watchRewardsForUser(String userId) {
    return _db.watchRewardsForUser(userId);
  }

  @override
  Future<void> createReward(ParentalReward reward) async {
    await _db.upsertReward(reward);
  }

  @override
  Future<void> updateReward(ParentalReward reward) async {
    await _db.upsertReward(reward);
  }

  @override
  Future<void> claimReward(String rewardId) async {
    await _db.claimReward(rewardId);
  }
}
