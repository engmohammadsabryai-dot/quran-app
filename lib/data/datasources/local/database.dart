import 'dart:async';
import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/models/daily_task.dart';
import '../../domain/models/memorization_plan.dart';
import '../../domain/models/mutashabiha_item.dart';
import '../../domain/models/parental_reward.dart';
import '../../domain/models/user_profile.dart';
import 'seed_data.dart';

// DRIFT TABLE DEFINITIONS

@DataClassName('ProfileEntry')
class UserProfilesTable extends Table {
  TextColumn get userId => text()();
  TextColumn get name => text()();
  IntColumn get age => integer()();
  TextColumn get gender => text()();
  TextColumn get avatarId => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {userId};
}

@DataClassName('PlanEntry')
class MemorizationPlansTable extends Table {
  TextColumn get planId => text()();
  TextColumn get userId => text()();
  TextColumn get systemType => text()();
  TextColumn get name => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get targetEndDate => dateTime()();
  IntColumn get totalTasks => integer()();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {planId};
}

@DataClassName('TaskEntry')
class DailyTasksTable extends Table {
  TextColumn get taskId => text()();
  TextColumn get planId => text()();
  TextColumn get userId => text()();
  IntColumn get dayNumber => integer()();
  DateTimeColumn get scheduledDate => dateTime()();
  IntColumn get surahNumber => integer()();
  TextColumn get surahArabicName => text()();
  IntColumn get fromAyah => integer()();
  IntColumn get toAyah => integer()();
  IntColumn get quarterIndex => integer().nullable()();
  IntColumn get pageNumber => integer().nullable()();
  TextColumn get portionTitle => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  BoolColumn get isFridayReview => boolean().withDefault(const Constant(false))();
  TextColumn get compensationNote => text().nullable()();

  // 5 Prayers check-off flags
  BoolColumn get prayer1Done => boolean().withDefault(const Constant(false))();
  BoolColumn get prayer2Done => boolean().withDefault(const Constant(false))();
  BoolColumn get prayer3Done => boolean().withDefault(const Constant(false))();
  BoolColumn get prayer4Done => boolean().withDefault(const Constant(false))();
  BoolColumn get prayer5Done => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {taskId};
}

@DataClassName('MutashabihaEntry')
class MutashabihatTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get surah1 => integer()();
  TextColumn get surah1Name => text()();
  IntColumn get ayah1 => integer()();
  TextColumn get text1 => text()();
  IntColumn get surah2 => integer()();
  TextColumn get surah2Name => text()();
  IntColumn get ayah2 => integer()();
  TextColumn get text2 => text()();
  TextColumn get ruleMnemonic => text()();
  TextColumn get differenceHighlight => text()();
  TextColumn get category => text()();
}

@DataClassName('ParentalRewardEntry')
class ParentalRewardsTable extends Table {
  TextColumn get rewardId => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  IntColumn get targetQuarterMilestone => integer()();
  IntColumn get targetStreakMilestone => integer().withDefault(const Constant(0))();
  BoolColumn get isUnlocked => boolean().withDefault(const Constant(false))();
  BoolColumn get isClaimed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {rewardId};
}

@DataClassName('OfflineAudioCacheEntry')
class OfflineAudioCacheTable extends Table {
  TextColumn get cacheId => text()();
  TextColumn get reciterId => text()();
  IntColumn get surahNumber => integer()();
  IntColumn get ayahNumber => integer()();
  TextColumn get localFilePath => text()();
  IntColumn get fileSizeBytes => integer()();
  DateTimeColumn get downloadedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {cacheId};
}

/// Robust In-Memory and SQLite-backed Reactive Database Engine
/// Exposes reactive streams (BehaviorSubject), seed data population, and type-safe DAOs
class AppDatabase {
  static AppDatabase? _instance;
  static AppDatabase get instance => _instance ??= AppDatabase._internal();

  // In-Memory Reactive stores for fault-tolerant offline execution
  final BehaviorSubject<List<UserProfile>> _profilesSubject = BehaviorSubject<List<UserProfile>>();
  final BehaviorSubject<List<MemorizationPlan>> _plansSubject = BehaviorSubject<List<MemorizationPlan>>();
  final BehaviorSubject<List<DailyTask>> _tasksSubject = BehaviorSubject<List<DailyTask>>();
  final BehaviorSubject<List<MutashabihaItem>> _mutashabihatSubject = BehaviorSubject<List<MutashabihaItem>>();
  final BehaviorSubject<List<ParentalReward>> _rewardsSubject = BehaviorSubject<List<ParentalReward>>();

  AppDatabase._internal() {
    _seedInitialData();
  }

