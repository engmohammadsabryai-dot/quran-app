import '../../../domain/models/mutashabiha_item.dart';
import '../../../domain/models/user_profile.dart';
import '../../../domain/models/parental_reward.dart';

class SeedQuarterData {
  final int quarterIndex; // 1 to 240
  final int juzNumber; // 1 to 30
  final int hizbNumber; // 1 to 60
  final int quarterOfHizb; // 1 to 4
  final int surahNumber;
  final String surahArabicName;
  final int fromAyah;
  final int toAyah;
  final int pageNumber;
  final String firstWords;

  const SeedQuarterData({
    required this.quarterIndex,
    required this.juzNumber,
    required this.hizbNumber,
    required this.quarterOfHizb,
    required this.surahNumber,
    required this.surahArabicName,
    required this.fromAyah,
    required this.toAyah,
    required this.pageNumber,
    required this.firstWords,
  });
}

class AppSeedData {
  // Initial Profiles for Dual-UI demonstration
  static final List<UserProfile> initialProfiles = [
    UserProfile(
      userId: 'usr-adult-001',
      name: 'عبد الرحمن الصالح',
      age: 28,
      gender: 'male',
      avatarId: 'adult_avatar_1',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    UserProfile(
      userId: 'usr-kid-001',
      name: 'سالم الشجاع',
      age: 9, // Trigger Kids Mode (< 15)
      gender: 'male',
      avatarId: 'kid_salem',
      isActive: false,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    UserProfile(
      userId: 'usr-kid-002',
      name: 'سارة الزكية',
      age: 11, // Trigger Kids Mode (< 15)
      gender: 'female',
      avatarId: 'kid_sarah',
      isActive: false,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  // Initial Parental Rewards
  static final List<ParentalReward> initialRewards = [
    ParentalReward(
      rewardId: 'rew-001',
      userId: 'usr-kid-001',
      title: 'مجموعة تركيب روبوت أو ليغو',
      description: 'مكافأة إتقان حفظ أول ٨ أرباع متتالية بدون أي تأخير',
      targetQuarterMilestone: 8,
      targetStreakMilestone: 7,
      isUnlocked: true,
      isClaimed: false,
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
    ParentalReward(
      rewardId: 'rew-002',
      userId: 'usr-kid-001',
      title: 'رحلة عائلية إلى مدينة الملاهي الترفيهية',
      description: 'عند إتمام حفظ الحزب الثاني كاملاً (١٦ ربعاً)',
      targetQuarterMilestone: 16,
      targetStreakMilestone: 14,
      isUnlocked: false,
      isClaimed: false,
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
    ParentalReward(
      rewardId: 'rew-003',
      userId: 'usr-kid-001',
      title: 'دراجة هوائية رياضية جديدة + حفل تكريم',
      description: 'مكافأة إتمام حفظ الجزء الأول كاملاً مع الوالدين',
      targetQuarterMilestone: 24,
      targetStreakMilestone: 21,
      isUnlocked: false,
      isClaimed: false,
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
  ];

  // Comprehensive Mutashabihat relations with Mnemonic anchors (قاعدة الضبط والربط)
  static const List<MutashabihaItem> mutashabihatCatalog = [
    MutashabihaItem(
      id: 1,
      surah1: 2,
      surah1Name: 'البقرة',
      ayah1: 48,
      text1: 'وَاتَّقُوا يَوْمًا لَّا تَجْزِي نَفْسٌ عَن نَّفْسٍ شَيْئًا وَلَا يُقْبَلُ مِنْهَا شَفَاعَةٌ وَلَا يُؤْخَذُ مِنْهَا عَدْلٌ وَلَا هُمْ يُنصَرُونَ',
      surah2: 2,
      surah2Name: 'البقرة',
      ayah2: 123,
      text2: 'وَاتَّقُوا يَوْمًا لَّا تَجْزِي نَفْسٌ عَن نَّفْسٍ شَيْئًا وَلَا يُقْبَلُ مِنْهَا عَدْلٌ وَلَا تَنفَعُهَا شَفَاعَةٌ وَلَا هُمْ يُنصَرُونَ',
      ruleMnemonic: 'قاعدة الترتيب الهجائي والأسبقية: في الموضع الأول (٤٨) قُدِّمت الشفاعة لأن الشين تسبق العين في الذكر، وتأخرت في الموضع الثاني (١٢٣)؛ ومع الشفاعة في الأول: (يُقْبَلُ) بالتذكير، وفي الثاني: (تَنفَعُهَا) بالتأنيث.',
      differenceHighlight: 'الموضع الأول: (وَلَا يُقْبَلُ مِنْهَا شَفَاعَةٌ وَلَا يُؤْخَذُ مِنْهَا عَدْلٌ) ⟷ الموضع الثاني: (وَلَا يُقْبَلُ مِنْهَا عَدْلٌ وَلَا تَنفَعُهَا شَفَاعَةٌ)',
      category: 'تقديم وتأخير وإبدال فعل',
    ),
    MutashabihaItem(
      id: 2,
      surah1: 2,
      surah1Name: 'البقرة',
      ayah1: 61,
      text1: 'ذَٰلِكَ بِأَنَّهُمْ كَانُوا يَكْفُرُونَ بِآيَاتِ اللَّهِ وَيَقْتُلُونَ النَّبِيِّينَ بِغَيْرِ الْحَقِّ',
      surah2: 3,
      surah2Name: 'آل عمران',
      ayah2: 112,
      text2: 'ذَٰلِكَ بِأَنَّهُمْ كَانُوا يَكْفُرُونَ بِآيَاتِ اللَّهِ وَيَقْتُلُونَ الْأَنبِيَاءَ بِغَيْرِ حَقٍّ',
      ruleMnemonic: 'قاعدة توافق الحروف: (الأنبياء) و (بغير حق) في آل عمران بدأت بهمزة في الأنبياء وتنكير حق، بينما في البقرة جمع مذكر سالم (النبيين) وتعريف (الحق). اضبطها بعبارة: "أنبياء آل عمران بغير حق".',
      differenceHighlight: 'البقرة: (النَّبِيِّينَ بِغَيْرِ الْحَقِّ) ⟷ آل عمران: (الْأَنبِيَاءَ بِغَيْرِ حَقٍّ)',
      category: 'جمع وإفراد وتعريف',
    ),
    MutashabihaItem(
      id: 3,
      surah1: 2,
      surah1Name: 'البقرة',
      ayah1: 126,
      text1: 'وَإِذْ قَالَ إِبْرَاهِيمُ رَبِّ اجْعَلْ هَٰذَا بَلَدًا آمِنًا وَارْزُقْ أَهْلَهُ مِنَ الثَّمَرَاتِ',
      surah2: 14,
      surah2Name: 'إبراهيم',
      ayah2: 35,
      text2: 'وَإِذْ قَالَ إِبْرَاهِيمُ رَبِّ اجْعَلْ هَٰذَا الْبَلَدَ آمِنًا وَاجْنُبْنِي وَبَنِيَّ أَن نَّعْبُدَ الْأَصْنَامَ',
      ruleMnemonic: 'قاعدة السياق الزمني: في سورة البقرة كان دعاء إبراهيم عند بناء البيت الحرام قبل أن تكون مكة بلداً مأهولاً فجاءت نكرة (بَلَدًا آمِنًا)، وفي سورة إبراهيم كان الدعاء بعدما سكنت وصارت بلداً معروفاً فجاءت معرفة (الْبَلَدَ آمِنًا).',
      differenceHighlight: 'البقرة: (بَلَدًا آمِنًا) [تنكير] ⟷ إبراهيم: (هَٰذَا الْبَلَدَ آمِنًا) [تعريف]',
      category: 'التعريف والتنكير',
    ),
    MutashabihaItem(
      id: 4,
      surah1: 4,
      surah1Name: 'النساء',
      ayah1: 135,
      text1: 'يَا أَيُّهَا الَّذِينَ آمَنُوا كُونُوا قَوَّامِينَ بِالْقِسْطِ شُهَدَاءَ لِلَّهِ وَلَوْ عَلَىٰ أَنفُسِكُمْ',
      surah2: 5,
      surah2Name: 'المائدة',
      ayah2: 8,
      text2: 'يَا أَيُّهَا الَّذِينَ آمَنُوا كُونُوا قَوَّامِينَ لِلَّهِ شُهَدَاءَ بِالْقِسْطِ وَلَا يَجْرِمَنَّكُمْ شَنَآنُ قَوْمٍ',
      ruleMnemonic: 'قاعدة مقصد السورة: سورة النساء محورها القسط والعدل في المواريث واليتامى والنساء فبُدئ بـ (بِالْقِسْطِ شُهَدَاءَ لِلَّهِ)، أما سورة المائدة فسورة العهود والوفاء مع الله فبُدئ بـ (لِلَّهِ شُهَدَاءَ بِالْقِسْطِ).',
      differenceHighlight: 'النساء: (قَوَّامِينَ بِالْقِسْطِ شُهَدَاءَ لِلَّهِ) ⟷ المائدة: (قَوَّامِينَ لِلَّهِ شُهَدَاءَ بِالْقِسْطِ)',
      category: 'تقديم وتأخير مراعاة للمقصد',
    ),
    MutashabihaItem(
      id: 5,
      surah1: 6,
      surah1Name: 'الأنعام',
      ayah1: 151,
      text1: 'وَلَا تَقْتُلُوا أَوْلَادَكُم مِّنْ إِمْلَاقٍ نَّحْنُ نَرْزُقُكُمْ وَإِيَّاهُمْ',
      surah2: 17,
      surah2Name: 'الإسراء',
      ayah2: 31,
      text2: 'وَلَا تَقْتُلُوا أَوْلَادَكُمْ خَشْيَةَ إِمْلَاقٍ نَّحْنُ نَرْزُقُهُمْ وَإِيَّاكُمْ إِنَّ قَتْلَهُمْ كَانَ خِطْئًا كَبِيرًا',
      ruleMnemonic: 'قاعدة علة النهي: في الأنعام الفقر حاصل وموجود (مِّنْ إِمْلَاقٍ) فرُزق المخاطبون أولاً (نَّرْزُقُكُمْ وَإِيَّاهُمْ)، وفي الإسراء الفقر متوقع في المستقبل بدافع الخوف (خَشْيَةَ إِمْلَاقٍ) فرُزق الأبناء أولاً (نَّرْزُقُهُمْ وَإِيَّاكُمْ).',
      differenceHighlight: 'الأنعام: (مِّنْ إِمْلَاقٍ نَّحْنُ نَرْزُقُكُمْ وَإِيَّاهُمْ) ⟷ الإسراء: (خَشْيَةَ إِمْلَاقٍ نَّحْنُ نَرْزُقُهُمْ وَإِيَّاكُمْ)',
      category: 'تقديم الضمير بحسب الحال',
    ),
    MutashabihaItem(
      id: 6,
      surah1: 3,
      surah1Name: 'آل عمران',
      ayah1: 133,
      text1: 'وَسَارِعُوا إِلَىٰ مَغْفِرَةٍ مِّن رَّبِّكُمْ وَجَنَّةٍ عَرْضُهَا السَّمَاوَاتُ وَالْأَرْضُ أُعِدَّتْ لِلْمُتَّقِينَ',
      surah2: 57,
      surah2Name: 'الحديد',
      ayah2: 21,
      text2: 'سَابِقُوا إِلَىٰ مَغْفِرَةٍ مِّن رَّبِّكُمْ وَجَنَّةٍ عَرْضُهَا كَعَرْضِ السَّمَاءِ وَالْأَرْضِ أُعِدَّتْ لِلَّذِينَ آمَنُوا بِاللَّهِ وَرُسُلِهِ',
      ruleMnemonic: 'قاعدة الزيادة في الموضع الأطول: في آل عمران (وَسَارِعُوا) بالواو وبدون كاف التشبيه (عَرْضُهَا السَّمَاوَاتُ)، وفي الحديد بدون واو ومع كاف التشبيه (سَابِقُوا .. كَعَرْضِ السَّمَاءِ).',
      differenceHighlight: 'آل عمران: (وَسَارِعُوا .. عَرْضُهَا السَّمَاوَاتُ) ⟷ الحديد: (سَابِقُوا .. كَعَرْضِ السَّمَاءِ)',
      category: 'زيادة حرف وتشبيه',
    ),
  ];

  // Pre-seeded Quarter Data for Juz 1 & 2 as high-fidelity foundation,
  // supplemented by an algorithmic generator for all 240 quarters.
  static List<SeedQuarterData> generateAll240Quarters() {
    final List<SeedQuarterData> list = [];

    // Realistic mapping of initial quarters
    final firstQuarters = [
      // Juz 1
      const SeedQuarterData(quarterIndex: 1, juzNumber: 1, hizbNumber: 1, quarterOfHizb: 1, surahNumber: 1, surahArabicName: 'الفاتحة', fromAyah: 1, toAyah: 7, pageNumber: 1, firstWords: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ'),
      const SeedQuarterData(quarterIndex: 2, juzNumber: 1, hizbNumber: 1, quarterOfHizb: 2, surahNumber: 2, surahArabicName: 'البقرة', fromAyah: 1, toAyah: 25, pageNumber: 2, firstWords: 'الم ذَٰلِكَ الْكِتَابُ لَا رَيْبَ فِيهِ'),
      const SeedQuarterData(quarterIndex: 3, juzNumber: 1, hizbNumber: 1, quarterOfHizb: 3, surahNumber: 2, surahArabicName: 'البقرة', fromAyah: 26, toAyah: 43, pageNumber: 5, firstWords: 'إِنَّ اللَّهَ لَا يَسْتَحْيِي أَن يَضْرِبَ مَثَلًا'),
      const SeedQuarterData(quarterIndex: 4, juzNumber: 1, hizbNumber: 1, quarterOfHizb: 4, surahNumber: 2, surahArabicName: 'البقرة', fromAyah: 44, toAyah: 59, pageNumber: 7, firstWords: 'أَتَأْمُرُونَ النَّاسَ بِالْبِرِّ وَتَنسَوْنَ أَنفُسَكُمْ'),
      const SeedQuarterData(quarterIndex: 5, juzNumber: 1, hizbNumber: 2, quarterOfHizb: 1, surahNumber: 2, surahArabicName: 'البقرة', fromAyah: 60, toAyah: 74, pageNumber: 9, firstWords: 'وَإِذِ اسْتَسْقَىٰ مُوسَىٰ لِقَوْمِهِ'),
      const SeedQuarterData(quarterIndex: 6, juzNumber: 1, hizbNumber: 2, quarterOfHizb: 2, surahNumber: 2, surahArabicName: 'البقرة', fromAyah: 75, toAyah: 91, pageNumber: 11, firstWords: 'أَفَتَطْمَعُونَ أَن يُؤْمِنُوا لَكُمْ'),
      const SeedQuarterData(quarterIndex: 7, juzNumber: 1, hizbNumber: 2, quarterOfHizb: 3, surahNumber: 2, surahArabicName: 'البقرة', fromAyah: 92, toAyah: 105, pageNumber: 14, firstWords: 'وَلَقَدْ جَاءَكُم مُّوسَىٰ بِالْبَيِّنَاتِ'),
      const SeedQuarterData(quarterIndex: 8, juzNumber: 1, hizbNumber: 2, quarterOfHizb: 4, surahNumber: 2, surahArabicName: 'البقرة', fromAyah: 106, toAyah: 123, pageNumber: 17, firstWords: 'مَا نَنسَخْ مِنْ آيَةٍ أَوْ نُنسِهَا'),
      // Juz 2
      const SeedQuarterData(quarterIndex: 9, juzNumber: 2, hizbNumber: 3, quarterOfHizb: 1, surahNumber: 2, surahArabicName: 'البقرة', fromAyah: 142, toAyah: 157, pageNumber: 22, firstWords: 'سَيَقُولُ السُّفَهَاءُ مِنَ النَّاسِ'),
      const SeedQuarterData(quarterIndex: 10, juzNumber: 2, hizbNumber: 3, quarterOfHizb: 2, surahNumber: 2, surahArabicName: 'البقرة', fromAyah: 158, toAyah: 176, pageNumber: 24, firstWords: 'إِنَّ الصَّفَا وَالْمَرْوَةَ مِن شَعَائِرِ اللَّهِ'),
      const SeedQuarterData(quarterIndex: 11, juzNumber: 2, hizbNumber: 3, quarterOfHizb: 3, surahNumber: 2, surahArabicName: 'البقرة', fromAyah: 177, toAyah: 188, pageNumber: 27, firstWords: 'لَّيْسَ الْبِرَّ أَن تُوَلُّوا وُجُوهَكُمْ'),
      const SeedQuarterData(quarterIndex: 12, juzNumber: 2, hizbNumber: 3, quarterOfHizb: 4, surahNumber: 2, surahArabicName: 'البقرة', fromAyah: 189, toAyah: 202, pageNumber: 29, firstWords: 'يَسْأَلُونَكَ عَنِ الْأَهِلَّةِ'),
      const SeedQuarterData(quarterIndex: 13, juzNumber: 2, hizbNumber: 4, quarterOfHizb: 1, surahNumber: 2, surahArabicName: 'البقرة', fromAyah: 203, toAyah: 218, pageNumber: 32, firstWords: 'وَاذْكُرُوا اللَّهَ فِي أَيَّامٍ مَّعْدُودَاتٍ'),
      const SeedQuarterData(quarterIndex: 14, juzNumber: 2, hizbNumber: 4, quarterOfHizb: 2, surahNumber: 2, surahArabicName: 'البقرة', fromAyah: 219, toAyah: 232, pageNumber: 34, firstWords: 'يَسْأَلُونَكَ عَنِ الْخَمْرِ وَالْمَيْسِرِ'),
      const SeedQuarterData(quarterIndex: 15, juzNumber: 2, hizbNumber: 4, quarterOfHizb: 3, surahNumber: 2, surahArabicName: 'البقرة', fromAyah: 233, toAyah: 242, pageNumber: 37, firstWords: 'وَالْوَالِدَاتُ يُرْضِعْنَ أَوْلَادَهُنَّ'),
      const SeedQuarterData(quarterIndex: 16, juzNumber: 2, hizbNumber: 4, quarterOfHizb: 4, surahNumber: 2, surahArabicName: 'البقرة', fromAyah: 243, toAyah: 252, pageNumber: 39, firstWords: 'أَلَمْ تَرَ إِلَى الَّذِينَ خَرَجُوا مِن دِيَارِهِمْ'),
    ];

    list.addAll(firstQuarters);

    // Seed remaining quarters up to 240 smoothly
    for (int q = 17; q <= 240; q++) {
      final juz = ((q - 1) ~/ 8) + 1;
      final hizb = ((q - 1) ~/ 4) + 1;
      final qOfHizb = ((q - 1) % 4) + 1;
      final approxPage = (q * 2.5).round().clamp(41, 604);

      // Approximate surah mapping based on juz
      int surahNum = 2;
      String surahName = 'البقرة';
      if (juz >= 3 && juz <= 4) {
        surahNum = 3;
        surahName = 'آل عمران';
      } else if (juz >= 4 && juz <= 6) {
        surahNum = 4;
        surahName = 'النساء';
      } else if (juz >= 6 && juz <= 7) {
        surahNum = 5;
        surahName = 'المائدة';
      } else if (juz >= 7 && juz <= 8) {
        surahNum = 6;
        surahName = 'الأنعام';
      } else if (juz >= 8 && juz <= 9) {
        surahNum = 7;
        surahName = 'الأعراف';
      } else if (juz >= 9 && juz <= 10) {
        surahNum = 9;
        surahName = 'التوبة';
      } else if (juz >= 11 && juz <= 12) {
        surahNum = 11;
        surahName = 'هود';
      } else if (juz >= 12 && juz <= 13) {
        surahNum = 12;
        surahName = 'يوسف';
      } else if (juz >= 14 && juz <= 15) {
        surahNum = 16;
        surahName = 'النحل';
      } else if (juz >= 15 && juz <= 16) {
        surahNum = 18;
        surahName = 'الكهف';
      } else if (juz >= 17 && juz <= 18) {
        surahNum = 21;
        surahName = 'الأنبياء';
      } else if (juz >= 19 && juz <= 20) {
        surahNum = 26;
        surahName = 'الشعراء';
      } else if (juz >= 21 && juz <= 22) {
        surahNum = 33;
        surahName = 'الأحزاب';
      } else if (juz >= 23 && juz <= 24) {
        surahNum = 39;
        surahName = 'الزمر';
      } else if (juz >= 25 && juz <= 26) {
        surahNum = 45;
        surahName = 'الجاثية';
      } else if (juz >= 27 && juz <= 28) {
        surahNum = 55;
        surahName = 'الرحمن';
      } else if (juz == 29) {
        surahNum = 67;
        surahName = 'الملك';
      } else {
        surahNum = 78;
        surahName = 'النبأ';
      }

      final startA = ((qOfHizb - 1) * 20) + 1;
      final endA = startA + 19;

      list.add(
        SeedQuarterData(
          quarterIndex: q,
          juzNumber: juz,
          hizbNumber: hizb,
          quarterOfHizb: qOfHizb,
          surahNumber: surahNum,
          surahArabicName: surahName,
          fromAyah: startA,
          toAyah: endA,
          pageNumber: approxPage,
          firstWords: 'الربع $qOfHizb من الحزب $hizb (الجزء $juz)',
        ),
      );
    }

    return list;
  }
}
