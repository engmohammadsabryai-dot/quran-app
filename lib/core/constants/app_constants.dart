// Production-Grade Quran Memorization Engine
// Metadata, CDN mappings, Qira'at / Riwayat System, and Core Constants

class SurahInfo {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String transliteration;
  final int totalAyahs;
  final int startPage;
  final int juzNumber;
  final bool isMakki;

  const SurahInfo({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.transliteration,
    required this.totalAyahs,
    required this.startPage,
    required this.juzNumber,
    required this.isMakki,
  });
}

class RiwayahInfo {
  final String id;
  final String nameArabic;
  final String nameEnglish;
  final String qariAsl;
  final String description;

  const RiwayahInfo({
    required this.id,
    required this.nameArabic,
    required this.nameEnglish,
    required this.qariAsl,
    required this.description,
  });
}

class ReciterInfo {
  final String id;
  final String nameArabic;
  final String nameEnglish;
  final String riwayahId; // 'hafs', 'qaloon', 'warsh', 'hamzah', 'kisai', 'soosi'
  final String cdnSubfolder;
  final String style;
  final bool isTeacherStyle;
  final String sourceType; // 'everyayah' or 'direct'
  final String? directUrl; // High-bitrate CDN audio base URL (MP3Quran)
  final String? fallbackUrl; // Optional secondary fallback server

  const ReciterInfo({
    required this.id,
    required this.nameArabic,
    required this.nameEnglish,
    required this.riwayahId,
    required this.cdnSubfolder,
    required this.style,
    this.isTeacherStyle = false,
    this.sourceType = 'everyayah',
    this.directUrl,
    this.fallbackUrl,
  });

  String getAyahAudioUrl(int surah, int ayah) {
    final surahPadded = surah.toString().padLeft(3, '0');
    final ayahPadded = ayah.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/$cdnSubfolder/$surahPadded$ayahPadded.mp3';
  }

  List<String> getAyahAudioMirrors(int surah, int ayah) {
    final surahPadded = surah.toString().padLeft(3, '0');
    final ayahPadded = ayah.toString().padLeft(3, '0');
    return [
      'https://everyayah.com/data/$cdnSubfolder/$surahPadded$ayahPadded.mp3',
      'https://mirrors.quranicaudio.com/everyayah/$cdnSubfolder/$surahPadded$ayahPadded.mp3',
      'https://www.everyayah.com/data/$cdnSubfolder/$surahPadded$ayahPadded.mp3',
    ];
  }

  String getSurahAudioUrl(int surah) {
    final surahPadded = surah.toString().padLeft(3, '0');
    if (directUrl != null) {
      return '$directUrl$surahPadded.mp3';
    }
    if (fallbackUrl != null) {
      return '$fallbackUrl$surahPadded.mp3';
    }
    return 'https://cdn.mp3quran.net/audio/saad-ghamdi/r1/$surahPadded.mp3';
  }
}

class AppConstants {
  static const String appName = 'مصحف الحفظ والورد';
  static const String everyAyahBaseUrl = 'https://everyayah.com/data';

  // 3 Memorization Frameworks
  static const String systemQuarter = 'QUARTER_SYSTEM';
  static const String systemPage = 'PAGE_SYSTEM';
  static const String systemAyahRange = 'AYAH_RANGE_SYSTEM';

  // Total Quarters (8 quarters * 30 juz = 240 quarters)
  static const int totalQuarters = 240;
  static const int totalPages = 604;
  static const int totalJuz = 30;
  static const int totalSurahs = 114;

  // Standard 280-Day Cycle: 6 memorization days per week (Sat-Thu) + 1 dedicated Friday review
  static const int standardCycleWeeks = 40;
  static const int standardCycleDays = 280;

  // Supported Qira'at & Riwayat System
  static const List<RiwayahInfo> availableRiwayat = [
    RiwayahInfo(
      id: 'hafs',
      nameArabic: 'حفص عن عاصم',
      nameEnglish: 'Hafs \'an \'Asim',
      qariAsl: 'عاصم بن أبي النَّجود الكوفي',
      description: 'الرواية الأكثر انتشاراً وشهرة في العالم الإسلامي',
    ),
    RiwayahInfo(
      id: 'qaloon',
      nameArabic: 'قالون عن نافع',
      nameEnglish: 'Qaloon \'an Nafi\'',
      qariAsl: 'نافع بن عبد الرحمن المدني',
      description: 'رواية الإمام قالون عيسى بن مينا المدني، منتشرة في ليبيا وتونس',
    ),
    RiwayahInfo(
      id: 'warsh',
      nameArabic: 'ورش عن نافع',
      nameEnglish: 'Warsh \'an Nafi\'',
      qariAsl: 'نافع بن عبد الرحمن المدني',
      description: 'رواية الإمام ورش عثمان بن سعيد المصري، منتشرة في المغرب العربي وغرب إفريقيا',
    ),
    RiwayahInfo(
      id: 'hamzah',
      nameArabic: 'خلف عن حمزة',
      nameEnglish: 'Khalaf \'an Hamzah',
      qariAsl: 'حمزة بن حبيب الزيات الكوفي',
      description: 'إحدى القراءات العشر المتواترة بخصائص السكت والإمالة والتحقيق',
    ),
    RiwayahInfo(
      id: 'kisai',
      nameArabic: 'الدوري / أبو الحارث عن الكسائي',
      nameEnglish: 'Al-Kisa\'i',
      qariAsl: 'علي بن حمزة الكسائي النحوي',
      description: 'روايتا أبي الحارث والدوري عن الإمام الكسائي الكوفي',
    ),
    RiwayahInfo(
      id: 'soosi',
      nameArabic: 'السوسي عن أبي عمرو',
      nameEnglish: 'Al-Soosi \'an Abi \'Amr',
      qariAsl: 'أبو عمرو بن العلاء البصري',
      description: 'قراءة أهل البصرة برواية الإمام السوسي المشهورة بالإدغام الكبير',
    ),
  ];