  void _seedInitialData() {
    // 1. Seed Initial Profiles (Adult and Kid)
    _profilesSubject.add(List.from(AppSeedData.initialProfiles));

    // 2. Seed Mutashabihat Catalog
    _mutashabihatSubject.add(List.from(AppSeedData.mutashabihatCatalog));

    // 3. Seed Parental Rewards
    _rewardsSubject.add(List.from(AppSeedData.initialRewards));

    // 4. Seed Standard 280-Day Quarter Plan for Adult user
    final adultUserId = AppSeedData.initialProfiles.first.userId;
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 3));

    final adultPlan = MemorizationPlan(
      planId: 'plan-adult-001',
      userId: adultUserId,
      systemType: MemorizationSystemType.quarterSystem,
      name: 'ختمة الحفظ المتقن - نظام الأرباع (٢٨٠ يوماً)',
      startDate: startDate,
      targetEndDate: startDate.add(const Duration(days: 280)),
      totalTasks: 280,
      currentStreak: 2,
    );

    _plansSubject.add([adultPlan]);

    // Generate tasks for the adult plan
    final quarterSeeds = AppSeedData.generateAll240Quarters();
    final List<DailyTask> initialTasks = [];

    int quarterIndex = 0;
    for (int day = 1; day <= 28; day++) { // First 4 weeks demo
      final taskDate = startDate.add(Duration(days: day - 1));
      final isFriday = taskDate.weekday == DateTime.friday;

      if (isFriday) {
        // Dedicated Friday Review Day
        initialTasks.add(
          DailyTask(
            taskId: 'task-${adultPlan.planId}-$day',
            planId: adultPlan.planId,
            userId: adultUserId,
            dayNumber: day,
            scheduledDate: taskDate,
            surahNumber: 2,
            surahArabicName: 'البقرة',
            fromAyah: 1,
            toAyah: quarterIndex > 0 ? quarterSeeds[quarterIndex - 1].toAyah : 25,
            portionTitle: 'جلسة مراجعة وتثبيت الجمعة الأسبوعية',
            isFridayReview: true,
            isCompleted: day < 3,
            completedAt: day < 3 ? taskDate : null,
          ),
        );
      } else {
        // Active Memorization Day
        if (quarterIndex < quarterSeeds.length) {
          final q = quarterSeeds[quarterIndex];
          final isPastCompleted = day == 1 || day == 2;
          initialTasks.add(
            DailyTask(
              taskId: 'task-${adultPlan.planId}-$day',
              planId: adultPlan.planId,
              userId: adultUserId,
              dayNumber: day,
              scheduledDate: taskDate,
              surahNumber: q.surahNumber,
              surahArabicName: q.surahArabicName,
              fromAyah: q.fromAyah,
              toAyah: q.toAyah,
              quarterIndex: q.quarterIndex,
              pageNumber: q.pageNumber,
              portionTitle: 'الربع رقم ${q.quarterIndex} (${q.firstWords})',
              isCompleted: isPastCompleted,
              completedAt: isPastCompleted ? taskDate : null,
              prayer1FajrDone: isPastCompleted,
              prayer2DhuhrDone: isPastCompleted,
              prayer3AsrDone: isPastCompleted,
              prayer4MaghribDone: isPastCompleted,
              prayer5IshaDone: isPastCompleted,
            ),
          );
          quarterIndex++;
        }
      }
    }

    // Also generate sample kid plan for "سالم"
    final kidUserId = AppSeedData.initialProfiles[1].userId;
    final kidPlan = MemorizationPlan(
      planId: 'plan-kid-001',
      userId: kidUserId,
      systemType: MemorizationSystemType.ayahRangeSystem,
      name: 'رحلة سالم في بستان القرآن (جزء عم)',
      startDate: startDate,
      targetEndDate: startDate.add(const Duration(days: 90)),
      totalTasks: 30,
      currentStreak: 4,
    );

    _plansSubject.add([..._plansSubject.value, kidPlan]);

    for (int day = 1; day <= 10; day++) {
      final taskDate = startDate.add(Duration(days: day - 1));
      final isDone = day <= 3; // First 3 days completed, Day 4 is today
      initialTasks.add(
        DailyTask(
          taskId: 'task-${kidPlan.planId}-$day',
          planId: kidPlan.planId,
          userId: kidUserId,
          dayNumber: day,
          scheduledDate: taskDate,
          surahNumber: 114 - (day - 1), // An-Nas, Al-Falaq, Al-Ikhlas...
          surahArabicName: day == 1
              ? 'الناس'
              : day == 2
                  ? 'الفلق'
                  : day == 3
                      ? 'الإخلاص'
                      : day == 4
                          ? 'المسد'
                          : 'النصر',
          fromAyah: 1,
          toAyah: day == 1 ? 6 : day == 2 ? 5 : 4,
          portionTitle: 'حفظ سورة مباركة مع سالم',
          isCompleted: isDone,
          completedAt: isDone ? taskDate : null,
          prayer1FajrDone: isDone,
          prayer2DhuhrDone: isDone,
          prayer3AsrDone: isDone,
        ),
      );
    }

    _tasksSubject.add(initialTasks);
  }

  // --- Profile DAO Stream & Operations ---
  Stream<List<UserProfile>> watchProfiles() => _profilesSubject.stream;
  List<UserProfile> get profiles => _profilesSubject.value;

  Stream<UserProfile?> watchActiveProfile() {
    return _profilesSubject.stream.map((list) {
      return list.cast<UserProfile?>().firstWhere(
            (p) => p?.isActive == true,
            orElse: () => list.isNotEmpty ? list.first : null,
          );
    });
  }

  Future<void> switchActiveProfile(String userId) async {
    final list = _profilesSubject.value.map((p) {
      return p.copyWith(isActive: p.userId == userId);
    }).toList();
    _profilesSubject.add(list);
  }

  Future<void> upsertProfile(UserProfile profile) async {
    final list = List<UserProfile>.from(_profilesSubject.value);
    final idx = list.indexWhere((p) => p.userId == profile.userId);
    if (idx >= 0) {
      list[idx] = profile;
    } else {
      list.add(profile);
    }
    _profilesSubject.add(list);
  }

  // --- Plan DAO Stream & Operations ---
  Stream<List<MemorizationPlan>> watchPlansForUser(String userId) {
    return _plansSubject.stream.map((plans) => plans.where((p) => p.userId == userId).toList());
  }

  Future<void> savePlan(MemorizationPlan plan) async {
    final list = List<MemorizationPlan>.from(_plansSubject.value);
    final idx = list.indexWhere((p) => p.planId == plan.planId);
    if (idx >= 0) {
      list[idx] = plan;
    } else {
      list.add(plan);
    }
    _plansSubject.add(list);
  }

  // --- Task DAO Stream & Operations ---
  Stream<List<DailyTask>> watchTasksForPlan(String planId) {
    return _tasksSubject.stream.map((tasks) => tasks.where((t) => t.planId == planId).toList());
  }

  Stream<List<DailyTask>> watchTasksForUser(String userId) {
    return _tasksSubject.stream.map((tasks) => tasks.where((t) => t.userId == userId).toList());
  }

  List<DailyTask> get tasks => _tasksSubject.hasValue ? _tasksSubject.value : [];

  Future<void> updateTask(DailyTask task) async {
    final list = List<DailyTask>.from(_tasksSubject.value);
    final idx = list.indexWhere((t) => t.taskId == task.taskId);
    if (idx >= 0) {
      list[idx] = task;
      _tasksSubject.add(list);
    }
  }

  Future<void> updateTasksBatch(List<DailyTask> updated) async {
    final list = List<DailyTask>.from(_tasksSubject.value);
    for (final task in updated) {
      final idx = list.indexWhere((t) => t.taskId == task.taskId);
      if (idx >= 0) {
        list[idx] = task;
      } else {
        list.add(task);
      }
    }
    _tasksSubject.add(list);
  }

  // --- Mutashabihat DAO ---
  Stream<List<MutashabihaItem>> watchMutashabihat() => _mutashabihatSubject.stream;

  List<MutashabihaItem> getMutashabihatForAyahRange(int surah, int fromAyah, int toAyah) {
    return _mutashabihatSubject.value.where((m) => m.isInRange(surah, fromAyah, toAyah)).toList();
  }

  // --- Parental Rewards DAO ---
  Stream<List<ParentalReward>> watchRewardsForUser(String userId) {
    return _rewardsSubject.stream.map((rewards) => rewards.where((r) => r.userId == userId).toList());
  }

  Future<void> upsertReward(ParentalReward reward) async {
    final list = List<ParentalReward>.from(_rewardsSubject.value);
    final idx = list.indexWhere((r) => r.rewardId == reward.rewardId);
    if (idx >= 0) {
      list[idx] = reward;
    } else {
      list.add(reward);
    }
    _rewardsSubject.add(list);
  }

  Future<void> claimReward(String rewardId) async {
    final list = List<ParentalReward>.from(_rewardsSubject.value);
    final idx = list.indexWhere((r) => r.rewardId == rewardId);
    if (idx >= 0) {
      list[idx] = list[idx].copyWith(isClaimed: true);
      _rewardsSubject.add(list);
    }
  }
}
