import '../../domain/models/memorization_plan.dart';
import '../../domain/repositories/i_plan_repository.dart';
import '../datasources/local/database.dart';

class PlanRepositoryImpl implements IPlanRepository {
  final AppDatabase _db;

  PlanRepositoryImpl({AppDatabase? db}) : _db = db ?? AppDatabase.instance;

  @override
  Stream<List<MemorizationPlan>> watchPlansForUser(String userId) {
    return _db.watchPlansForUser(userId);
  }

  @override
  Future<void> createPlan(MemorizationPlan plan) async {
    await _db.savePlan(plan);
  }

  @override
  Future<void> updatePlan(MemorizationPlan plan) async {
    await _db.savePlan(plan);
  }
}