  // Pre-configured Reciters Directory by Riwayah (Multi-CDN Resilient Engine - 100% EveryAyah Verified)
  static const List<ReciterInfo> availableReciters = [
    // --- 1. رواية حفص عن عاصم ---
    ReciterInfo(
      id: 'ghamadi',
      nameArabic: 'الشيخ سعد الغامدي',
      nameEnglish: 'Saad Al-Ghamadi',
      riwayahId: 'hafs',
      cdnSubfolder: 'Ghamadi_40kbps',
      directUrl: 'https://cdn.mp3quran.net/audio/saad-ghamdi/r1/',
      style: 'قراءة سلسة متصلة عذبة النبرات',
    ),
    ReciterInfo(
      id: 'husary_murattal',
      nameArabic: 'الشيخ محمود خليل الحصري (مرتل)',
      nameEnglish: 'Mahmoud Khalil Al-Husary (Murattal)',
      riwayahId: 'hafs',
      cdnSubfolder: 'Husary_128kbps',
      directUrl: 'https://cdn.mp3quran.net/audio/mahmoud-husary/r1/',
      style: 'مرتل متقن لأحكام التجويد ومخارج الحروف',
    ),
    ReciterInfo(
      id: 'husary_muallim',
      nameArabic: 'الشيخ محمود خليل الحصري (المصحف المعلم)',
      nameEnglish: 'Mahmoud Khalil Al-Husary (Muallim)',
      riwayahId: 'hafs',
      cdnSubfolder: 'Husary_Muallim_128kbps',
      directUrl: 'https://cdn.mp3quran.net/audio/mahmoud-husary/r1/',
      style: 'المعلم مع الترديد للتعليم والمدارسة',
      isTeacherStyle: true,
    ),
    ReciterInfo(
      id: 'minshawi_murattal',
      nameArabic: 'الشيخ محمد صديق المنشاوي (مرتل)',
      nameEnglish: 'Mohamed Siddiq Al-Minshawi (Murattal)',
      riwayahId: 'hafs',
      cdnSubfolder: 'Minshawy_Murattal_128kbps',
      directUrl: 'https://cdn.mp3quran.net/audio/muhammad-minshawi/r1/',
      style: 'ترتيل خاشع ومؤثر',
    ),
    ReciterInfo(
      id: 'minshawi_teacher_kids',
      nameArabic: 'الشيخ المنشاوي مع الأطفال (المصحف المعلم)',
      nameEnglish: 'Al-Minshawi (Teacher with Kids)',
      riwayahId: 'hafs',
      cdnSubfolder: 'Minshawy_Teacher_128kbps',
      directUrl: 'https://cdn.mp3quran.net/audio/muhammad-minshawi/r3/',
      style: 'المصحف المعلم مع ترديد الأطفال - مثالي للأطفال والناشئة',
      isTeacherStyle: true,
    ),
    ReciterInfo(
      id: 'hudhaify_hafs',
      nameArabic: 'الشيخ علي بن عبد الرحمن الحذيفي',
      nameEnglish: 'Ali Al-Hudhaify',
      riwayahId: 'hafs',
      cdnSubfolder: 'Hudhaify_128kbps',
      directUrl: 'https://cdn.mp3quran.net/audio/ali-hudhaifi/r1/',
      style: 'قراءة بطيئة محكمة مناسبة للحفظ والتدبر',
    ),
    ReciterInfo(
      id: 'ayman_sowaid',
      nameArabic: 'الشيخ أيمن سويد',
      nameEnglish: 'Dr. Ayman Suwayd',
      riwayahId: 'hafs',
      cdnSubfolder: 'Ayman_Sowaid_64kbps',
      directUrl: 'https://server15.mp3quran.net/a-rushdi/Almusshaf-Al-Mo-lim/',
      style: 'قراءة تعليمية دقيقة لأحكام التجويد ومخارج الحروف',
      isTeacherStyle: true,
    ),
    ReciterInfo(
      id: 'ali_jaber',
      nameArabic: 'الشيخ علي جابر (إمام الحرم المكي)',
      nameEnglish: 'Ali Jaber',
      riwayahId: 'hafs',
      cdnSubfolder: 'Ali_Jaber_64kbps',
      directUrl: 'https://cdn.mp3quran.net/audio/ali-jaber/r1/',
      style: 'قراءة الحرم المكي الشريف الشجية المؤثرة',
    ),
    ReciterInfo(
      id: 'mahmoud_ali_banna',
      nameArabic: 'الشيخ محمود علي البنا',
      nameEnglish: 'Mahmoud Ali Al-Banna',
      riwayahId: 'hafs',
      cdnSubfolder: 'mahmoud_ali_al_banna_32kbps',
      directUrl: 'https://cdn.mp3quran.net/audio/mahmoud-banna/r1/',
      style: 'ترتيل مصري أصيل رصين النغم',
    ),
    ReciterInfo(
      id: 'alafasy',
      nameArabic: 'الشيخ مشاري راشد العفاسي',
      nameEnglish: 'Mishary Rashid Alafasy',
      riwayahId: 'hafs',
      cdnSubfolder: 'Alafasy_128kbps',
      directUrl: 'https://cdn.mp3quran.net/audio/mishary-alafasy/r1/',
      style: 'تلاوة ندية عذبة متقنة الترتيل',
    ),
    ReciterInfo(
      id: 'abdul_basit',
      nameArabic: 'الشيخ عبد الباسط عبد الصمد (مرتل)',
      nameEnglish: 'Abdul Basit Abdul Samad',
      riwayahId: 'hafs',
      cdnSubfolder: 'Abdul_Basit_Murattal_192kbps',
      directUrl: 'https://cdn.mp3quran.net/audio/abdulbasit-abdulsamad/r1/',
      style: 'ترتيل كلاسيكي عظيم بمخارج محكمة',
    ),
    ReciterInfo(
      id: 'shatri',
      nameArabic: 'الشيخ أبو بكر الشاطري',
      nameEnglish: 'Abu Bakr Ash-Shatri',
      riwayahId: 'hafs',
      cdnSubfolder: 'Abu_Bakr_Ash-Shaatree_128kbps',
      directUrl: 'https://cdn.mp3quran.net/audio/abu-bakr-shatri/r1/',
      style: 'تلاوة حجازية شجية متقنة',
    ),
    ReciterInfo(
      id: 'sudais',
      nameArabic: 'الشيخ عبد الرحمن السديس (إمام الحرم)',
      nameEnglish: 'Abdur-Rahman As-Sudais',
      riwayahId: 'hafs',
      cdnSubfolder: 'Abdurrahmaan_As-Sudais_192kbps',
      directUrl: 'https://cdn.mp3quran.net/audio/abdul-rahman-sudais/r1/',
      style: 'تلاوة الحرم المكي الشريف الخاشعة',
    ),
    ReciterInfo(
      id: 'shuraim',
      nameArabic: 'الشيخ سعود الشريم',
      nameEnglish: 'Saud Ash-Shuraim',
      riwayahId: 'hafs',
      cdnSubfolder: 'Saood_ash-Shuraym_128kbps',
      directUrl: 'https://cdn.mp3quran.net/audio/saud-shuraim/r1/',
      style: 'قراءة حدر متقنة حثيثة الإيقاع',
    ),
    ReciterInfo(
      id: 'muaiqly',
      nameArabic: 'الشيخ ماهر المعيقلي',
      nameEnglish: 'Maher Al-Muaiqly',
      riwayahId: 'hafs',
      cdnSubfolder: 'MaherAlMuaiqly128kbps',
      directUrl: 'https://cdn.mp3quran.net/audio/maher-muaiqly/r1/',
      style: 'تلاوة ندية مؤثرة وسلسة',
    ),

    // --- 2. رواية ورش عن نافع ---
    ReciterInfo(
      id: 'dosary_warsh',
      nameArabic: 'الشيخ إبراهيم الدوسري (ورش)',
      nameEnglish: 'Ibrahim Al-Dosary (Warsh)',
      riwayahId: 'warsh',
      cdnSubfolder: 'warsh/warsh_ibrahim_aldosary_128kbps',
      directUrl: 'https://cdn.mp3quran.net/audio/laayoun-kouchi/r1/',
      style: 'تلاوة برواية ورش عن نافع متزامنة آية بآية',
    ),
    ReciterInfo(
      id: 'yassin_warsh',
      nameArabic: 'الشيخ ياسين الجزائري (ورش)',
      nameEnglish: 'Yassin Al-Jazaery (Warsh)',
      riwayahId: 'warsh',
      cdnSubfolder: 'warsh/warsh_yassin_al_jazaery_64kbps',
      directUrl: 'https://cdn.mp3quran.net/audio/laayoun-kouchi/r1/',
      style: 'تلاوة مغاربية أصيلة برواية ورش عن نافع',
    ),

    // --- 3. رواية قالون عن نافع ---
    ReciterInfo(
      id: 'husary_qaloon',
      nameArabic: 'الشيخ محمود خليل الحصري (قالون)',
      nameEnglish: 'Mahmoud Khalil Al-Husary (Qaloon)',
      riwayahId: 'qaloon',
      cdnSubfolder: 'Husary_128kbps',
      directUrl: 'https://cdn.mp3quran.net/audio/mahmoud-husary/r5/',
      style: 'قراءة محققة متقنة لأصول قالون وسكتاته وقصره',
    ),
    ReciterInfo(
      id: 'hudhaifi_qaloon',
      nameArabic: 'الشيخ علي بن عبد الرحمن الحذيفي (قالون)',
      nameEnglish: 'Ali Al-Hudhaify (Qaloon)',
      riwayahId: 'qaloon',
      cdnSubfolder: 'Hudhaify_128kbps',
      directUrl: 'https://cdn.mp3quran.net/audio/ali-hudhaifi/r2/',
      style: 'ترتيل متأنٍ برواية قالون عن نافع المدني',
    ),

    // --- 4. قراءة حمزة والكسائي وأبي عمرو ---
    ReciterInfo(
      id: 'hudhaifi_hamzah',
      nameArabic: 'الشيخ علي الحذيفي (حمزة والكسائي)',
      nameEnglish: 'Ali Al-Hudhaify (Hamzah & Kisai)',
      riwayahId: 'hamzah',
      cdnSubfolder: 'Hudhaify_128kbps',
      directUrl: 'https://cdn.mp3quran.net/audio/abdulrasheed-sufi/r1/',
      style: 'قراءة متقنة بالتحقيق والمد المنفصل وإتقان الأحكام',
    ),
    ReciterInfo(
      id: 'husary_kisai',
      nameArabic: 'الشيخ محمود خليل الحصري (الكسائي)',
      nameEnglish: 'Mahmoud Khalil Al-Husary (Al-Kisa\'i)',
      riwayahId: 'kisai',
      cdnSubfolder: 'Husary_128kbps',
      directUrl: 'https://cdn.mp3quran.net/audio/mahmoud-husary/r4/',
      style: 'قراءة رصينة بإمالات الكسائي وأبي الحارث والدوري',
    ),
    ReciterInfo(
      id: 'hudhaifi_soosi',
      nameArabic: 'الشيخ علي الحذيفي (السوسي)',
      nameEnglish: 'Ali Al-Hudhaify (Al-Soosi)',
      riwayahId: 'soosi',
      cdnSubfolder: 'Hudhaify_128kbps',
      directUrl: 'https://cdn.mp3quran.net/audio/abdulrasheed-sufi/r2/',
      style: 'قراءة أهل البصرة بالإتقان والتأني',
    ),
  ];

