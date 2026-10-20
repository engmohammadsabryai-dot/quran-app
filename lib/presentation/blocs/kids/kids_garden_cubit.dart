import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum MascotEmotion {
  happy,
  excited,
  proud,
  thinking,
  celebrating,
}

class BubbleQuizQuestion extends Equatable {
  final String prompt;
  final String missingWord;
  final List<String> bubbleOptions;
  final String fullAyah;
  final String surahName;

  const BubbleQuizQuestion({
    required this.prompt,
    required this.missingWord,
    required this.bubbleOptions,
    required this.fullAyah,
    required this.surahName,
  });

  @override
  List<Object?> get props => [prompt, missingWord, bubbleOptions, fullAyah, surahName];
}

class KidsGardenState extends Equatable {
  final int gardenStage; // 1 to 5
  final int waterDropsEarned;
  final int starsCollected;
  final String mascotName; // 'سالم' or 'سارة'
  final MascotEmotion mascotEmotion;
  final String mascotSpeechText;
  final int quizScore;
  final int currentQuestionIndex;
  final List<BubbleQuizQuestion> questions;
  final bool isQuizActive;

  const KidsGardenState({
    this.gardenStage = 1,
    this.waterDropsEarned = 3,
    this.starsCollected = 12,
    this.mascotName = 'سالم',
    this.mascotEmotion = MascotEmotion.happy,
    this.mascotSpeechText = 'أهلاً بك يا بطل القرآن! هيا نسقي شجرة القرآن معاً بإنجاز ورد اليوم! 🌱',
    this.quizScore = 0,
    this.currentQuestionIndex = 0,
    this.questions = const [],
    this.isQuizActive = false,
  });

  String get stageTitle {
    switch (gardenStage) {
      case 1:
        return 'المرحلة ١: البذرة المباركة في التربة الطيبة 🌱';
      case 2:
        return 'المرحلة ٢: البرعم الأخضر اليافع 🌿';
      case 3:
        return 'المرحلة ٣: الغرسة النامية المتأصلة 🪴';
      case 4:
        return 'المرحلة ٤: الشجرة المزهرة العاطرة 🌸';
      case 5:
      default:
        return 'المرحلة ٥: شجرة القرآن الذهبية المثمرة 🌳✨';
    }
  }

  KidsGardenState copyWith({
    int? gardenStage,
    int? waterDropsEarned,
    int? starsCollected,
    String? mascotName,
    MascotEmotion? mascotEmotion,
    String? mascotSpeechText,
    int? quizScore,
    int? currentQuestionIndex,
    List<BubbleQuizQuestion>? questions,
    bool? isQuizActive,
  }) {
    return KidsGardenState(
      gardenStage: gardenStage ?? this.gardenStage,
      waterDropsEarned: waterDropsEarned ?? this.waterDropsEarned,
      starsCollected: starsCollected ?? this.starsCollected,
      mascotName: mascotName ?? this.mascotName,
      mascotEmotion: mascotEmotion ?? this.mascotEmotion,
      mascotSpeechText: mascotSpeechText ?? this.mascotSpeechText,
      quizScore: quizScore ?? this.quizScore,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      questions: questions ?? this.questions,
      isQuizActive: isQuizActive ?? this.isQuizActive,
    );
  }

  @override
  List<Object?> get props => [
        gardenStage,
        waterDropsEarned,
        starsCollected,
        mascotName,
        mascotEmotion,
        mascotSpeechText,
        quizScore,
        currentQuestionIndex,
        questions,
        isQuizActive,
      ];
}

class KidsGardenCubit extends Cubit<KidsGardenState> {
  KidsGardenCubit()
      : super(
          KidsGardenState(
            questions: _sampleQuizQuestions,
          ),
        );

  static const List<BubbleQuizQuestion> _sampleQuizQuestions = [
    BubbleQuizQuestion(
      prompt: 'قُلْ أَعُوذُ بِرَبِّ ....... (سورة الفلق)',
      missingWord: 'الْفَلَقِ',
      bubbleOptions: ['الْفَلَقِ', 'النَّاسِ', 'الصَّمَدِ', 'الْكَوْثَرِ'],
      fullAyah: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
      surahName: 'الفلق',
    ),
    BubbleQuizQuestion(
      prompt: 'مِن شَرِّ الْوَسْوَاسِ ....... (سورة الناس)',
      missingWord: 'الْخَنَّاسِ',
      bubbleOptions: ['الْخَنَّاسِ', 'الْعَظِيمِ', 'الرَّحِيمِ', 'الْمُبِينِ'],
      fullAyah: 'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ',
      surahName: 'الناس',
    ),
    BubbleQuizQuestion(
      prompt: 'اللَّهُ الصَّمَدُ * لَمْ يَلِدْ وَلَمْ ....... (سورة الإخلاص)',
      missingWord: 'يُولَدْ',
      bubbleOptions: ['يُولَدْ', 'يَعْلَمْ', 'يَكُن', 'يَمُتْ'],
      fullAyah: 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
      surahName: 'الإخلاص',
    ),
  ];

