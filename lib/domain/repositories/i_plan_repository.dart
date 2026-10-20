import '../models/memorization_plan.dart';

abstract class IPlanRepository {
  Stream<List<MemorizationPlan>> watchPlansForUser(String userId);
  Future<void> createPlan(MemorizationPlan plan);
  Future<void> updatePlan(MemorizationPlan plan);
}
