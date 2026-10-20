import '../models/daily_task.dart';

abstract class ITaskRepository {
  Stream<List<DailyTask>> watchTasksForPlan(String planId);
  Stream<List<DailyTask>> watchTasksForUser(String userId);
  Future<void> updateTask(DailyTask task);
  Future<void> updateTasksBatch(List<DailyTask> tasks);
  Future<void> togglePrayerCheckoff(String taskId, int prayerIndex, bool isCompleted);
}
