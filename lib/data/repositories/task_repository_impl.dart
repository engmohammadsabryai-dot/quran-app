import '../../domain/models/daily_task.dart';
import '../../domain/repositories/i_task_repository.dart';
import '../datasources/local/database.dart';

class TaskRepositoryImpl implements ITaskRepository {
  final AppDatabase _db;

  TaskRepositoryImpl({AppDatabase? db}) : _db = db ?? AppDatabase.instance;

  @override
  Stream<List<DailyTask>> watchTasksForPlan(String planId) {
    return _db.watchTasksForPlan(planId);
  }

  @override
  Stream<List<DailyTask>> watchTasksForUser(String userId) {
    return _db.watchTasksForUser(userId);
  }

  @override
  Future<void> updateTask(DailyTask task) async {
    await _db.updateTask(task);
  }

  @override
  Future<void> updateTasksBatch(List<DailyTask> tasks) async {
    await _db.updateTasksBatch(tasks);
  }

  @override
  Future<void> togglePrayerCheckoff(String taskId, int prayerIndex, bool isCompleted) async {
    final tasks = _db.tasks; // current cached tasks
    final idx = tasks.indexWhere((t) => t.taskId == taskId);
    if (idx >= 0) {
      final task = tasks[idx];
      DailyTask updated;
      switch (prayerIndex) {
        case 1:
          updated = task.copyWith(prayer1FajrDone: isCompleted);
          break;
        case 2:
          updated = task.copyWith(prayer2DhuhrDone: isCompleted);
          break;
        case 3:
          updated = task.copyWith(prayer3AsrDone: isCompleted);
          break;
        case 4:
          updated = task.copyWith(prayer4MaghribDone: isCompleted);
          break;
        case 5:
          updated = task.copyWith(prayer5IshaDone: isCompleted);
          break;
        default:
          updated = task;
      }

      // If all 5 prayers done, auto-mark task as completed if not already
      if (updated.areAllPrayersCompleted && !updated.isCompleted) {
        updated = updated.copyWith(isCompleted: true, completedAt: DateTime.now());
      }

      await _db.updateTask(updated);
    }
  }
}