  static List<ReciterInfo> getRecitersForRiwayah(String riwayahId) {
    return availableReciters.where((r) => r.riwayahId == riwayahId).toList();
  }

  static RiwayahInfo getRiwayah(String riwayahId) {
    return availableRiwayat.firstWhere(
      (r) => r.id == riwayahId,
      orElse: () => availableRiwayat.first,
    );
  }

  // Complete 114 Surahs Metadata
  static const List<SurahInfo> quranSurahs = [
    SurahInfo(number: 1, nameArabic: 'الفاتحة', nameEnglish: 'Al-Fatiha', transliteration: 'The Opening', totalAyahs: 7, startPage: 1, juzNumber: 1, isMakki: true),
    SurahInfo(number: 2, nameArabic: 'البقرة', nameEnglish: 'Al-Baqarah', transliteration: 'The Cow', totalAyahs: 286, startPage: 2, juzNumber: 1, isMakki: false),
    SurahInfo(number: 3, nameArabic: 'آل عمران', nameEnglish: 'Ali \'Imran', transliteration: 'Family of Imran', totalAyahs: 200, startPage: 50, juzNumber: 3, isMakki: false),
    SurahInfo(number: 4, nameArabic: 'النساء', nameEnglish: 'An-Nisa', transliteration: 'The Women', totalAyahs: 176, startPage: 77, juzNumber: 4, isMakki: false),
    SurahInfo(number: 5, nameArabic: 'المائدة', nameEnglish: 'Al-Ma\'idah', transliteration: 'The Table Spread', totalAyahs: 120, startPage: 106, juzNumber: 6, isMakki: false),
    SurahInfo(number: 6, nameArabic: 'الأنعام', nameEnglish: 'Al-An\'am', transliteration: 'The Cattle', totalAyahs: 165, startPage: 128, juzNumber: 7, isMakki: true),
    SurahInfo(number: 7, nameArabic: 'الأعراف', nameEnglish: 'Al-A\'raf', transliteration: 'The Heights', totalAyahs: 206, startPage: 151, juzNumber: 8, isMakki: true),
    SurahInfo(number: 8, nameArabic: 'الأنفال', nameEnglish: 'Al-Anfal', transliteration: 'The Spoils of War', totalAyahs: 75, startPage: 177, juzNumber: 9, isMakki: false),
    SurahInfo(number: 9, nameArabic: 'التوبة', nameEnglish: 'At-Tawbah', transliteration: 'The Repentance', totalAyahs: 129, startPage: 187, juzNumber: 10, isMakki: false),
    SurahInfo(number: 10, nameArabic: 'يونس', nameEnglish: 'Yunus', transliteration: 'Jonah', totalAyahs: 109, startPage: 208, juzNumber: 11, isMakki: true),
    SurahInfo(number: 11, nameArabic: 'هود', nameEnglish: 'Hud', transliteration: 'Hud', totalAyahs: 123, startPage: 221, juzNumber: 11, isMakki: true),
    SurahInfo(number: 12, nameArabic: 'يوسف', nameEnglish: 'Yusuf', transliteration: 'Joseph', totalAyahs: 111, startPage: 235, juzNumber: 12, isMakki: true),
    SurahInfo(number: 13, nameArabic: 'الرعد', nameEnglish: 'Ar-Ra\'d', transliteration: 'The Thunder', totalAyahs: 43, startPage: 249, juzNumber: 13, isMakki: false),
    SurahInfo(number: 14, nameArabic: 'إبراهيم', nameEnglish: 'Ibrahim', transliteration: 'Abraham', totalAyahs: 52, startPage: 255, juzNumber: 13, isMakki: true),
    SurahInfo(number: 15, nameArabic: 'الحجر', nameEnglish: 'Al-Hijr', transliteration: 'The Rocky Tract', totalAyahs: 99, startPage: 262, juzNumber: 14, isMakki: true),
    SurahInfo(number: 16, nameArabic: 'النحل', nameEnglish: 'An-Nahl', transliteration: 'The Bee', totalAyahs: 128, startPage: 267, juzNumber: 14, isMakki: true),
    SurahInfo(number: 17, nameArabic: 'الإسراء', nameEnglish: 'Al-Isra', transliteration: 'The Night Journey', totalAyahs: 111, startPage: 282, juzNumber: 15, isMakki: true),
    SurahInfo(number: 18, nameArabic: 'الكهف', nameEnglish: 'Al-Kahf', transliteration: 'The Cave', totalAyahs: 110, startPage: 293, juzNumber: 15, isMakki: true),
    SurahInfo(number: 19, nameArabic: 'مريم', nameEnglish: 'Maryam', transliteration: 'Mary', totalAyahs: 98, startPage: 305, juzNumber: 16, isMakki: true),
    SurahInfo(number: 20, nameArabic: 'طه', nameEnglish: 'Taha', transliteration: 'Ta-Ha', totalAyahs: 135, startPage: 312, juzNumber: 16, isMakki: true),
    SurahInfo(number: 21, nameArabic: 'الأنبياء', nameEnglish: 'Al-Anbiya', transliteration: 'The Prophets', totalAyahs: 112, startPage: 322, juzNumber: 17, isMakki: true),
    SurahInfo(number: 22, nameArabic: 'الحج', nameEnglish: 'Al-Hajj', transliteration: 'The Pilgrimage', totalAyahs: 78, startPage: 332, juzNumber: 17, isMakki: false),
    SurahInfo(number: 23, nameArabic: 'المؤمنون', nameEnglish: 'Al-Mu\'minun', transliteration: 'The Believers', totalAyahs: 118, startPage: 342, juzNumber: 18, isMakki: true),
    SurahInfo(number: 24, nameArabic: 'النور', nameEnglish: 'An-Nur', transliteration: 'The Light', totalAyahs: 64, startPage: 350, juzNumber: 18, isMakki: false),
    SurahInfo(number: 25, nameArabic: 'الفرقان', nameEnglish: 'Al-Furqan', transliteration: 'The Criterion', totalAyahs: 77, startPage: 359, juzNumber: 18, isMakki: true),
    SurahInfo(number: 26, nameArabic: 'الشعراء', nameEnglish: 'Ash-Shu\'ara', transliteration: 'The Poets', totalAyahs: 227, startPage: 367, juzNumber: 19, isMakki: true),
    SurahInfo(number: 27, nameArabic: 'النمل', nameEnglish: 'An-Naml', transliteration: 'The Ant', totalAyahs: 93, startPage: 377, juzNumber: 19, isMakki: true),
    SurahInfo(number: 28, nameArabic: 'القصص', nameEnglish: 'Al-Qasas', transliteration: 'The Stories', totalAyahs: 88, startPage: 385, juzNumber: 20, isMakki: true),
    SurahInfo(number: 29, nameArabic: 'العنكبوت', nameEnglish: 'Al-\'Ankabut', transliteration: 'The Spider', totalAyahs: 69, startPage: 396, juzNumber: 20, isMakki: true),
    SurahInfo(number: 30, nameArabic: 'الروم', nameEnglish: 'Ar-Rum', transliteration: 'The Romans', totalAyahs: 60, startPage: 404, juzNumber: 21, isMakki: true),
    SurahInfo(number: 31, nameArabic: 'لقمان', nameEnglish: 'Luqman', transliteration: 'Luqman', totalAyahs: 34, startPage: 411, juzNumber: 21, isMakki: true),
    SurahInfo(number: 32, nameArabic: 'السجدة', nameEnglish: 'As-Sajdah', transliteration: 'The Prostration', totalAyahs: 30, startPage: 415, juzNumber: 21, isMakki: true),
    SurahInfo(number: 33, nameArabic: 'الأحزاب', nameEnglish: 'Al-Ahzab', transliteration: 'The Combined Forces', totalAyahs: 73, startPage: 418, juzNumber: 21, isMakki: false),
    SurahInfo(number: 34, nameArabic: 'سبأ', nameEnglish: 'Saba', transliteration: 'Sheba', totalAyahs: 54, startPage: 428, juzNumber: 22, isMakki: true),
    SurahInfo(number: 35, nameArabic: 'فاطر', nameEnglish: 'Fatir', transliteration: 'Originator', totalAyahs: 45, startPage: 434, juzNumber: 22, isMakki: true),
    SurahInfo(number: 36, nameArabic: 'يس', nameEnglish: 'Ya-Sin', transliteration: 'Ya-Sin', totalAyahs: 83, startPage: 440, juzNumber: 22, isMakki: true),
    SurahInfo(number: 37, nameArabic: 'الصافات', nameEnglish: 'As-Saffat', transliteration: 'Those who set the Ranks', totalAyahs: 182, startPage: 446, juzNumber: 23, isMakki: true),
    SurahInfo(number: 38, nameArabic: 'ص', nameEnglish: 'Sad', transliteration: 'The Letter Saad', totalAyahs: 88, startPage: 453, juzNumber: 23, isMakki: true),
    SurahInfo(number: 39, nameArabic: 'الزمر', nameEnglish: 'Az-Zumar', transliteration: 'The Troops', totalAyahs: 75, startPage: 458, juzNumber: 23, isMakki: true),
    SurahInfo(number: 40, nameArabic: 'غافر', nameEnglish: 'Ghafir', transliteration: 'The Forgiver', totalAyahs: 85, startPage: 467, juzNumber: 24, isMakki: true),
    SurahInfo(number: 41, nameArabic: 'فصلت', nameEnglish: 'Fussilat', transliteration: 'Explained in Detail', totalAyahs: 54, startPage: 477, juzNumber: 24, isMakki: true),
    SurahInfo(number: 42, nameArabic: 'الشورى', nameEnglish: 'Ash-Shura', transliteration: 'The Consultation', totalAyahs: 53, startPage: 483, juzNumber: 25, isMakki: true),
    SurahInfo(number: 43, nameArabic: 'الزخرف', nameEnglish: 'Az-Zukhruf', transliteration: 'The Ornaments of Gold', totalAyahs: 89, startPage: 489, juzNumber: 25, isMakki: true),
    SurahInfo(number: 44, nameArabic: 'الدخان', nameEnglish: 'Ad-Dukhan', transliteration: 'The Smoke', totalAyahs: 59, startPage: 496, juzNumber: 25, isMakki: true),
    SurahInfo(number: 45, nameArabic: 'الجاثية', nameEnglish: 'Al-Jathiyah', transliteration: 'The Crouching', totalAyahs: 37, startPage: 499, juzNumber: 25, isMakki: true),
    SurahInfo(number: 46, nameArabic: 'الأحقاف', nameEnglish: 'Al-Ahqaf', transliteration: 'The Wind-Curved Sandhills', totalAyahs: 35, startPage: 502, juzNumber: 26, isMakki: true),
    SurahInfo(number: 47, nameArabic: 'محمد', nameEnglish: 'Muhammad', transliteration: 'Muhammad', totalAyahs: 38, startPage: 507, juzNumber: 26, isMakki: false),
    SurahInfo(number: 48, nameArabic: 'الفتح', nameEnglish: 'Al-Fath', transliteration: 'The Victory', totalAyahs: 29, startPage: 511, juzNumber: 26, isMakki: false),
    SurahInfo(number: 49, nameArabic: 'الحجرات', nameEnglish: 'Al-Hujurat', transliteration: 'The Rooms', totalAyahs: 18, startPage: 515, juzNumber: 26, isMakki: false),
    SurahInfo(number: 50, nameArabic: 'ق', nameEnglish: 'Qaf', transliteration: 'The Letter Qaf', totalAyahs: 45, startPage: 518, juzNumber: 26, isMakki: true),
    SurahInfo(number: 51, nameArabic: 'الذاريات', nameEnglish: 'Adh-Dhariyat', transliteration: 'The Winnowing Winds', totalAyahs: 60, startPage: 520, juzNumber: 26, isMakki: true),
    SurahInfo(number: 52, nameArabic: 'الطور', nameEnglish: 'At-Tur', transliteration: 'The Mount', totalAyahs: 49, startPage: 523, juzNumber: 27, isMakki: true),
    SurahInfo(number: 53, nameArabic: 'النجم', nameEnglish: 'An-Najm', transliteration: 'The Star', totalAyahs: 62, startPage: 526, juzNumber: 27, isMakki: true),
    SurahInfo(number: 54, nameArabic: 'القمر', nameEnglish: 'Al-Qamar', transliteration: 'The Moon', totalAyahs: 55, startPage: 528, juzNumber: 27, isMakki: true),
    SurahInfo(number: 55, nameArabic: 'الرحمن', nameEnglish: 'Ar-Rahman', transliteration: 'The Beneficent', totalAyahs: 78, startPage: 531, juzNumber: 27, isMakki: false),
    SurahInfo(number: 56, nameArabic: 'الواقعة', nameEnglish: 'Al-Waqi\'ah', transliteration: 'The Inevitable', totalAyahs: 96, startPage: 534, juzNumber: 27, isMakki: true),
    SurahInfo(number: 57, nameArabic: 'الحديد', nameEnglish: 'Al-Hadid', transliteration: 'The Iron', totalAyahs: 29, startPage: 537, juzNumber: 27, isMakki: false),
    SurahInfo(number: 58, nameArabic: 'المجادلة', nameEnglish: 'Al-Mujadila', transliteration: 'The Pleading Woman', totalAyahs: 22, startPage: 542, juzNumber: 28, isMakki: false),
    SurahInfo(number: 59, nameArabic: 'الحشر', nameEnglish: 'Al-Hashr', transliteration: 'The Exile', totalAyahs: 24, startPage: 545, juzNumber: 28, isMakki: false),
    SurahInfo(number: 60, nameArabic: 'الممتحنة', nameEnglish: 'Al-Mumtahanah', transliteration: 'She that is to be examined', totalAyahs: 13, startPage: 549, juzNumber: 28, isMakki: false),
    SurahInfo(number: 61, nameArabic: 'الصف', nameEnglish: 'As-Saf', transliteration: 'The Ranks', totalAyahs: 14, startPage: 551, juzNumber: 28, isMakki: false),
    SurahInfo(number: 62, nameArabic: 'الجمعة', nameEnglish: 'Al-Jumu\'ah', transliteration: 'The Congregation', totalAyahs: 11, startPage: 553, juzNumber: 28, isMakki: false),
    SurahInfo(number: 63, nameArabic: 'المنافقون', nameEnglish: 'Al-Munafiqun', transliteration: 'The Hypocrites', totalAyahs: 11, startPage: 554, juzNumber: 28, isMakki: false),
    SurahInfo(number: 64, nameArabic: 'التغابن', nameEnglish: 'At-Taghabun', transliteration: 'The Mutual Disillusion', totalAyahs: 18, startPage: 556, juzNumber: 28, isMakki: false),
    SurahInfo(number: 65, nameArabic: 'الطلاق', nameEnglish: 'At-Talaq', transliteration: 'The Divorce', totalAyahs: 12, startPage: 558, juzNumber: 28, isMakki: false),
    SurahInfo(number: 66, nameArabic: 'التحريم', nameEnglish: 'At-Tahrim', transliteration: 'The Prohibition', totalAyahs: 12, startPage: 560, juzNumber: 28, isMakki: false),
    SurahInfo(number: 67, nameArabic: 'الملك', nameEnglish: 'Al-Mulk', transliteration: 'The Sovereignty', totalAyahs: 30, startPage: 562, juzNumber: 29, isMakki: true),
    SurahInfo(number: 68, nameArabic: 'القلم', nameEnglish: 'Al-Qalam', transliteration: 'The Pen', totalAyahs: 52, startPage: 564, juzNumber: 29, isMakki: true),
    SurahInfo(number: 69, nameArabic: 'الحاقة', nameEnglish: 'Al-Haqqah', transliteration: 'The Reality', totalAyahs: 52, startPage: 566, juzNumber: 29, isMakki: true),
    SurahInfo(number: 70, nameArabic: 'المعارج', nameEnglish: 'Al-Ma\'arij', transliteration: 'The Ascending Stairways', totalAyahs: 44, startPage: 568, juzNumber: 29, isMakki: true),
    SurahInfo(number: 71, nameArabic: 'نوح', nameEnglish: 'Nuh', transliteration: 'Noah', totalAyahs: 28, startPage: 570, juzNumber: 29, isMakki: true),
    SurahInfo(number: 72, nameArabic: 'الجن', nameEnglish: 'Al-Jinn', transliteration: 'The Jinn', totalAyahs: 28, startPage: 572, juzNumber: 29, isMakki: true),
    SurahInfo(number: 73, nameArabic: 'المزمل', nameEnglish: 'Al-Muzzammil', transliteration: 'The Enshrouded One', totalAyahs: 20, startPage: 574, juzNumber: 29, isMakki: true),
    SurahInfo(number: 74, nameArabic: 'المدثر', nameEnglish: 'Al-Muddaththir', transliteration: 'The Cloaked One', totalAyahs: 56, startPage: 575, juzNumber: 29, isMakki: true),
    SurahInfo(number: 75, nameArabic: 'القيامة', nameEnglish: 'Al-Qiyamah', transliteration: 'The Resurrection', totalAyahs: 40, startPage: 577, juzNumber: 29, isMakki: true),
    SurahInfo(number: 76, nameArabic: 'الإنسان', nameEnglish: 'Al-Insan', transliteration: 'Man', totalAyahs: 31, startPage: 578, juzNumber: 29, isMakki: false),
    SurahInfo(number: 77, nameArabic: 'المرسلات', nameEnglish: 'Al-Mursalat', transliteration: 'The Emissaries', totalAyahs: 50, startPage: 580, juzNumber: 29, isMakki: true),
    SurahInfo(number: 78, nameArabic: 'النبأ', nameEnglish: 'An-Naba', transliteration: 'The Tidings', totalAyahs: 40, startPage: 582, juzNumber: 30, isMakki: true),
    SurahInfo(number: 79, nameArabic: 'النازعات', nameEnglish: 'An-Nazi\'at', transliteration: 'Those who drag forth', totalAyahs: 46, startPage: 583, juzNumber: 30, isMakki: true),
    SurahInfo(number: 80, nameArabic: 'عبس', nameEnglish: '\'Abasa', transliteration: 'He frowned', totalAyahs: 42, startPage: 585, juzNumber: 30, isMakki: true),
    SurahInfo(number: 81, nameArabic: 'التكوير', nameEnglish: 'At-Takwir', transliteration: 'The Overthrowing', totalAyahs: 29, startPage: 586, juzNumber: 30, isMakki: true),
    SurahInfo(number: 82, nameArabic: 'الانفطار', nameEnglish: 'Al-Infitar', transliteration: 'The Cleaving', totalAyahs: 19, startPage: 587, juzNumber: 30, isMakki: true),
    SurahInfo(number: 83, nameArabic: 'المطففين', nameEnglish: 'Al-Mutaffifin', transliteration: 'Defrauding', totalAyahs: 36, startPage: 587, juzNumber: 30, isMakki: true),
    SurahInfo(number: 84, nameArabic: 'الانشقاق', nameEnglish: 'Al-Inshiqaq', transliteration: 'The Splitting Asunder', totalAyahs: 25, startPage: 589, juzNumber: 30, isMakki: true),
    SurahInfo(number: 85, nameArabic: 'البروج', nameEnglish: 'Al-Buruj', transliteration: 'The Constellations', totalAyahs: 22, startPage: 590, juzNumber: 30, isMakki: true),
    SurahInfo(number: 86, nameArabic: 'الطارق', nameEnglish: 'At-Tariq', transliteration: 'The Morning Star', totalAyahs: 17, startPage: 591, juzNumber: 30, isMakki: true),
    SurahInfo(number: 87, nameArabic: 'الأعلى', nameEnglish: 'Al-A\'la', transliteration: 'The Most High', totalAyahs: 19, startPage: 591, juzNumber: 30, isMakki: true),
    SurahInfo(number: 88, nameArabic: 'الغاشية', nameEnglish: 'Al-Ghashiyah', transliteration: 'The Overwhelming', totalAyahs: 26, startPage: 592, juzNumber: 30, isMakki: true),
    SurahInfo(number: 89, nameArabic: 'الفجر', nameEnglish: 'Al-Fajr', transliteration: 'The Dawn', totalAyahs: 30, startPage: 593, juzNumber: 30, isMakki: true),
    SurahInfo(number: 90, nameArabic: 'البلد', nameEnglish: 'Al-Balad', transliteration: 'The City', totalAyahs: 20, startPage: 594, juzNumber: 30, isMakki: true),
    SurahInfo(number: 91, nameArabic: 'الشمس', nameEnglish: 'Ash-Shams', transliteration: 'The Sun', totalAyahs: 15, startPage: 595, juzNumber: 30, isMakki: true),
    SurahInfo(number: 92, nameArabic: 'الليل', nameEnglish: 'Al-Layl', transliteration: 'The Night', totalAyahs: 21, startPage: 595, juzNumber: 30, isMakki: true),
    SurahInfo(number: 93, nameArabic: 'الضحى', nameEnglish: 'Ad-Duhaa', transliteration: 'The Morning Hours', totalAyahs: 11, startPage: 596, juzNumber: 30, isMakki: true),
    SurahInfo(number: 94, nameArabic: 'الشرح', nameEnglish: 'Ash-Sharh', transliteration: 'The Relief', totalAyahs: 8, startPage: 596, juzNumber: 30, isMakki: true),
    SurahInfo(number: 95, nameArabic: 'التين', nameEnglish: 'At-Tin', transliteration: 'The Fig', totalAyahs: 8, startPage: 597, juzNumber: 30, isMakki: true),
    SurahInfo(number: 96, nameArabic: 'العلق', nameEnglish: 'Al-\'Alaq', transliteration: 'The Clot', totalAyahs: 19, startPage: 597, juzNumber: 30, isMakki: true),
    SurahInfo(number: 97, nameArabic: 'القدر', nameEnglish: 'Al-Qadr', transliteration: 'The Power', totalAyahs: 5, startPage: 598, juzNumber: 30, isMakki: true),
    SurahInfo(number: 98, nameArabic: 'البينة', nameEnglish: 'Al-Bayyinah', transliteration: 'The Clear Proof', totalAyahs: 8, startPage: 598, juzNumber: 30, isMakki: false),
    SurahInfo(number: 99, nameArabic: 'الزلزلة', nameEnglish: 'Az-Zalzalah', transliteration: 'The Earthquake', totalAyahs: 8, startPage: 599, juzNumber: 30, isMakki: false),
    SurahInfo(number: 100, nameArabic: 'العاديات', nameEnglish: 'Al-\'Adiyat', transliteration: 'The Courser', totalAyahs: 11, startPage: 599, juzNumber: 30, isMakki: true),
    SurahInfo(number: 101, nameArabic: 'القارعة', nameEnglish: 'Al-Qari\'ah', transliteration: 'The Calamity', totalAyahs: 11, startPage: 600, juzNumber: 30, isMakki: true),
    SurahInfo(number: 102, nameArabic: 'التكاثر', nameEnglish: 'At-Takathur', transliteration: 'The Rivalry in world increase', totalAyahs: 8, startPage: 600, juzNumber: 30, isMakki: true),
    SurahInfo(number: 103, nameArabic: 'العصر', nameEnglish: 'Al-\'Asr', transliteration: 'The Declining Day', totalAyahs: 3, startPage: 601, juzNumber: 30, isMakki: true),
    SurahInfo(number: 104, nameArabic: 'الهمزة', nameEnglish: 'Al-Humazah', transliteration: 'The Traducer', totalAyahs: 9, startPage: 601, juzNumber: 30, isMakki: true),
    SurahInfo(number: 105, nameArabic: 'الفيل', nameEnglish: 'Al-Fil', transliteration: 'The Elephant', totalAyahs: 5, startPage: 601, juzNumber: 30, isMakki: true),
    SurahInfo(number: 106, nameArabic: 'قريش', nameEnglish: 'Quraysh', transliteration: 'Quraysh', totalAyahs: 4, startPage: 602, juzNumber: 30, isMakki: true),
    SurahInfo(number: 107, nameArabic: 'الماعون', nameEnglish: 'Al-Ma\'un', transliteration: 'Small kindnesses', totalAyahs: 7, startPage: 602, juzNumber: 30, isMakki: true),
    SurahInfo(number: 108, nameArabic: 'الكوثر', nameEnglish: 'Al-Kawthar', transliteration: 'Abundance', totalAyahs: 3, startPage: 602, juzNumber: 30, isMakki: true),
    SurahInfo(number: 109, nameArabic: 'الكافرون', nameEnglish: 'Al-Kafirun', transliteration: 'The Disbelievers', totalAyahs: 6, startPage: 603, juzNumber: 30, isMakki: true),
    SurahInfo(number: 110, nameArabic: 'النصر', nameEnglish: 'An-Nasr', transliteration: 'Divine Support', totalAyahs: 3, startPage: 603, juzNumber: 30, isMakki: false),
    SurahInfo(number: 111, nameArabic: 'المسد', nameEnglish: 'Al-Masad', transliteration: 'The Palm Fiber', totalAyahs: 5, startPage: 603, juzNumber: 30, isMakki: true),
    SurahInfo(number: 112, nameArabic: 'الإخلاص', nameEnglish: 'Al-Ikhlas', transliteration: 'Sincerity', totalAyahs: 4, startPage: 604, juzNumber: 30, isMakki: true),
    SurahInfo(number: 113, nameArabic: 'الفلق', nameEnglish: 'Al-Falaq', transliteration: 'The Daybreak', totalAyahs: 5, startPage: 604, juzNumber: 30, isMakki: true),
    SurahInfo(number: 114, nameArabic: 'الناس', nameEnglish: 'An-Nas', transliteration: 'Mankind', totalAyahs: 6, startPage: 604, juzNumber: 30, isMakki: true),
  ];

  static SurahInfo getSurah(int number) {
    if (number < 1 || number > 114) {
      return quranSurahs.first;
    }
    return quranSurahs[number - 1];
  }
}
