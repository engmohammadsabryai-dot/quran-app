import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:audio_service/audio_service.dart';

import 'core/audio/hybrid_audio_player_service.dart';
import 'core/audio/quran_audio_handler.dart';
import 'core/network/dio_client.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/local/database.dart';
import 'data/datasources/local/quran_text_data.dart';
import 'data/datasources/secure/secure_storage_service.dart';
import 'data/repositories/mutashabihat_repository_impl.dart';
import 'data/repositories/parental_reward_repository_impl.dart';
import 'data/repositories/plan_repository_impl.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'data/repositories/task_repository_impl.dart';
import 'presentation/blocs/audio/audio_cubit.dart';
import 'presentation/blocs/kids/kids_garden_cubit.dart';
import 'presentation/blocs/mutashabihat/mutashabihat_cubit.dart';
import 'presentation/blocs/plan/plan_bloc.dart';
import 'presentation/blocs/profile/profile_bloc.dart';
import 'presentation/blocs/profile/profile_event.dart';
import 'presentation/views/adaptive_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 0. Initialize Full Uthmanic Quran Dataset (6,236 Verses)
  await QuranTextData.initialize();

  // 1. Core Services Setup
  final networkClient = NetworkClient();
  final secureStorage = SecureStorageService();
  final database = AppDatabase.instance;

  // 2. Audio Engine Setup & Background Playback Handler
  final hybridAudioService = HybridAudioPlayerService(networkClient: networkClient);
  try {
    final audioHandler = await AudioService.init(
      builder: () => QuranAudioHandler(hybridAudioService.player),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.quran.memorization.mushaf.audio',
        androidNotificationChannelName: 'تلاوة القرآن الكريم',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
    hybridAudioService.attachAudioHandler(audioHandler);
  } catch (e) {
    debugPrint('⚠️ AudioService background handler notice: $e');
  }

  // 3. Repositories
  final profileRepository = ProfileRepositoryImpl(db: database, secureStorage: secureStorage);
  final planRepository = PlanRepositoryImpl(db: database);
  final taskRepository = TaskRepositoryImpl(db: database);
  final mutashabihatRepository = MutashabihatRepositoryImpl(db: database);
  final parentalRewardRepository = ParentalRewardRepositoryImpl(db: database);

  runApp(
    QuranAppRoot(
      profileRepository: profileRepository,
      planRepository: planRepository,
      taskRepository: taskRepository,
      mutashabihatRepository: mutashabihatRepository,
      parentalRewardRepository: parentalRewardRepository,
      audioService: hybridAudioService,
    ),
  );
}

class QuranAppRoot extends StatelessWidget {
  final ProfileRepositoryImpl profileRepository;
  final PlanRepositoryImpl planRepository;
  final TaskRepositoryImpl taskRepository;
  final MutashabihatRepositoryImpl mutashabihatRepository;
  final ParentalRewardRepositoryImpl parentalRewardRepository;
  final HybridAudioPlayerService audioService;

  const QuranAppRoot({
    super.key,
    required this.profileRepository,
    required this.planRepository,
    required this.taskRepository,
    required this.mutashabihatRepository,
    required this.parentalRewardRepository,
    required this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileBloc>(
          create: (_) => ProfileBloc(profileRepository: profileRepository)..add(const LoadProfilesEvent()),
        ),
        BlocProvider<PlanBloc>(
          create: (_) => PlanBloc(
            planRepository: planRepository,
            taskRepository: taskRepository,
          ),
        ),
        BlocProvider<AudioCubit>(
          create: (_) => AudioCubit(audioService: audioService),
        ),
        BlocProvider<KidsGardenCubit>(
          create: (_) => KidsGardenCubit(),
        ),
        BlocProvider<MutashabihatCubit>(
          create: (_) => MutashabihatCubit(repository: mutashabihatRepository),
        ),
      ],
      child: MaterialApp(
        title: 'مصحف الحفظ والورد',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.adultTheme(),
        locale: const Locale('ar'),
        supportedLocales: const [
          Locale('ar'),
          Locale('en'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          // Force Right-to-Left Arabic directionality across the app
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const AdaptiveHomeScreen(),
      ),
    );
  }
}