  void setMascotName(String name) {
    final cleanName = name.trim().isEmpty ? 'بطل القرآن' : name.trim();
    final isGirl = cleanName == 'عائشة' || cleanName == 'مريم' || cleanName == 'سارة';
    final greeting = isGirl
        ? 'أهلاً بكِ يا $cleanName يا بطلة القرآن! هيا نسقي شجرة القرآن معاً بإنجاز ورد اليوم! 🌸'
        : 'أهلاً بك يا $cleanName يا بطل القرآن! هيا نسقي شجرة القرآن معاً بإنجاز ورد اليوم! 🌱';
    emit(state.copyWith(mascotName: cleanName, mascotSpeechText: greeting));
  }

  void updateStageFromCompletedCount(int completedTasks) {
    // 5 Stages based on tasks/quarters completed:
    // 0-2 -> Stage 1 (Seed)
    // 3-5 -> Stage 2 (Sprout)
    // 6-9 -> Stage 3 (Sapling)
    // 10-14 -> Stage 4 (Blooming)
    // 15+ -> Stage 5 (Golden Fruitful Tree)
    int stage = 1;
    if (completedTasks >= 15) {
      stage = 5;
    } else if (completedTasks >= 10) {
      stage = 4;
    } else if (completedTasks >= 6) {
      stage = 3;
    } else if (completedTasks >= 3) {
      stage = 2;
    }

    String cheer = state.mascotSpeechText;
    MascotEmotion emotion = state.mascotEmotion;

    if (stage > state.gardenStage) {
      cheer = 'ما شاء الله تبارك الله! 🎉 شجرة القرآن كبرت معك درجة جديدة بفضل حفظك المتقن!';
      emotion = MascotEmotion.celebrating;
    }

    emit(state.copyWith(
      gardenStage: stage,
      mascotEmotion: emotion,
      mascotSpeechText: cheer,
    ));
  }

  void waterTree() {
    final nextDrops = state.waterDropsEarned + 1;
    final nextStars = state.starsCollected + 5;
    emit(state.copyWith(
      waterDropsEarned: nextDrops,
      starsCollected: nextStars,
      mascotEmotion: MascotEmotion.excited,
      mascotSpeechText: 'أحسنت يا بطل! 💧 سَقَيْتَ شجرة القرآن بقطرات النور والبركة!',
    ));
  }

  void onTaskCompletedCheer(String portion) {
    emit(state.copyWith(
      starsCollected: state.starsCollected + 10,
      waterDropsEarned: state.waterDropsEarned + 1,
      mascotEmotion: MascotEmotion.celebrating,
      mascotSpeechText: 'يا للروعة! 🌟 أكملت $portion! أنت تملأ بستانك ثماراً نضرة!',
    ));
  }

  void startQuiz() {
    emit(state.copyWith(
      isQuizActive: true,
      currentQuestionIndex: 0,
      quizScore: 0,
      mascotEmotion: MascotEmotion.thinking,
      mascotSpeechText: 'هيا نتحدى الفقاعات! فرقع الفقاعة التي تحتوي على الكلمة الصحيحة! 🫧',
    ));
  }

  bool answerBubbleQuestion(String chosenWord) {
    final currentQ = state.questions[state.currentQuestionIndex];
    final isCorrect = chosenWord == currentQ.missingWord;

    if (isCorrect) {
      final newScore = state.quizScore + 10;
      final nextIndex = state.currentQuestionIndex + 1;
      final isFinished = nextIndex >= state.questions.length;

      emit(state.copyWith(
        quizScore: newScore,
        starsCollected: state.starsCollected + 5,
        currentQuestionIndex: isFinished ? 0 : nextIndex,
        isQuizActive: !isFinished,
        mascotEmotion: isFinished ? MascotEmotion.celebrating : MascotEmotion.excited,
        mascotSpeechText: isFinished
            ? 'مذهل جداً! 🎉 أجبت عن كل الأسئلة بنجاح وحصلت على النجوم الذهبية!'
            : 'إجابة صحيحة وفرقعة موفقة! 🌟 هيا للسؤال التالي!',
      ));
      return true;
    } else {
      emit(state.copyWith(
        mascotEmotion: MascotEmotion.thinking,
        mascotSpeechText: 'قريب جداً! حاول مرة أخرى وفرقع الفقاعة الصحيحة يا بطل! 💪',
      ));
      return false;
    }
  }

  void closeQuiz() {
    emit(state.copyWith(isQuizActive: false));
  }
}
