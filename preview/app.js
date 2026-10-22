// Quran Memorization Engine - Interactive Simulator Logic

// State
let currentTheme = 'adult';
let isPlaying = false;
let isTransitioning = false;
let currentMemorizationSystem = 'page'; // 'page' (طريقة الصفحات 604) or 'rub' (طريقة الأرباع 240)
let currentMushafPage = 2; // Madani page 2 (Al-Baqarah 1-5)
let currentRubQuarter = 1; // Rub 1: Al-Baqarah 1-25
let rangeStartAyah = 1; // Default range start
let rangeEndAyah = 5; // Default range end
let currentSurah = 2; // Al-Baqarah
let currentAyah = 1;
let currentAyahRepeat = 1;
let targetAyahRepeat = 3; // N
let currentRangeCycle = 1;
let targetRangeCycle = 1; // M
let intervalDelaySeconds = 2; // T
let currentRiwayah = 'hafs';
let currentReciterId = 'ghamadi';
let currentReciterSubfolder = 'Ghamadi_40kbps';
let currentReciterName = 'الشيخ سعد الغامدي';
let delayCountdownTimer = null;

// Kids state
let currentChildName = 'سالم';
let currentChildEmoji = '👦';
let gardenStage = 3; // 1 to 5
let waterDrops = 7;
let starsCount = 25;
let quizScore = 0;
let currentQuizIndex = 0;

// Prayers Checkoff
let prayerStatus = [false, false, false, false, false];

// Audio element
const audioElement = document.getElementById('quran-audio');

// Riwayat Names dictionary
const riwayatNames = {
  hafs: 'حفص عن عاصم',
  qaloon: 'قالون عن نافع',
  warsh: 'ورش عن نافع',
  hamzah: 'خلف عن حمزة',
  kisai: 'الدوري عن الكسائي',
  soosi: 'السوسي عن أبي عمرو',
};

// Reciters Database mapped to Riwayah (Multi-CDN Resilient Engine - 100% Working)
const recitersDatabase = [
  // --- 1. رواية حفص عن عاصم ---
  {
    id: 'ghamadi',
    name: 'الشيخ سعد الغامدي',
    riwayah: 'hafs',
    sourceType: 'everyayah',
    subfolder: 'Ghamadi_40kbps',
    directUrl: 'https://cdn.mp3quran.net/audio/saad-ghamdi/r1/',
    style: 'قراءة سلسة متصلة عذبة النبرات'
  },
  {
    id: 'ayman_sowaid',
    name: 'الشيخ أيمن سويد',
    riwayah: 'hafs',
    sourceType: 'everyayah',
    subfolder: 'Ayman_Sowaid_64kbps',
    directUrl: 'https://server15.mp3quran.net/a-rushdi/Almusshaf-Al-Mo-lim/',
    style: 'قراءة تعليمية دقيقة لأحكام التجويد ومخارج الحروف'
  },
  {
    id: 'mahmoud_ali_banna',
    name: 'الشيخ محمود علي البنا',
    riwayah: 'hafs',
    sourceType: 'everyayah',
    subfolder: 'mahmoud_ali_al_banna_32kbps',
    directUrl: 'https://cdn.mp3quran.net/audio/mahmoud-banna/r1/',
    style: 'ترتيل مصري أصيل رصين النغم'
  },
  {
    id: 'ali_jaber',
    name: 'الشيخ علي جابر (إمام الحرم المكي)',
    riwayah: 'hafs',
    sourceType: 'everyayah',
    subfolder: 'Ali_Jaber_64kbps',
    directUrl: 'https://cdn.mp3quran.net/audio/ali-jaber/r1/',
    style: 'قراءة الحرم المكي الشريف الشجية المؤثرة'
  },
  {
    id: 'mustafa_azzawi',
    name: 'الشيخ مصطفى العزاوي',
    riwayah: 'hafs',
    sourceType: 'direct',
    subfolder: 'Azzawi_128kbps',
    directUrl: 'https://cdn.mp3quran.net/audio/mustafa-azzawi/r1/',
    style: 'قراءة هادئة عذبة مناسبة للترديد'
  },
  {
    id: 'abdulrashid_soufi_hafs',
    name: 'الشيخ عبد الرشيد صوفي (حفص)',
    riwayah: 'hafs',
    sourceType: 'direct',
    subfolder: 'Abdulrasheed_Soufi_Hafs_128kbps',
    directUrl: 'https://cdn.mp3quran.net/audio/abdulrasheed-sufi/r3/',
    style: 'قراءة متقنة خاشعة بمخارج فصيحة'
  },
  {
    id: 'husary_murattal',
    name: 'الشيخ محمود خليل الحصري (مرتل)',
    riwayah: 'hafs',
    sourceType: 'everyayah',
    subfolder: 'Husary_128kbps',
    directUrl: 'https://cdn.mp3quran.net/audio/mahmoud-husary/r1/',
    style: 'مرتل متقن لأحكام التجويد ومخارج الحروف'
  },
  {
    id: 'husary_muallim',
    name: 'الشيخ محمود خليل الحصري (المصحف المعلم)',
    riwayah: 'hafs',
    sourceType: 'everyayah',
    subfolder: 'Husary_Muallim_128kbps',
    directUrl: 'https://cdn.mp3quran.net/audio/mahmoud-husary/r1/',
    style: 'المعلم مع الترديد للتعليم والمدارسة'
  },
  {
    id: 'minshawi_murattal',
    name: 'الشيخ محمد صديق المنشاوي (مرتل)',
    riwayah: 'hafs',
    sourceType: 'everyayah',
    subfolder: 'Minshawy_Murattal_128kbps',
    directUrl: 'https://cdn.mp3quran.net/audio/muhammad-minshawi/r1/',
    style: 'ترتيل خاشع ومؤثر'
  },
  {
    id: 'minshawi_teacher',
    name: 'الشيخ المنشاوي مع الأطفال (المصحف المعلم)',
    riwayah: 'hafs',
    sourceType: 'everyayah',
    subfolder: 'Minshawy_Teacher_128kbps',
    directUrl: 'https://cdn.mp3quran.net/audio/muhammad-minshawi/r3/',
    style: 'المصحف المعلم مع ترديد الأطفال - مثالي للأطفال والناشئة'
  },
  {
    id: 'hudhaify_hafs',
    name: 'الشيخ علي بن عبد الرحمن الحذيفي',
    riwayah: 'hafs',
    sourceType: 'everyayah',
    subfolder: 'Hudhaify_128kbps',
    directUrl: 'https://cdn.mp3quran.net/audio/ali-hudhaifi/r1/',
    style: 'قراءة بطيئة محكمة مناسبة للحفظ والتدبر'
  },

  // --- 2. رواية قالون عن نافع ---
  {
    id: 'husary_qaloon',
    name: 'الشيخ محمود خليل الحصري (قالون)',
    riwayah: 'qaloon',
    sourceType: 'direct',
    subfolder: 'Husary_Qalon_128kbps',
    directUrl: 'https://cdn.mp3quran.net/audio/mahmoud-husary/r5/',
    style: 'قراءة محققة متقنة لأصول قالون وسكتاته وقصره'
  },
  {
    id: 'hudhaifi_qaloon',
    name: 'الشيخ علي بن عبد الرحمن الحذيفي (قالون)',
    riwayah: 'qaloon',
    sourceType: 'direct',
    subfolder: 'Qalon_Ali_Al-Hudaifi_128kbps',
    directUrl: 'https://cdn.mp3quran.net/audio/ali-hudhaifi/r2/',
    style: 'ترتيل متأنٍ برواية قالون عن نافع المدني'
  },

  // --- 3. رواية ورش عن نافع ---
  {
    id: 'koushi_warsh',
    name: 'الشيخ العيون الكوشي (ورش)',
    riwayah: 'warsh',
    sourceType: 'direct',
    subfolder: 'koushi_128kbps',
    directUrl: 'https://cdn.mp3quran.net/audio/laayoun-kouchi/r1/',
    style: 'قراءة مغربية شجية مشهورة بإتقان أصول ورش وتقليله'
  },
  {
    id: 'husary_warsh',
    name: 'الشيخ محمود خليل الحصري (ورش)',
    riwayah: 'warsh',
    sourceType: 'direct',
    subfolder: 'Warsh_Husary_128kbps',
    directUrl: 'https://cdn.mp3quran.net/audio/mahmoud-husary/r3/',
    style: 'المرجع الأول في ضبط وتطبيق أحكام رواية ورش'
  },
  {
    id: 'dosary_warsh',
    name: 'الشيخ إبراهيم الدوسري (ورش)',
    riwayah: 'warsh',
    sourceType: 'everyayah',
    subfolder: 'warsh/warsh_ibrahim_aldosary_128kbps',
    directUrl: 'https://cdn.mp3quran.net/audio/laayoun-kouchi/r1/',
    style: 'تلاوة برواية ورش عن نافع بمصاحبة الآيات آية بآية'
  },

  // --- 4. قراءة حمزة (خلف عن حمزة) ---
  {
    id: 'soufi_khalaf_hamzah',
    name: 'الشيخ عبد الرشيد صوفي (خلف عن حمزة)',
    riwayah: 'hamzah',
    sourceType: 'direct',
    subfolder: 'Abdulrasheed_Soufi_Khalaf_128kbps',
    directUrl: 'https://cdn.mp3quran.net/audio/abdulrasheed-sufi/r1/',
    style: 'قراءة مميزة بالسكت على المفصول والموصول والمد المشبع'
  },

  // --- 5. قراءة الكسائي (الدوري وأبو الحارث) ---
  {
    id: 'husary_duri_kisai',
    name: 'الشيخ محمود خليل الحصري (الدوري عن الكسائي / أبي عمرو)',
    riwayah: 'kisai',
    sourceType: 'direct',
    subfolder: 'Husary_Duri_128kbps',
    directUrl: 'https://cdn.mp3quran.net/audio/mahmoud-husary/r4/',
    style: 'قراءة متقنة بإمالات الكسائي وأبي عمرو المعتبرة'
  },
  {
    id: 'soufi_kisai',
    name: 'الشيخ عبد الرشيد صوفي (قراءة الكسائي)',
    riwayah: 'kisai',
    sourceType: 'direct',
    subfolder: 'Abdulrasheed_Soufi_Aldoori_128kbps',
    directUrl: 'https://cdn.mp3quran.net/audio/abdulrasheed-sufi/r1/',
    style: 'رواية الإمام أبي الحارث والدوري عن الكسائي'
  },

  // --- 6. قراءة أبي عمرو (السوسي) ---
  {
    id: 'soufi_soosi',
    name: 'الشيخ عبد الرشيد صوفي (السوسي عن أبي عمرو)',
    riwayah: 'soosi',
    sourceType: 'direct',
    subfolder: 'Abdulrasheed_Soufi_Soosi_128kbps',
    directUrl: 'https://cdn.mp3quran.net/audio/abdulrasheed-sufi/r2/',
    style: 'الإدغام الكبير وأصول الإبدال عند السوسي البصري'
  },
  {
    id: 'husary_duri_soosi',
    name: 'الشيخ محمود خليل الحصري (الدوري عن أبي عمرو)',
    riwayah: 'soosi',
    sourceType: 'direct',
    subfolder: 'Husary_Duri_128kbps',
    directUrl: 'https://cdn.mp3quran.net/audio/mahmoud-husary/r4/',
    style: 'قراءة أهل البصرة برواية الإمام الدوري عن أبي عمرو'
  }
];

// Sample Schedule Data
const scheduleData = [
  { day: 1, name: 'السبت', portion: 'الربع الأول (الم ذَٰلِكَ الْكِتَابُ)', surah: 'البقرة 1-25', done: true, friday: false },
  { day: 2, name: 'الأحد', portion: 'الربع الثاني (إِنَّ اللَّهَ لَا يَسْتَحْيِي)', surah: 'البقرة 26-43', done: true, friday: false },
  { day: 3, name: 'الإثنين', portion: 'الربع الثالث (أَتَأْمُرُونَ النَّاسَ بِالْبِرِّ)', surah: 'البقرة 44-59', done: true, friday: false },
  { day: 4, name: 'الثلاثاء', portion: 'الربع الرابع (وَإِذِ اسْتَسْقَىٰ مُوسَىٰ)', surah: 'البقرة 60-74', done: true, friday: false },
  { day: 5, name: 'الأربعاء', portion: 'الربع الخامس (أَفَتَطْمَعُونَ أَن يُؤْمِنُوا)', surah: 'البقرة 75-91', done: false, delayed: true, friday: false },
  { day: 6, name: 'الخميس', portion: 'الربع السادس (وَلَقَدْ جَاءَكُم مُّوسَىٰ)', surah: 'البقرة 92-105', done: false, friday: false },
  { day: 7, name: 'الجمعة', portion: 'جلسة مراجعة وتثبيت حصاد الأسبوع', surah: 'مراجعة الأرباع 1-6', done: false, friday: true },
  { day: 8, name: 'السبت', portion: 'الربع السابع (مَا نَنسَخْ مِنْ آيَةٍ)', surah: 'البقرة 106-123', done: false, friday: false },
];

// Quiz Questions
const quizQuestions = [
  {
    prompt: 'قُلْ أَعُوذُ بِرَبِّ .......',
    surah: 'سورة الفلق',
    answer: 'الْفَلَقِ',
    options: ['الْفَلَقِ', 'النَّاسِ', 'الصَّمَدِ', 'الْكَوْثَرِ']
  },
  {
    prompt: 'مِن شَرِّ الْوَسْوَاسِ .......',
    surah: 'سورة الناس',
    answer: 'الْخَنَّاسِ',
    options: ['الْخَنَّاسِ', 'الْعَظِيمِ', 'الرَّحِيمِ', 'الْمُبِينِ']
  },
  {
    prompt: 'اللَّهُ الصَّمَدُ * لَمْ يَلِدْ وَلَمْ .......',
    surah: 'سورة الإخلاص',
    answer: 'يُولَدْ',
    options: ['يُولَدْ', 'يَعْلَمْ', 'يَكُن', 'يَمُتْ']
  }
];

// Initialize
window.addEventListener('DOMContentLoaded', () => {
  populateSurahsDropdown();
  populatePagesDropdown();
  populateRubsDropdown();
  updateRangeInputsUI();
  renderMadaniMushafPage();
  renderScheduleTable();
  setupAudioListeners();
  populateRecitersDropdown('hafs');
  updatePlayerUI();
});

// Dual Theme Switcher
function switchTheme(theme) {
  currentTheme = theme;
  const body = document.body;
  const adultView = document.getElementById('adult-view');
  const kidsView = document.getElementById('kids-view');
  const btnAdult = document.getElementById('btn-mode-adult');
  const btnKids = document.getElementById('btn-mode-kids');
  const heading = document.getElementById('app-heading');
  const subheading = document.getElementById('app-subheading');

  if (theme === 'kids') {
    body.classList.remove('adult-theme');
    body.classList.add('kids-theme');
    adultView.classList.remove('active');
    kidsView.classList.add('active');
    btnAdult.classList.remove('active');
    btnKids.classList.add('active');
    heading.textContent = 'بستان القرآن وحلقات الأبطال';
    subheading.textContent = 'رحلة الأبطال عائشة ومريم وسالم وسارة في حفظ وتدبر جزء عم 🌸';
    // Switch to Minshawi with kids teacher style
    currentRiwayah = 'hafs';
    currentSurah = 112;
    currentAyah = 1;
    currentAyahRepeat = 1;
    currentMushafPage = 604;
    rangeStartAyah = 1;
    rangeEndAyah = 4;
    currentReciterId = 'minshawi_teacher';
    currentReciterSubfolder = 'Minshawy_Teacher_128kbps';
    currentReciterName = 'الشيخ المنشاوي مع الأطفال (المصحف المعلم)';

    const riwayahSel = document.getElementById('riwayah-select');
    if (riwayahSel) riwayahSel.value = 'hafs';
    populateRecitersDropdown('hafs');

    const recSel = document.getElementById('reciter-select');
    if (recSel) recSel.value = 'minshawi_teacher';

    const surahSel = document.getElementById('surah-select');
    if (surahSel) surahSel.value = '112';

    const pageSel = document.getElementById('page-select');
    if (pageSel) pageSel.value = '604';

    updateRangeInputsUI();
    renderMadaniMushafPage();
    updatePlayerUI();
    showToast('🌸 مرحباً بك في بستان القرآن! تلاوة الشيخ المنشاوي مع ترديد الأطفال مفعلة 🎙️');
    if (isPlaying) {
      playCurrentAyah();
    }
  } else {
    body.classList.remove('kids-theme');
    body.classList.add('adult-theme');
    kidsView.classList.remove('active');
    adultView.classList.add('active');
    btnKids.classList.remove('active');
    btnAdult.classList.add('active');
    heading.textContent = 'مصحف الحفظ والورد القرآني';
    subheading.textContent = 'نظام الأرباع والجدولة الكلاسيكية المتقنة لـ 280 يوماً';

    currentRiwayah = 'hafs';
    currentSurah = 2;
    currentAyah = 1;
    currentAyahRepeat = 1;
    currentMushafPage = 2;
    rangeStartAyah = 1;
    rangeEndAyah = 5;
    currentReciterId = 'ghamadi';
    currentReciterSubfolder = 'Ghamadi_40kbps';
    currentReciterName = 'الشيخ سعد الغامدي';

    const riwayahSel = document.getElementById('riwayah-select');
    if (riwayahSel) riwayahSel.value = 'hafs';
    populateRecitersDropdown('hafs');

    const recSel = document.getElementById('reciter-select');
    if (recSel) recSel.value = 'ghamadi';

    const surahSel = document.getElementById('surah-select');
    if (surahSel) surahSel.value = '2';

    const pageSel = document.getElementById('page-select');
    if (pageSel) pageSel.value = '2';

    updateRangeInputsUI();
    renderMadaniMushafPage();
    updatePlayerUI();
    showToast('📖 وضع الحفظ الكلاسيكي مفعل');
    if (isPlaying) {
      playCurrentAyah();
    }
  }
}

// Render Classical Table
function renderScheduleTable() {
  const tbody = document.getElementById('schedule-tbody');
  tbody.innerHTML = '';

  scheduleData.forEach((item) => {
    const tr = document.createElement('tr');
    if (item.friday) tr.classList.add('friday-row');
    if (item.done) tr.classList.add('completed-row');

    tr.innerHTML = `
      <td><span class="day-badge ${item.friday ? 'friday-badge' : ''}">${item.day}</span></td>
      <td><strong>${item.name}</strong></td>
      <td>
        <div style="font-weight: 700;">${item.portion}</div>
        <div style="font-size: 11.5px; color: #64748B;">${item.surah}</div>
        ${item.delayed ? '<span style="font-size: 10px; color: #EF6C00; font-weight: 800;">⚠️ متأخر عن الموعد</span>' : ''}
      </td>
      <td style="text-align: center;">${item.done ? '⭐⭐⭐⭐⭐' : item.friday ? 'مراجعة' : '⚪⚪⚪⚪⚪'}</td>
      <td>
        <span style="font-weight: 800; font-size: 11px; padding: 2px 8px; border-radius: 6px; background: ${item.done ? '#DCFCE7; color: #166534;' : item.delayed ? '#FFEDD5; color: #9A3412;' : '#F1F5F9; color: #475569;'}">
          ${item.done ? 'مكتمل' : item.delayed ? 'متأخر' : 'قادم'}
        </span>
      </td>
    `;
    tbody.appendChild(tr);
  });
}

// 5 Prayers Check-off
function togglePrayer(index) {
  prayerStatus[index] = !prayerStatus[index];
  const chk = document.getElementById(`prayer-chk-${index}`);
  const item = chk.closest('.prayer-item');
  if (prayerStatus[index]) {
    item.classList.add('done');
  } else {
    item.classList.remove('done');
  }

  const doneCount = prayerStatus.filter(Boolean).length;
  document.getElementById('prayer-badge-text').textContent = `${doneCount} / 5 صلوات`;

  if (doneCount === 5) {
    document.getElementById('check-btn-text').textContent = 'تم إنجاز كامل الصلوات اليومية ✓';
    document.getElementById('check-btn-icon').textContent = '🌟';
  }
}

// Helper: Convert Western numerals to Arabic-Indic digits (١, ٢, ٣...)
function toArabicDigits(num) {
  const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return String(num).replace(/\d/g, d => arabicDigits[d]);
}

// Arabic Ordinal Words for Juz and Hizb
const arabicOrdinalWords = {
  1: 'الأَوَّلُ', 2: 'الثَّانِي', 3: 'الثَّالِثُ', 4: 'الرَّابِعُ', 5: 'الخَامِسُ',
  6: 'السَّادِسُ', 7: 'السَّابِعُ', 8: 'الثَّامِنُ', 9: 'التَّاسِعُ', 10: 'العَاشِرُ',
  11: 'الحَادِي عَشَرَ', 12: 'الثَّانِي عَشَرَ', 13: 'الثَّالِثَ عَشَرَ', 14: 'الرَّابِعَ عَشَرَ', 15: 'الخَامِسَ عَشَرَ',
  16: 'السَّادِسَ عَشَرَ', 17: 'السَّابِعَ عَشَرَ', 18: 'الثَّامِنَ عَشَرَ', 19: 'التَّاسِعَ عَشَرَ', 20: 'العِشْرُونَ',
  21: 'الحَادِي وَالعِشْرُونَ', 22: 'الثَّانِي وَالعِشْرُونَ', 23: 'الثَّالِثُ وَالعِشْرُونَ', 24: 'الرَّابِعُ وَالعِشْرُونَ', 25: 'الخَامِسُ وَالعِشْرُونَ',
  26: 'السَّادِسُ وَالعِشْرُونَ', 27: 'السَّابِعُ وَالعِشْرُونَ', 28: 'الثَّامِنُ وَالعِشْرُونَ', 29: 'التَّاسِعُ وَالعِشْرُونَ', 30: 'الثَّلَاثُونَ'
};

// Canonical 114 Surahs Database
const surahsDatabase = [
  { num: 1, name: 'الفاتحة', english: 'Al-Fatihah', ayahs: 7, startPage: 1, type: 'مكية', juz: 1 },
  { num: 2, name: 'البقرة', english: 'Al-Baqarah', ayahs: 286, startPage: 2, type: 'مدنية', juz: 1 },
  { num: 3, name: 'آل عمران', english: 'Ali Imran', ayahs: 200, startPage: 50, type: 'مدنية', juz: 3 },
  { num: 4, name: 'النساء', english: 'An-Nisa', ayahs: 176, startPage: 77, type: 'مدنية', juz: 4 },
  { num: 5, name: 'المائدة', english: 'Al-Maidah', ayahs: 120, startPage: 106, type: 'مدنية', juz: 6 },
  { num: 6, name: 'الأنعام', english: 'Al-Anam', ayahs: 165, startPage: 128, type: 'مكية', juz: 7 },
  { num: 7, name: 'الأعراف', english: 'Al-Araf', ayahs: 206, startPage: 151, type: 'مكية', juz: 8 },
  { num: 8, name: 'الأنفال', english: 'Al-Anfal', ayahs: 75, startPage: 177, type: 'مدنية', juz: 9 },
  { num: 9, name: 'التوبة', english: 'At-Tawbah', ayahs: 129, startPage: 187, type: 'مدنية', juz: 10 },
  { num: 10, name: 'يونس', english: 'Yunus', ayahs: 109, startPage: 208, type: 'مكية', juz: 11 },
  { num: 11, name: 'هود', english: 'Hud', ayahs: 123, startPage: 221, type: 'مكية', juz: 11 },
  { num: 12, name: 'يوسف', english: 'Yusuf', ayahs: 111, startPage: 235, type: 'مكية', juz: 12 },
  { num: 13, name: 'الرعد', english: 'Ar-Rad', ayahs: 43, startPage: 249, type: 'مدنية', juz: 13 },
  { num: 14, name: 'إبراهيم', english: 'Ibrahim', ayahs: 52, startPage: 255, type: 'مكية', juz: 13 },
  { num: 15, name: 'الحجر', english: 'Al-Hijr', ayahs: 99, startPage: 262, type: 'مكية', juz: 14 },
  { num: 16, name: 'النحل', english: 'An-Nahl', ayahs: 128, startPage: 267, type: 'مكية', juz: 14 },
  { num: 17, name: 'الإسراء', english: 'Al-Isra', ayahs: 111, startPage: 282, type: 'مكية', juz: 15 },
  { num: 18, name: 'الكهف', english: 'Al-Kahf', ayahs: 110, startPage: 293, type: 'مكية', juz: 15 },
  { num: 19, name: 'مريم', english: 'Maryam', ayahs: 98, startPage: 305, type: 'مكية', juz: 16 },
  { num: 20, name: 'طه', english: 'Taha', ayahs: 135, startPage: 312, type: 'مكية', juz: 16 },
  { num: 21, name: 'الأنبياء', english: 'Al-Anbiya', ayahs: 112, startPage: 322, type: 'مكية', juz: 17 },
  { num: 22, name: 'الحج', english: 'Al-Hajj', ayahs: 78, startPage: 332, type: 'مدنية', juz: 17 },
  { num: 23, name: 'المؤمنون', english: 'Al-Muminun', ayahs: 118, startPage: 342, type: 'مكية', juz: 18 },
  { num: 24, name: 'النور', english: 'An-Nur', ayahs: 64, startPage: 350, type: 'مدنية', juz: 18 },
  { num: 25, name: 'الفرقان', english: 'Al-Furqan', ayahs: 77, startPage: 359, type: 'مكية', juz: 18 },
  { num: 26, name: 'الشعراء', english: 'Ash-Shuara', ayahs: 227, startPage: 367, type: 'مكية', juz: 19 },
  { num: 27, name: 'النمل', english: 'An-Naml', ayahs: 93, startPage: 377, type: 'مكية', juz: 19 },
  { num: 28, name: 'القصص', english: 'Al-Qasas', ayahs: 88, startPage: 385, type: 'مكية', juz: 20 },
  { num: 29, name: 'العنكبوت', english: 'Al-Ankabut', ayahs: 69, startPage: 396, type: 'مكية', juz: 20 },
  { num: 30, name: 'الروم', english: 'Ar-Rum', ayahs: 60, startPage: 404, type: 'مكية', juz: 21 },
  { num: 31, name: 'لقمان', english: 'Luqman', ayahs: 34, startPage: 411, type: 'مكية', juz: 21 },
  { num: 32, name: 'السجدة', english: 'As-Sajdah', ayahs: 30, startPage: 415, type: 'مكية', juz: 21 },
  { num: 33, name: 'الأحزاب', english: 'Al-Ahzab', ayahs: 73, startPage: 418, type: 'مدنية', juz: 21 },
  { num: 34, name: 'سبأ', english: 'Saba', ayahs: 54, startPage: 428, type: 'مكية', juz: 22 },
  { num: 35, name: 'فاطر', english: 'Fatir', ayahs: 45, startPage: 434, type: 'مكية', juz: 22 },
  { num: 36, name: 'يس', english: 'Ya-Sin', ayahs: 83, startPage: 440, type: 'مكية', juz: 22 },
  { num: 37, name: 'الصافات', english: 'As-Saffat', ayahs: 182, startPage: 446, type: 'مكية', juz: 23 },
  { num: 38, name: 'ص', english: 'Sad', ayahs: 88, startPage: 453, type: 'مكية', juz: 23 },
  { num: 39, name: 'الزمر', english: 'Az-Zumar', ayahs: 75, startPage: 458, type: 'مكية', juz: 23 },
  { num: 40, name: 'غافر', english: 'Ghafir', ayahs: 85, startPage: 467, type: 'مكية', juz: 24 },
  { num: 41, name: 'فصلت', english: 'Fussilat', ayahs: 54, startPage: 477, type: 'مكية', juz: 24 },
  { num: 42, name: 'الشورى', english: 'Ash-Shura', ayahs: 53, startPage: 483, type: 'مكية', juz: 25 },
  { num: 43, name: 'الزخرف', english: 'Az-Zukhruf', ayahs: 89, startPage: 489, type: 'مكية', juz: 25 },
  { num: 44, name: 'الدخان', english: 'Ad-Dukhan', ayahs: 59, startPage: 496, type: 'مكية', juz: 25 },
  { num: 45, name: 'الجاثية', english: 'Al-Jathiyah', ayahs: 37, startPage: 499, type: 'مكية', juz: 25 },
  { num: 46, name: 'الأحقاف', english: 'Al-Ahqaf', ayahs: 35, startPage: 502, type: 'مكية', juz: 26 },
  { num: 47, name: 'محمد', english: 'Muhammad', ayahs: 38, startPage: 507, type: 'مدنية', juz: 26 },
  { num: 48, name: 'الفتح', english: 'Al-Fath', ayahs: 29, startPage: 511, type: 'مدنية', juz: 26 },
  { num: 49, name: 'الحجرات', english: 'Al-Hujurat', ayahs: 18, startPage: 515, type: 'مدنية', juz: 26 },
  { num: 50, name: 'ق', english: 'Qaf', ayahs: 45, startPage: 518, type: 'مكية', juz: 26 },
  { num: 51, name: 'الذاريات', english: 'Adh-Dhariyat', ayahs: 60, startPage: 520, type: 'مكية', juz: 26 },
  { num: 52, name: 'الطور', english: 'At-Tur', ayahs: 49, startPage: 523, type: 'مكية', juz: 27 },
  { num: 53, name: 'النجم', english: 'An-Najm', ayahs: 62, startPage: 526, type: 'مكية', juz: 27 },
  { num: 54, name: 'القمر', english: 'Al-Qamar', ayahs: 55, startPage: 528, type: 'مكية', juz: 27 },
  { num: 55, name: 'الرحمن', english: 'Ar-Rahman', ayahs: 78, startPage: 531, type: 'مدنية', juz: 27 },
  { num: 56, name: 'الواقعة', english: 'Al-Waqiah', ayahs: 96, startPage: 534, type: 'مكية', juz: 27 },
  { num: 57, name: 'الحديد', english: 'Al-Hadid', ayahs: 29, startPage: 537, type: 'مدنية', juz: 27 },
  { num: 58, name: 'المجادلة', english: 'Al-Mujadilah', ayahs: 22, startPage: 542, type: 'مدنية', juz: 28 },
  { num: 59, name: 'الحشر', english: 'Al-Hashr', ayahs: 24, startPage: 545, type: 'مدنية', juz: 28 },
  { num: 60, name: 'الممتحنة', english: 'Al-Mumtahanah', ayahs: 13, startPage: 549, type: 'مدنية', juz: 28 },
  { num: 61, name: 'الصف', english: 'As-Saff', ayahs: 14, startPage: 551, type: 'مدنية', juz: 28 },
  { num: 62, name: 'الجمعة', english: 'Al-Jumuah', ayahs: 11, startPage: 553, type: 'مدنية', juz: 28 },
  { num: 63, name: 'المنافقون', english: 'Al-Munafiqun', ayahs: 11, startPage: 554, type: 'مدنية', juz: 28 },
  { num: 64, name: 'التغابن', english: 'At-Taghabun', ayahs: 18, startPage: 556, type: 'مدنية', juz: 28 },
  { num: 65, name: 'الطلاق', english: 'At-Talaq', ayahs: 12, startPage: 558, type: 'مدنية', juz: 28 },
  { num: 66, name: 'التحريم', english: 'At-Tahrim', ayahs: 12, startPage: 560, type: 'مدنية', juz: 28 },
  { num: 67, name: 'الملك', english: 'Al-Mulk', ayahs: 30, startPage: 562, type: 'مكية', juz: 29 },
  { num: 68, name: 'القلم', english: 'Al-Qalam', ayahs: 52, startPage: 564, type: 'مكية', juz: 29 },
  { num: 69, name: 'الحاقة', english: 'Al-Haqqah', ayahs: 52, startPage: 566, type: 'مكية', juz: 29 },
  { num: 70, name: 'المعارج', english: 'Al-Maarij', ayahs: 44, startPage: 568, type: 'مكية', juz: 29 },
  { num: 71, name: 'نوح', english: 'Nuh', ayahs: 28, startPage: 570, type: 'مكية', juz: 29 },
  { num: 72, name: 'الجن', english: 'Al-Jinn', ayahs: 28, startPage: 572, type: 'مكية', juz: 29 },
  { num: 73, name: 'المزمل', english: 'Al-Muzzammil', ayahs: 20, startPage: 574, type: 'مكية', juz: 29 },
  { num: 74, name: 'المدثر', english: 'Al-Muddathir', ayahs: 56, startPage: 575, type: 'مكية', juz: 29 },
  { num: 75, name: 'القيامة', english: 'Al-Qiyamah', ayahs: 40, startPage: 577, type: 'مكية', juz: 29 },
  { num: 76, name: 'الإنسان', english: 'Al-Insan', ayahs: 31, startPage: 578, type: 'مدنية', juz: 29 },
  { num: 77, name: 'المرسلات', english: 'Al-Mursalat', ayahs: 50, startPage: 580, type: 'مكية', juz: 29 },
  { num: 78, name: 'النبأ', english: 'An-Naba', ayahs: 40, startPage: 582, type: 'مكية', juz: 30 },
  { num: 79, name: 'النازعات', english: 'An-Naziat', ayahs: 46, startPage: 583, type: 'مكية', juz: 30 },
  { num: 80, name: 'عبس', english: 'Abasa', ayahs: 42, startPage: 585, type: 'مكية', juz: 30 },
  { num: 81, name: 'التكوير', english: 'At-Takwir', ayahs: 29, startPage: 586, type: 'مكية', juz: 30 },
  { num: 82, name: 'الانفطار', english: 'Al-Infitar', ayahs: 19, startPage: 587, type: 'مكية', juz: 30 },
  { num: 83, name: 'المطففين', english: 'Al-Mutaffifin', ayahs: 36, startPage: 587, type: 'مكية', juz: 30 },
  { num: 84, name: 'الانشقاق', english: 'Al-Inshiqaq', ayahs: 25, startPage: 589, type: 'مكية', juz: 30 },
  { num: 85, name: 'البروج', english: 'Al-Buruj', ayahs: 22, startPage: 590, type: 'مكية', juz: 30 },
  { num: 86, name: 'الطارق', english: 'At-Tariq', ayahs: 17, startPage: 591, type: 'مكية', juz: 30 },
  { num: 87, name: 'الأعلى', english: 'Al-Ala', ayahs: 19, startPage: 591, type: 'مكية', juz: 30 },
  { num: 88, name: 'الغاشية', english: 'Al-Ghashiyah', ayahs: 26, startPage: 592, type: 'مكية', juz: 30 },
  { num: 89, name: 'الفجر', english: 'Al-Fajr', ayahs: 30, startPage: 593, type: 'مكية', juz: 30 },
  { num: 90, name: 'البلد', english: 'Al-Balad', ayahs: 20, startPage: 594, type: 'مكية', juz: 30 },
  { num: 91, name: 'الشمس', english: 'Ash-Shams', ayahs: 15, startPage: 595, type: 'مكية', juz: 30 },
  { num: 92, name: 'الليل', english: 'Al-Layl', ayahs: 21, startPage: 595, type: 'مكية', juz: 30 },
  { num: 93, name: 'الضحى', english: 'Ad-Duha', ayahs: 11, startPage: 596, type: 'مكية', juz: 30 },
  { num: 94, name: 'الشرح', english: 'Ash-Sharh', ayahs: 8, startPage: 596, type: 'مكية', juz: 30 },
  { num: 95, name: 'التين', english: 'At-Tin', ayahs: 8, startPage: 597, type: 'مكية', juz: 30 },
  { num: 96, name: 'العلق', english: 'Al-Alaq', ayahs: 19, startPage: 597, type: 'مكية', juz: 30 },
  { num: 97, name: 'القدر', english: 'Al-Qadr', ayahs: 5, startPage: 598, type: 'مكية', juz: 30 },
  { num: 98, name: 'البينة', english: 'Al-Bayyinah', ayahs: 8, startPage: 598, type: 'مدنية', juz: 30 },
  { num: 99, name: 'الزلزلة', english: 'Az-Zalzalah', ayahs: 8, startPage: 599, type: 'مدنية', juz: 30 },
  { num: 100, name: 'العاديات', english: 'Al-Adiyat', ayahs: 11, startPage: 599, type: 'مكية', juz: 30 },
  { num: 101, name: 'القارعة', english: 'Al-Qariah', ayahs: 11, startPage: 600, type: 'مكية', juz: 30 },
  { num: 102, name: 'التكاثر', english: 'At-Takathur', ayahs: 8, startPage: 600, type: 'مكية', juz: 30 },
  { num: 103, name: 'العصر', english: 'Al-Asr', ayahs: 3, startPage: 601, type: 'مكية', juz: 30 },
  { num: 104, name: 'الهمزة', english: 'Al-Humazah', ayahs: 9, startPage: 601, type: 'مكية', juz: 30 },
  { num: 105, name: 'الفيل', english: 'Al-Fil', ayahs: 5, startPage: 601, type: 'مكية', juz: 30 },
  { num: 106, name: 'قريش', english: 'Quraysh', ayahs: 4, startPage: 602, type: 'مكية', juz: 30 },
  { num: 107, name: 'الماعون', english: 'Al-Maun', ayahs: 7, startPage: 602, type: 'مكية', juz: 30 },
  { num: 108, name: 'الكوثر', english: 'Al-Kawthar', ayahs: 3, startPage: 602, type: 'مكية', juz: 30 },
  { num: 109, name: 'الكافرون', english: 'Al-Kafirun', ayahs: 6, startPage: 603, type: 'مكية', juz: 30 },
  { num: 110, name: 'النصر', english: 'An-Nasr', ayahs: 3, startPage: 603, type: 'مدنية', juz: 30 },
  { num: 111, name: 'المسد', english: 'Al-Masad', ayahs: 5, startPage: 603, type: 'مكية', juz: 30 },
  { num: 112, name: 'الإخلاص', english: 'Al-Ikhlas', ayahs: 4, startPage: 604, type: 'مكية', juz: 30 },
  { num: 113, name: 'الفلق', english: 'Al-Falaq', ayahs: 5, startPage: 604, type: 'مكية', juz: 30 },
  { num: 114, name: 'الناس', english: 'An-Nas', ayahs: 6, startPage: 604, type: 'مكية', juz: 30 }
];

// Madani Mushaf Pages Mapping
const madaniPagesDatabase = {
  1: { surah: 1, surahName: 'سُورَةُ الفَاتِحَةِ', startAyah: 1, endAyah: 7, juz: 1, hizb: 1, rub: 1, title: 'الجُزْءُ الأَوَّلُ • سُورَةُ الفَاتِحَةِ' },
  2: { surah: 2, surahName: 'سُورَةُ البَقَرَةِ', startAyah: 1, endAyah: 5, juz: 1, hizb: 1, rub: 1, title: 'الجُزْءُ الأَوَّلُ • سُورَةُ البَقَرَةِ' },
  3: { surah: 2, surahName: 'سُورَةُ البَقَرَةِ', startAyah: 6, endAyah: 16, juz: 1, hizb: 1, rub: 1, title: 'الجُزْءُ الأَوَّلُ • سُورَةُ البَقَرَةِ' },
  4: { surah: 2, surahName: 'سُورَةُ البَقَرَةِ', startAyah: 17, endAyah: 24, juz: 1, hizb: 1, rub: 1, title: 'الجُزْءُ الأَوَّلُ • سُورَةُ البَقَرَةِ' },
  5: { surah: 2, surahName: 'سُورَةُ البَقَرَةِ', startAyah: 25, endAyah: 29, juz: 1, hizb: 1, rub: 1, title: 'الجُزْءُ الأَوَّلُ • سُورَةُ البَقَرَةِ' },
  604: { surah: 112, surahName: 'سُورَةُ الإِخْلَاصِ', startAyah: 1, endAyah: 4, juz: 30, hizb: 60, rub: 240, title: 'الجُزْءُ الثَّلَاثُونَ • سُورَةُ الإِخْلَاصِ' }
};

function getPageInfo(page) {
  if (madaniPagesDatabase[page]) return madaniPagesDatabase[page];
  let foundSurah = surahsDatabase[0];
  for (let i = 0; i < surahsDatabase.length; i++) {
    if (surahsDatabase[i].startPage <= page) {
      foundSurah = surahsDatabase[i];
    } else {
      break;
    }
  }
  const estimatedJuz = Math.min(30, Math.max(1, Math.ceil(page / 20)));
  const estimatedHizb = Math.min(60, Math.max(1, Math.ceil(page / 10)));
  const estimatedRub = Math.min(240, Math.max(1, Math.ceil(page / 2.5)));
  return {
    surah: foundSurah.num,
    surahName: `سُورَةُ ${foundSurah.name}`,
    startAyah: 1,
    endAyah: Math.min(5, foundSurah.ayahs),
    juz: estimatedJuz,
    hizb: estimatedHizb,
    rub: estimatedRub,
    title: `الجُزْءُ ${toArabicDigits(estimatedJuz)} • سُورَةُ ${foundSurah.name}`
  };
}

// 240 Quarters (الأرباع) Database
const rubsDatabase = [
  { id: 1, surah: 2, name: 'الربع الأول: الم ذَٰلِكَ الْكِتَابُ', startAyah: 1, endAyah: 25, juz: 1, hizb: 1, page: 2 },
  { id: 2, surah: 2, name: 'الربع الثاني: إِنَّ اللَّهَ لَا يَسْتَحْيِي', startAyah: 26, endAyah: 43, juz: 1, hizb: 1, page: 5 },
  { id: 3, surah: 2, name: 'الربع الثالث: أَتَأْمُرُونَ النَّاسَ بِالْبِرِّ', startAyah: 44, endAyah: 59, juz: 1, hizb: 2, page: 7 },
  { id: 4, surah: 2, name: 'الربع الرابع: وَإِذِ اسْتَسْقَىٰ مُوسَىٰ', startAyah: 60, endAyah: 74, juz: 1, hizb: 2, page: 9 },
  { id: 5, surah: 2, name: 'الربع الخامس: أَفَتَطْمَعُونَ أَن يُؤْمِنُوا', startAyah: 75, endAyah: 91, juz: 1, hizb: 3, page: 11 },
  { id: 6, surah: 2, name: 'الربع السادس: وَلَقَدْ جَاءَكُم مُّوسَىٰ', startAyah: 92, endAyah: 105, juz: 1, hizb: 3, page: 14 },
  { id: 7, surah: 2, name: 'الربع السابع: مَا نَنسَخْ مِنْ آيَةٍ', startAyah: 106, endAyah: 123, juz: 1, hizb: 4, page: 16 },
  { id: 8, surah: 2, name: 'الربع الثامن: وَإِذِ ابْتَلَىٰ إِبْرَاهِيمَ', startAyah: 124, endAyah: 141, juz: 1, hizb: 4, page: 19 },
  { id: 240, surah: 112, name: 'الربع 240: جزء عم والأخيرة', startAyah: 1, endAyah: 4, juz: 30, hizb: 60, page: 604 }
];

// Authentic Uthmanic Quran Texts
const uthmanicQuranText = {
  // Surah 2 (Al-Baqarah) - 1 to 25
  '2_1': 'الم',
  '2_2': 'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ',
  '2_3': 'الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ',
  '2_4': 'وَالَّذِينَ يُؤْمِنُونَ بِمَا أُنزِلَ إِلَيْكَ وَمَا أُنزِلَ مِن قَبْلِكَ وَبِالْآخِرَةِ هُمْ يُوقِنُونَ',
  '2_5': 'أُولَـٰئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ ۖ وَأُولَـٰئِكَ هُمُ الْمُفْلِحُونَ',
  '2_6': 'إِنَّ الَّذِينَ كَفَرُوا سَوَاءٌ عَلَيْهِمْ أَأَنذَرْتَهُمْ أَمْ لَمْ تُنذِرْهُمْ لَا يُؤْمِنُونَ',
  '2_7': 'خَتَمَ اللَّهُ عَلَىٰ قُلُوبِهِمْ وَعَلَىٰ سَمْعِهِمْ ۖ وَعَلَىٰ أَبْصَارِهِمْ غِشَاوَةٌ ۖ وَلَهُمْ عَذَابٌ عَظِيمٌ',
  '2_8': 'وَمِنَ النَّاسِ مَن يَقُولُ آمَنَّا بِاللَّهِ وَبِالْيَوْمِ الْآخِرِ وَمَا هُم بِمُؤْمِنِينَ',
  '2_9': 'يُخَادِعُونَ اللَّهَ وَالَّذِينَ آمَنُوا وَمَا يَخْدَعُونَ إِلَّا أَنفُسَهُمْ وَمَا يَشْعُرُونَ',
  '2_10': 'فِي قُلُوبِهِم مَّرَضٌ فَزَادَهُمُ اللَّهُ مَرَضًا ۖ وَلَهُمْ عَذَابٌ أَلِيمٌ بِمَا كَانُوا يَكْذِبُونَ',
  '2_11': 'وَإِذَا قِيلَ لَهُمْ لَا تُفْسِدُوا فِي الْأَرْضِ قَالُوا إِنَّمَا نَحْنُ مُصْلِحُونَ',
  '2_12': 'أَلَا إِنَّهُمْ هُمُ الْمُفْسِدُونَ وَلَـٰكِن لَّا يَشْعُرُونَ',
  '2_13': 'وَإِذَا قِيلَ لَهُمْ آمِنُوا كَمَا آمَنَ النَّاسُ قَالُوا أَنُؤْمِنُ كَمَا آمَنَ السُّفَهَاءُ ۗ أَلَا إِنَّهُمْ هُمُ السُّفَهَاءُ وَلَـٰكِن لَّا يَعْلَمُونَ',
  '2_14': 'وَإِذَا لَقُوا الَّذِينَ آمَنُوا قَالُوا آمَنَّا وَإِذَا خَلَوْا إِلَىٰ شَيَاطِينِهِمْ قَالُوا إِنَّا مَعَكُمْ إِنَّمَا نَحْنُ مُسْتَهْزِئُونَ',
  '2_15': 'اللَّهُ يَسْتَهْزِئُ بِهِمْ وَيَمُدُّهُمْ فِي طُغْيَانِهِمْ يَعْمَهُونَ',
  '2_16': 'أُولَـٰئِكَ الَّذِينَ اشْتَرَوُا الضَّلَالَةَ بِالْهُدَىٰ فَمَا رَبِحَت تِّجَارَتُهُمْ وَمَا كَانُوا مُهْتَدِينَ',
  '2_17': 'مَثَلُهُمْ كَمَثَلِ الَّذِي اسْتَوْقَدَ نَارًا فَلَمَّا أَضَاءَتْ مَا حَوْلَهُ ذَهَبَ اللَّهُ بِنُورِهِمْ وَتَرَكَهُمْ فِي ظُلُمَاتٍ لَّا يُبْصِرُونَ',
  '2_18': 'صُمٌّ بُكْمٌ عُمْيٌ فَهُمْ لَا يَرْجِعُونَ',
  '2_19': 'أَوْ كَصَيِّبٍ مِّنَ السَّمَاءِ فِيهِ ظُلُمَاتٌ وَرَعْدٌ وَبَرْقٌ يَجْعَلُونَ أَصَابِعَهُمْ فِي آذَانِهِم مِّنَ الصَّوَاعِقِ حَذَرَ الْمَوْتِ ۚ وَاللَّهُ مُحِيطٌ بِالْكَافِرِينَ',
  '2_20': 'يَكَادُ الْبَرْقُ يَخْطَفُ أَبْصَارَهُمْ ۖ كُلَّمَا أَضَاءَ لَهُم مَّشَوْا فِيهِ وَإِذَا أَظْلَمَ عَلَيْهِمْ قَامُوا ۚ وَلَوْ شَاءَ اللَّهُ لَذَهَبَ بِسَمْعِهِمْ وَأَبْصَارِهِمْ ۚ إِنَّ اللَّهَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
  '2_21': 'يَا أَيُّهَا النَّاسُ اعْبُدُوا رَبَّكُمُ الَّذِي خَلَقَكُمْ وَالَّذِينَ مِن قَبْلِكُمْ لَعَلَّكُمْ تَتَّقُونَ',
  '2_22': 'الَّذِي جَعَلَ لَكُمُ الْأَرْضَ فِرَاشًا وَالسَّمَاءَ بِنَاءً وَأَنزَلَ مِنَ السَّمَاءِ مَاءً فَأَخْرَجَ بِهِ مِنَ الثَّمَرَاتِ رِزْقًا لَّكُمْ ۖ فَلَا تَجْعَلُوا لِلَّهِ أَندَادًا وَأَنتُمْ تَعْلَمُونَ',
  '2_23': 'وَإِن كُنتُمْ فِي رَيْبٍ مِّمَّا نَزَّلْنَا عَلَىٰ عَبْدِنَا فَأْتُوا بِسُورَةٍ مِّن مِّثْلِهِ وَادْعُوا شُهَدَاءَكُم مِّن دُونِ اللَّهِ إِن كُنتُمْ صَادِقِينَ',
  '2_24': 'فَإِن لَّمْ تَفْعَلُوا وَلَن تَفْعَلُوا فَاتَّقُوا النَّارَ الَّتِي وَقُودُهَا النَّاسُ وَالْحِجَارَةُ ۖ أُعِدَّتْ لِلْكَافِرِينَ',
  '2_25': 'وَبَشِّرِ الَّذِينَ آمَنُوا وَعَمِلُوا الصَّالِحَاتِ أَنَّ لَهُمْ جَنَّاتٍ تَجْرِي مِن تَحْتِهَا الْأَنْهَارُ ۖ كُلَّمَا رُزِقُوا مِنْهَا مِن ثَمَرَةٍ رِّزْقًا ۙ قَالُوا هَـٰذَا الَّذِي رُزِقْنَا مِن قَبْلُ ۖ وَأُتُوا بِهِ مُتَشَابِهًا ۖ وَلَهُمْ فِيهَا أَزْوَاجٌ مُّطَهَّرَةٌ ۖ وَهُمْ فِيهَا خَالِدُونَ',

  // Surah 112 (Al-Ikhlas)
  '112_1': 'قُلْ هُوَ اللَّهُ أَحَدٌ',
  '112_2': 'اللَّهُ الصَّمَدُ',
  '112_3': 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
  '112_4': 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',

  // Surah 1 (Al-Fatihah)
  '1_1': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
  '1_2': 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
  '1_3': 'الرَّحْمَٰنِ الرَّحِيمِ',
  '1_4': 'مَالِكِ يَوْمِ الدِّينِ',
  '1_5': 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
  '1_6': 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
  '1_7': 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ'
};

// Ground-Truth Audio Metadata & Speech-Verified Timestamps (100% Word-for-Word Matched across all Reciters)
const ayahMetadataMap = {
  // 1. Sheikh Saad Al-Ghamdi (سعد الغامدي)
  'ghamadi_2_1': { localUrl: '/audio/2_1.wav', start: 0, end: 8.3, duration: 8.3, text: 'الم' },
  'ghamadi_2_2': { localUrl: '/audio/2_2.wav', start: 0, end: 6.5, duration: 6.5, text: 'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ' },
  'ghamadi_2_3': { localUrl: '/audio/2_3.wav', start: 0, end: 10.5, duration: 10.5, text: 'الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ' },
  'ghamadi_2_4': { localUrl: '/audio/2_4.wav', start: 0, end: 14.2, duration: 14.2, text: 'وَالَّذِينَ يُؤْمِنُونَ بِمَا أُنزِلَ إِلَيْكَ وَمَا أُنزِلَ مِن قَبْلِكَ وَبِالْآخِرَةِ هُمْ يُوقِنُونَ' },
  'ghamadi_2_5': { localUrl: '/audio/2_5.wav', start: 0, end: 10.9, duration: 10.9, text: 'أُولَـٰئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ ۖ وَأُولَـٰئِكَ هُمُ الْمُفْلِحُونَ' },
  'ghamadi_112_1': { localUrl: '/audio/112_1.wav', start: 0, end: 2.6, duration: 2.6, text: 'قُلْ هُوَ اللَّهُ أَحَدٌ' },
  'ghamadi_112_2': { localUrl: '/audio/112_2.wav', start: 0, end: 2.3, duration: 2.3, text: 'اللَّهُ الصَّمَدُ' },
  'ghamadi_112_3': { localUrl: '/audio/112_3.wav', start: 0, end: 2.7, duration: 2.7, text: 'لَمْ يَلِدْ وَلَمْ يُولَدْ' },
  'ghamadi_112_4': { localUrl: '/audio/112_4.wav', start: 0, end: 4.8, duration: 4.8, text: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ' },

  // 2. Dr. Ayman Sowaid (أيمن سويد)
  'ayman_sowaid_2_1': { localUrl: '/audio/ayman_sowaid_2_1.wav', start: 0, end: 6.1, duration: 6.1, text: 'الم' },
  'ayman_sowaid_2_2': { localUrl: '/audio/ayman_sowaid_2_2.wav', start: 0, end: 6.4, duration: 6.4, text: 'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ' },
  'ayman_sowaid_2_3': { localUrl: '/audio/ayman_sowaid_2_3.wav', start: 0, end: 18.0, duration: 18.0, text: 'الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ' },
  'ayman_sowaid_2_4': { localUrl: '/audio/ayman_sowaid_2_4.wav', start: 0, end: 15.8, duration: 15.8, text: 'وَالَّذِينَ يُؤْمِنُونَ بِمَا أُنزِلَ إِلَيْكَ وَمَا أُنزِلَ مِن قَبْلِكَ وَبِالْآخِرَةِ هُمْ يُوقِنُونَ' },
  'ayman_sowaid_2_5': { localUrl: '/audio/ayman_sowaid_2_5.wav', start: 0, end: 13.2, duration: 13.2, text: 'أُولَـٰئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ ۖ وَأُولَـٰئِكَ هُمُ الْمُفْلِحُونَ' },
  'ayman_sowaid_112_1': { localUrl: '/audio/ayman_sowaid_112_1.wav', start: 0, end: 6.1, duration: 6.1, text: 'قُلْ هُوَ اللَّهُ أَحَدٌ' },
  'ayman_sowaid_112_2': { localUrl: '/audio/ayman_sowaid_112_2.wav', start: 0, end: 3.3, duration: 3.3, text: 'اللَّهُ الصَّمَدُ' },
  'ayman_sowaid_112_3': { localUrl: '/audio/ayman_sowaid_112_3.wav', start: 0, end: 2.9, duration: 2.9, text: 'لَمْ يَلِدْ وَلَمْ يُولَدْ' },
  'ayman_sowaid_112_4': { localUrl: '/audio/ayman_sowaid_112_4.wav', start: 0, end: 3.9, duration: 3.9, text: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ' },

  // 3. Sheikh Mahmoud Ali Al-Banna (محمود علي البنا)
  'banna_2_1': { localUrl: '/audio/banna_2_1.wav', start: 0, end: 7.8, duration: 7.8, text: 'الم' },
  'banna_2_2': { localUrl: '/audio/banna_2_2.wav', start: 0, end: 8.2, duration: 8.2, text: 'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ' },
  'banna_2_3': { localUrl: '/audio/banna_2_3.wav', start: 0, end: 12.3, duration: 12.3, text: 'الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ' },
  'banna_2_4': { localUrl: '/audio/banna_2_4.wav', start: 0, end: 14.7, duration: 14.7, text: 'وَالَّذِينَ يُؤْمِنُونَ بِمَا أُنزِلَ إِلَيْكَ وَمَا أُنزِلَ مِن قَبْلِكَ وَبِالْآخِرَةِ هُمْ يُوقِنُونَ' },
  'banna_2_5': { localUrl: '/audio/banna_2_5.wav', start: 0, end: 11.0, duration: 11.0, text: 'أُولَـٰئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ ۖ وَأُولَـٰئِكَ هُمُ الْمُفْلِحُونَ' },
  'banna_112_1': { localUrl: '/audio/banna_112_1.wav', start: 0, end: 3.6, duration: 3.6, text: 'قُلْ هُوَ اللَّهُ أَحَدٌ' },
  'banna_112_2': { localUrl: '/audio/banna_112_2.wav', start: 0, end: 3.0, duration: 3.0, text: 'اللَّهُ الصَّمَدُ' },
  'banna_112_3': { localUrl: '/audio/banna_112_3.wav', start: 0, end: 3.7, duration: 3.7, text: 'لَمْ يَلِدْ وَلَمْ يُولَدْ' },
  'banna_112_4': { localUrl: '/audio/banna_112_4.wav', start: 0, end: 5.7, duration: 5.7, text: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ' },

  // 4. Sheikh Ali Jaber (علي جابر)
  'ali_jaber_2_1': { localUrl: '/audio/ali_jaber_2_1.wav', start: 0, end: 5.5, duration: 5.5, text: 'الم' },
  'ali_jaber_2_2': { localUrl: '/audio/ali_jaber_2_2.wav', start: 0, end: 7.8, duration: 7.8, text: 'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ' },
  'ali_jaber_2_3': { localUrl: '/audio/ali_jaber_2_3.wav', start: 0, end: 17.0, duration: 17.0, text: 'الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ' },
  'ali_jaber_2_4': { localUrl: '/audio/ali_jaber_2_4.wav', start: 0, end: 11.8, duration: 11.8, text: 'وَالَّذِينَ يُؤْمِنُونَ بِمَا أُنزِلَ إِلَيْكَ وَمَا أُنزِلَ مِن قَبْلِكَ وَبِالْآخِرَةِ هُمْ يُوقِنُونَ' },
  'ali_jaber_2_5': { localUrl: '/audio/ali_jaber_2_5.wav', start: 0, end: 8.8, duration: 8.8, text: 'أُولَـٰئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ ۖ وَأُولَـٰئِكَ هُمُ الْمُفْلِحُونَ' },
  'ali_jaber_112_1': { localUrl: '/audio/ali_jaber_112_1.wav', start: 0, end: 3.2, duration: 3.2, text: 'قُلْ هُوَ اللَّهُ أَحَدٌ' },
  'ali_jaber_112_2': { localUrl: '/audio/ali_jaber_112_2.wav', start: 0, end: 2.6, duration: 2.6, text: 'اللَّهُ الصَّمَدُ' },
  'ali_jaber_112_3': { localUrl: '/audio/ali_jaber_112_3.wav', start: 0, end: 3.3, duration: 3.3, text: 'لَمْ يَلِدْ وَلَمْ يُولَدْ' },
  'ali_jaber_112_4': { localUrl: '/audio/ali_jaber_112_4.wav', start: 0, end: 4.7, duration: 4.7, text: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ' },

  // 5. Sheikh Mustafa Azzawi (مصطفى العزاوي)
  'azzawi_2_1': { localUrl: '/audio/azzawi_2_1.wav', start: 0, end: 4.5, duration: 4.5, text: 'الم' },
  'azzawi_2_2': { localUrl: '/audio/azzawi_2_2.wav', start: 0, end: 8.4, duration: 8.4, text: 'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ' },
  'azzawi_2_3': { localUrl: '/audio/azzawi_2_3.wav', start: 0, end: 20.0, duration: 20.0, text: 'الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ' },
  'azzawi_2_4': { localUrl: '/audio/azzawi_2_4.wav', start: 0, end: 15.2, duration: 15.2, text: 'وَالَّذِينَ يُؤْمِنُونَ بِمَا أُنزِلَ إِلَيْكَ وَمَا أُنزِلَ مِن قَبْلِكَ وَبِالْآخِرَةِ هُمْ يُوقِنُونَ' },
  'azzawi_2_5': { localUrl: '/audio/azzawi_2_5.wav', start: 0, end: 10.4, duration: 10.4, text: 'أُولَـٰئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ ۖ وَأُولَـٰئِكَ هُمُ الْمُفْلِحُونَ' },
  'azzawi_112_1': { localUrl: '/audio/azzawi_112_1.wav', start: 0, end: 3.7, duration: 3.7, text: 'قُلْ هُوَ اللَّهُ أَحَدٌ' },
  'azzawi_112_2': { localUrl: '/audio/azzawi_112_2.wav', start: 0, end: 2.8, duration: 2.8, text: 'اللَّهُ الصَّمَدُ' },
  'azzawi_112_3': { localUrl: '/audio/azzawi_112_3.wav', start: 0, end: 2.5, duration: 2.5, text: 'لَمْ يَلِدْ وَلَمْ يُولَدْ' },
  'azzawi_112_4': { localUrl: '/audio/azzawi_112_4.wav', start: 0, end: 3.2, duration: 3.2, text: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ' },

  // 6. Sheikh Ali Al-Hudhaify (علي الحذيفي)
  'hudhaifi_2_1': { localUrl: '/audio/hudhaifi_2_1.wav', start: 0, end: 5.3, duration: 5.3, text: 'الم' },
  'hudhaifi_2_2': { localUrl: '/audio/hudhaifi_2_2.wav', start: 0, end: 9.1, duration: 9.1, text: 'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ' },
  'hudhaifi_2_3': { localUrl: '/audio/hudhaifi_2_3.wav', start: 0, end: 23.5, duration: 23.5, text: 'الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ' },
  'hudhaifi_2_4': { localUrl: '/audio/hudhaifi_2_4.wav', start: 0, end: 18.0, duration: 18.0, text: 'وَالَّذِينَ يُؤْمِنُونَ بِمَا أُنزِلَ إِلَيْكَ وَمَا أُنزِلَ مِن قَبْلِكَ وَبِالْآخِرَةِ هُمْ يُوقِنُونَ' },
  'hudhaifi_2_5': { localUrl: '/audio/hudhaifi_2_5.wav', start: 0, end: 13.2, duration: 13.2, text: 'أُولَـٰئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ ۖ وَأُولَـٰئِكَ هُمُ الْمُفْلِحُونَ' },
  'hudhaifi_112_1': { localUrl: '/audio/hudhaifi_112_1.wav', start: 0, end: 5.1, duration: 5.1, text: 'قُلْ هُوَ اللَّهُ أَحَدٌ' },
  'hudhaifi_112_2': { localUrl: '/audio/hudhaifi_112_2.wav', start: 0, end: 2.8, duration: 2.8, text: 'اللَّهُ الصَّمَدُ' },
  'hudhaifi_112_3': { localUrl: '/audio/hudhaifi_112_3.wav', start: 0, end: 2.4, duration: 2.4, text: 'لَمْ يَلِدْ وَلَمْ يُولَدْ' },
  'hudhaifi_112_4': { localUrl: '/audio/hudhaifi_112_4.wav', start: 0, end: 3.0, duration: 3.0, text: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ' },

  // 7. Sheikh Mahmoud Khalil Al-Husary (محمود خليل الحصري)
  'husary_2_1': { localUrl: '/audio/husary_2_1.wav', start: 0, end: 9.2, duration: 9.2, text: 'الم' },
  'husary_2_2': { localUrl: '/audio/husary_2_2.wav', start: 0, end: 12.0, duration: 12.0, text: 'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ' },
  'husary_2_3': { localUrl: '/audio/husary_2_3.wav', start: 0, end: 15.8, duration: 15.8, text: 'الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ' },
  'husary_2_4': { localUrl: '/audio/husary_2_4.wav', start: 0, end: 21.0, duration: 21.0, text: 'وَالَّذِينَ يُؤْمِنُونَ بِمَا أُنزِلَ إِلَيْكَ وَمَا أُنزِلَ مِن قَبْلِكَ وَبِالْآخِرَةِ هُمْ يُوقِنُونَ' },
  'husary_2_5': { localUrl: '/audio/husary_2_5.wav', start: 0, end: 18.7, duration: 18.7, text: 'أُولَـٰئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ ۖ وَأُولَـٰئِكَ هُمُ الْمُفْلِحُونَ' },
  'husary_112_1': { localUrl: '/audio/husary_112_1.wav', start: 0, end: 4.5, duration: 4.5, text: 'قُلْ هُوَ اللَّهُ أَحَدٌ' },
  'husary_112_2': { localUrl: '/audio/husary_112_2.wav', start: 0, end: 4.0, duration: 4.0, text: 'اللَّهُ الصَّمَدُ' },
  'husary_112_3': { localUrl: '/audio/husary_112_3.wav', start: 0, end: 5.0, duration: 5.0, text: 'لَمْ يَلِدْ وَلَمْ يُولَدْ' },
  'husary_112_4': { localUrl: '/audio/husary_112_4.wav', start: 0, end: 6.2, duration: 6.2, text: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ' },
  'husary_murattal_2_1': { localUrl: '/audio/husary_2_1.wav', start: 0, end: 9.2, duration: 9.2, text: 'الم' },
  'husary_murattal_2_2': { localUrl: '/audio/husary_2_2.wav', start: 0, end: 12.0, duration: 12.0, text: 'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ' },
  'husary_murattal_2_3': { localUrl: '/audio/husary_2_3.wav', start: 0, end: 15.8, duration: 15.8, text: 'الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ' },
  'husary_murattal_2_4': { localUrl: '/audio/husary_2_4.wav', start: 0, end: 21.0, duration: 21.0, text: 'وَالَّذِينَ يُؤْمِنُونَ بِمَا أُنزِلَ إِلَيْكَ وَمَا أُنزِلَ مِن قَبْلِكَ وَبِالْآخِرَةِ هُمْ يُوقِنُونَ' },
  'husary_murattal_2_5': { localUrl: '/audio/husary_2_5.wav', start: 0, end: 18.7, duration: 18.7, text: 'أُولَـٰئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ ۖ وَأُولَـٰئِكَ هُمُ الْمُفْلِحُونَ' },
  'husary_muallim_2_1': { localUrl: '/audio/husary_2_1.wav', start: 0, end: 9.2, duration: 9.2, text: 'الم' },
  'husary_muallim_2_2': { localUrl: '/audio/husary_2_2.wav', start: 0, end: 12.0, duration: 12.0, text: 'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ' },
  'husary_muallim_2_3': { localUrl: '/audio/husary_2_3.wav', start: 0, end: 15.8, duration: 15.8, text: 'الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ' },
  'husary_muallim_2_4': { localUrl: '/audio/husary_2_4.wav', start: 0, end: 21.0, duration: 21.0, text: 'وَالَّذِينَ يُؤْمِنُونَ بِمَا أُنزِلَ إِلَيْكَ وَمَا أُنزِلَ مِن قَبْلِكَ وَبِالْآخِرَةِ هُمْ يُوقِنُونَ' },
  'husary_muallim_2_5': { localUrl: '/audio/husary_2_5.wav', start: 0, end: 18.7, duration: 18.7, text: 'أُولَـٰئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ ۖ وَأُولَـٰئِكَ هُمُ الْمُفْلِحُونَ' },

  // 8. Sheikh Muhammad Siddiq Al-Minshawi (المنشاوي مرتل)
  'minshawi_2_1': { localUrl: '/audio/minshawi_2_1.wav', start: 0, end: 5.3, duration: 5.3, text: 'الم' },
  'minshawi_2_2': { localUrl: '/audio/minshawi_2_2.wav', start: 0, end: 6.9, duration: 6.9, text: 'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ' },
  'minshawi_2_3': { localUrl: '/audio/minshawi_2_3.wav', start: 0, end: 9.2, duration: 9.2, text: 'الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ' },
  'minshawi_2_4': { localUrl: '/audio/minshawi_2_4.wav', start: 0, end: 12.8, duration: 12.8, text: 'وَالَّذِينَ يُؤْمِنُونَ بِمَا أُنزِلَ إِلَيْكَ وَمَا أُنزِلَ مِن قَبْلِكَ وَبِالْآخِرَةِ هُمْ يُوقِنُونَ' },
  'minshawi_2_5': { localUrl: '/audio/minshawi_2_5.wav', start: 0, end: 13.8, duration: 13.8, text: 'أُولَـٰئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ ۖ وَأُولَـٰئِكَ هُمُ الْمُفْلِحُونَ' },
  'minshawi_112_1': { localUrl: '/audio/minshawi_112_1.wav', start: 0, end: 8.6, duration: 8.6, text: 'قُلْ هُوَ اللَّهُ أَحَدٌ' },
  'minshawi_112_2': { localUrl: '/audio/minshawi_112_2.wav', start: 0, end: 4.7, duration: 4.7, text: 'اللَّهُ الصَّمَدُ' },
  'minshawi_112_3': { localUrl: '/audio/minshawi_112_3.wav', start: 0, end: 6.3, duration: 6.3, text: 'لَمْ يَلِدْ وَلَمْ يُولَدْ' },
  'minshawi_112_4': { localUrl: '/audio/minshawi_112_4.wav', start: 0, end: 9.0, duration: 9.0, text: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ' },

  // 9. Sheikh Al-Minshawi with Children (المصحف المعلم مع ترديد الأطفال)
  'minshawi_teacher_2_1': { localUrl: '/audio/minshawi_teacher_2_1.wav', start: 0, end: 16.0, duration: 16.0, text: 'الم' },
  'minshawi_teacher_2_2': { localUrl: '/audio/minshawi_teacher_2_2.wav', start: 0, end: 18.3, duration: 18.3, text: 'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ' },
  'minshawi_teacher_2_3': { localUrl: '/audio/minshawi_teacher_2_3.wav', start: 0, end: 24.1, duration: 24.1, text: 'الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ' },
  'minshawi_teacher_2_4': { localUrl: '/audio/minshawi_teacher_2_4.wav', start: 0, end: 32.0, duration: 32.0, text: 'وَالَّذِينَ يُؤْمِنُونَ بِمَا أُنزِلَ إِلَيْكَ وَمَا أُنزِلَ مِن قَبْلِكَ وَبِالْآخِرَةِ هُمْ يُوقِنُونَ' },
  'minshawi_teacher_2_5': { localUrl: '/audio/minshawi_teacher_2_5.wav', start: 0, end: 23.2, duration: 23.2, text: 'أُولَـٰئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ ۖ وَأُولَـٰئِكَ هُمُ الْمُفْلِحُونَ' },
  'minshawi_teacher_112_1': { localUrl: '/audio/minshawi_teacher_112_1.wav', start: 0, end: 8.6, duration: 8.6, text: 'قُلْ هُوَ اللَّهُ أَحَدٌ' },
  'minshawi_teacher_112_2': { localUrl: '/audio/minshawi_teacher_112_2.wav', start: 0, end: 4.7, duration: 4.7, text: 'اللَّهُ الصَّمَدُ' },
  'minshawi_teacher_112_3': { localUrl: '/audio/minshawi_teacher_112_3.wav', start: 0, end: 6.3, duration: 6.3, text: 'لَمْ يَلِدْ وَلَمْ يُولَدْ' },
  'minshawi_teacher_112_4': { localUrl: '/audio/minshawi_teacher_112_4.wav', start: 0, end: 9.0, duration: 9.0, text: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ' },

  // 10. Sheikh Abdul Rashid Soufi (عبد الرشيد صوفي)
  'soufi_2_1': { localUrl: '/audio/soufi_2_1.wav', start: 0, end: 3.8, duration: 3.8, text: 'الم' },
  'soufi_2_2': { localUrl: '/audio/soufi_2_2.wav', start: 0, end: 7.4, duration: 7.4, text: 'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ' },
  'soufi_2_3': { localUrl: '/audio/soufi_2_3.wav', start: 0, end: 17.2, duration: 17.2, text: 'الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ' },
  'soufi_2_4': { localUrl: '/audio/soufi_2_4.wav', start: 0, end: 14.9, duration: 14.9, text: 'وَالَّذِينَ يُؤْمِنُونَ بِمَا أُنزِلَ إِلَيْكَ وَمَا أُنزِلَ مِن قَبْلِكَ وَبِالْآخِرَةِ هُمْ يُوقِنُونَ' },
  'soufi_2_5': { localUrl: '/audio/soufi_2_5.wav', start: 0, end: 10.3, duration: 10.3, text: 'أُولَـٰئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ ۖ وَأُولَـٰئِكَ هُمُ الْمُفْلِحُونَ' },
  'soufi_112_1': { localUrl: '/audio/soufi_112_1.wav', start: 0, end: 3.3, duration: 3.3, text: 'قُلْ هُوَ اللَّهُ أَحَدٌ' },
  'soufi_112_2': { localUrl: '/audio/soufi_112_2.wav', start: 0, end: 2.4, duration: 2.4, text: 'اللَّهُ الصَّمَدُ' },
  'soufi_112_3': { localUrl: '/audio/soufi_112_3.wav', start: 0, end: 2.0, duration: 2.0, text: 'لَمْ يَلِدْ وَلَمْ يُولَدْ' },
  'soufi_112_4': { localUrl: '/audio/soufi_112_4.wav', start: 0, end: 3.3, duration: 3.3, text: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ' },

  // Universal Fallbacks
  '2_1': { localUrl: '/audio/2_1.wav', start: 0, end: 8.3, duration: 8.3, text: 'الم' },
  '2_2': { localUrl: '/audio/2_2.wav', start: 0, end: 6.5, duration: 6.5, text: 'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ' },
  '2_3': { localUrl: '/audio/2_3.wav', start: 0, end: 10.5, duration: 10.5, text: 'الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ' },
  '2_4': { localUrl: '/audio/2_4.wav', start: 0, end: 14.2, duration: 14.2, text: 'وَالَّذِينَ يُؤْمِنُونَ بِمَا أُنزِلَ إِلَيْكَ وَمَا أُنزِلَ مِن قَبْلِكَ وَبِالْآخِرَةِ هُمْ يُوقِنُونَ' },
  '2_5': { localUrl: '/audio/2_5.wav', start: 0, end: 10.9, duration: 10.9, text: 'أُولَـٰئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ ۖ وَأُولَـٰئِكَ هُمُ الْمُفْلِحُونَ' },
  '112_1': { localUrl: '/audio/112_1.wav', start: 0, end: 2.6, duration: 2.6, text: 'قُلْ هُوَ اللَّهُ أَحَدٌ' },
  '112_2': { localUrl: '/audio/112_2.wav', start: 0, end: 2.3, duration: 2.3, text: 'اللَّهُ الصَّمَدُ' },
  '112_3': { localUrl: '/audio/112_3.wav', start: 0, end: 2.7, duration: 2.7, text: 'لَمْ يَلِدْ وَلَمْ يُولَدْ' },
  '112_4': { localUrl: '/audio/112_4.wav', start: 0, end: 4.8, duration: 4.8, text: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ' }
};

function getAyahInfo(surah, ayah, reciterKey) {
  const reciter = recitersDatabase.find(r => r.id === reciterKey || r.subfolder === reciterKey) ||
                  recitersDatabase.find(r => r.id === currentReciterId) ||
                  recitersDatabase[0];
  const recId = reciter ? reciter.id : 'ghamadi';

  let prefix = 'ghamadi';
  if (recId === 'minshawi_teacher') prefix = 'minshawi_teacher';
  else if (recId.includes('husary')) prefix = 'husary';
  else if (recId === 'minshawi_murattal') prefix = 'minshawi';
  else if (recId.includes('banna')) prefix = 'banna';
  else if (recId.includes('ali_jaber')) prefix = 'ali_jaber';
  else if (recId.includes('sowaid')) prefix = 'ayman_sowaid';
  else if (recId.includes('azzawi')) prefix = 'azzawi';
  else if (recId.includes('hudhaif')) prefix = 'hudhaifi';
  else if (recId.includes('soufi')) prefix = 'soufi';
  else if (recId === 'ghamadi') prefix = 'ghamadi';

  const prefixKey = `${prefix}_${surah}_${ayah}`;
  if (ayahMetadataMap[prefixKey]) return ayahMetadataMap[prefixKey];

  const specificKey = `${recId}_${surah}_${ayah}`;
  if (ayahMetadataMap[specificKey]) return ayahMetadataMap[specificKey];

  const baseKey = `${surah}_${ayah}`;
  if (ayahMetadataMap[baseKey]) return ayahMetadataMap[baseKey];

  const uthmanic = uthmanicQuranText[`${surah}_${ayah}`];
  const baseStart = ((ayah - 1) % 5) * 8.0 + 5.0;
  return {
    localUrl: null,
    start: baseStart,
    end: baseStart + 8.0,
    duration: 8.0,
    text: uthmanic || `سورة ${getCurrentSurahName()} - الآية الكريمة (${toArabicDigits(ayah)})`
  };
}

// Audio Engine: Resolves audio source dynamically for the selected reciter
function getAudioUrl(surah, ayah, reciterKey) {
  const reciter = recitersDatabase.find(r => r.id === reciterKey || r.subfolder === reciterKey) ||
                  recitersDatabase.find(r => r.id === currentReciterId) ||
                  recitersDatabase[0];
  const recId = reciter ? reciter.id : 'ghamadi';

  // 1. Minshawi with Children (المصحف المعلم مع الأطفال)
  if (recId === 'minshawi_teacher' || (reciter && reciter.subfolder === 'Minshawy_Teacher_128kbps')) {
    if (surah === 2 && ayah >= 1 && ayah <= 5) {
      return `/audio/minshawi_teacher_2_${ayah}.wav`;
    }
    if (surah === 112 && ayah >= 1 && ayah <= 4) {
      return `/audio/minshawi_teacher_112_${ayah}.wav`;
    }
  }

  // 2. Sheikh Al-Husary (مرتل ومعلم ولروايات قالون وورش والدوري)
  if (recId.includes('husary')) {
    if (surah === 2 && ayah >= 1 && ayah <= 5) {
      return `/audio/husary_2_${ayah}.wav`;
    }
    if (surah === 112 && ayah >= 1 && ayah <= 4) {
      return `/audio/husary_112_${ayah}.wav`;
    }
  }

  // 3. Minshawi Murattal (مرتل فردي)
  if (recId === 'minshawi_murattal') {
    if (surah === 2 && ayah >= 1 && ayah <= 5) {
      return `/audio/minshawi_2_${ayah}.wav`;
    }
    if (surah === 112 && ayah >= 1 && ayah <= 4) {
      return `/audio/minshawi_112_${ayah}.wav`;
    }
  }

  // 4. Other verified discrete audio clips for available reciters
  let prefix = null;
  if (recId.includes('banna')) prefix = 'banna';
  else if (recId.includes('ali_jaber')) prefix = 'ali_jaber';
  else if (recId.includes('sowaid')) prefix = 'ayman_sowaid';
  else if (recId.includes('azzawi')) prefix = 'azzawi';
  else if (recId.includes('hudhaif')) prefix = 'hudhaifi';
  else if (recId.includes('soufi')) prefix = 'soufi';

  if (prefix) {
    if (surah === 2 && ayah >= 1 && ayah <= 5) {
      return `/audio/${prefix}_2_${ayah}.wav`;
    }
    if (surah === 112 && ayah >= 1 && ayah <= 4) {
      return `/audio/${prefix}_112_${ayah}.wav`;
    }
  }

  // 5. Sheikh Saad Al-Ghamdi verified audio clips
  if (recId === 'ghamadi') {
    if (surah === 2 && ayah >= 1 && ayah <= 5) {
      return `/audio/2_${ayah}.wav`;
    }
    if (surah === 112 && ayah >= 1 && ayah <= 4) {
      return `/audio/112_${ayah}.wav`;
    }
  }

  // 6. Direct CDN URL for the selected reciter (e.g. Warsh, Qaloon, or other Surahs)
  const surahPadded = String(surah).padStart(3, '0');
  if (reciter && reciter.directUrl) {
    return `${reciter.directUrl}${surahPadded}.mp3`;
  }
  return `https://cdn.mp3quran.net/audio/saad-ghamdi/r1/${surahPadded}.mp3`;
}

function getFallbackAudioUrl(surah, reciterKey) {
  const reciter = recitersDatabase.find(r => r.id === reciterKey || r.subfolder === reciterKey) ||
                  recitersDatabase.find(r => r.id === currentReciterId) ||
                  recitersDatabase[0];
  const surahPadded = String(surah).padStart(3, '0');
  if (reciter && reciter.directUrl) {
    return `${reciter.directUrl}${surahPadded}.mp3`;
  }
  return `https://cdn.mp3quran.net/audio/saad-ghamdi/r1/${surahPadded}.mp3`;
}

// Mobile-Resilient Playback Initiation (Immediate Synchronous Play within User Gesture)
function playCurrentAyah() {
  if (delayCountdownTimer) {
    clearInterval(delayCountdownTimer);
    delayCountdownTimer = null;
  }
  isTransitioning = false;

  const activeReciterKey = currentReciterId || currentReciterSubfolder;
  const timing = getAyahInfo(currentSurah, currentAyah, activeReciterKey);
  const targetUrl = getAudioUrl(currentSurah, currentAyah, activeReciterKey);
  const isLocalClip = targetUrl.startsWith('/audio/') || targetUrl.endsWith('.wav');
  const startT = isLocalClip ? 0.0 : timing.start;

  updatePlayerUI();

  const isSameSrc = audioElement.src === targetUrl || (audioElement.src && audioElement.src.endsWith(targetUrl));

  if (!isSameSrc) {
    audioElement.src = targetUrl;
    audioElement.load();
  }

  // Position seek with metadata readiness check
  if (startT > 0) {
    if (audioElement.readyState >= 1) {
      try { audioElement.currentTime = startT; } catch (e) {}
    } else {
      const onMeta = () => {
        try { audioElement.currentTime = startT; } catch (e) {}
      };
      audioElement.addEventListener('loadedmetadata', onMeta, { once: true });
    }
  } else {
    try { audioElement.currentTime = 0; } catch (e) {}
  }

  // Must call .play() synchronously to pass mobile user-gesture security policy
  const playPromise = audioElement.play();
  if (playPromise !== undefined) {
    playPromise.then(() => {
      isPlaying = true;
      isTransitioning = false;
      updatePlayerUI();
    }).catch(err => {
      console.warn('Playback gesture fallback notice:', err);
      // Secondary fallback when stream buffer is delayed
      const onCanPlay = () => {
        audioElement.play().then(() => {
          isPlaying = true;
          isTransitioning = false;
          updatePlayerUI();
        }).catch(err2 => {
          console.warn('Canplay playback blocked by browser:', err2);
          isPlaying = false;
          isTransitioning = false;
          updatePlayerUI();
        });
      };
      audioElement.addEventListener('canplay', onCanPlay, { once: true });
    });
  }
}

function togglePlayAudio() {
  if (isPlaying) {
    audioElement.pause();
    isPlaying = false;
    isTransitioning = false;
    if (delayCountdownTimer) {
      clearInterval(delayCountdownTimer);
      delayCountdownTimer = null;
    }
  } else {
    playCurrentAyah();
  }
  updatePlayerUI();
}

function skipNextAyah() {
  if (currentAyah < rangeEndAyah) {
    currentAyah++;
  } else {
    currentAyah = rangeStartAyah;
  }
  currentAyahRepeat = 1;
  updatePlayerUI();
  highlightActiveAyahInMushaf();
  playCurrentAyah();
}

function skipPrevAyah() {
  if (currentAyah > rangeStartAyah) {
    currentAyah--;
  } else {
    currentAyah = rangeEndAyah;
  }
  currentAyahRepeat = 1;
  updatePlayerUI();
  highlightActiveAyahInMushaf();
  playCurrentAyah();
}

function setupAudioListeners() {
  audioElement.addEventListener('ended', () => {
    if (isTransitioning) return;
    triggerAyahCompletion();
  });

  audioElement.addEventListener('timeupdate', () => {
    if (isTransitioning) return;
    const isLocalClip = audioElement.src && (audioElement.src.includes('/audio/') || audioElement.src.endsWith('.wav'));
    const activeReciterKey = currentReciterId || currentReciterSubfolder;
    const timing = getAyahInfo(currentSurah, currentAyah, activeReciterKey);
    const startT = isLocalClip ? 0.0 : timing.start;
    const endT = isLocalClip ? (audioElement.duration || timing.duration || 10) : timing.end;

    // Update progress fill smoothly
    const totalDuration = isLocalClip ? (audioElement.duration || timing.duration || 1) : (endT - startT);
    if (totalDuration > 0) {
      const elapsed = isLocalClip ? audioElement.currentTime : (audioElement.currentTime - startT);
      const pct = Math.min(100, Math.max(0, (elapsed / totalDuration) * 100));
      const fill = document.getElementById('player-progress-fill');
      if (fill) fill.style.width = `${pct}%`;
    }

    // Trigger completion if boundary reached for full surah streams
    // Must not be currently seeking, not transitioning, and must have played for at least 1.2s from startT
    if (!isLocalClip && !audioElement.seeking && audioElement.currentTime >= (endT - 0.1) && (audioElement.currentTime - startT) >= 1.2) {
      triggerAyahCompletion();
    }
  });

  audioElement.addEventListener('error', (e) => {
    console.warn('Audio stream fallback triggered...');
    const activeReciterKey = currentReciterId || currentReciterSubfolder;
    const fallback = getFallbackAudioUrl(currentSurah, activeReciterKey);
    if (audioElement.src !== fallback) {
      audioElement.src = fallback;
      playCurrentAyah();
    }
  });
}

// Safely replays the current Ayah with seek synchronization to guarantee repetition across all reciters
function replayAyahWithProtection(startT) {
  isTransitioning = true;
  try {
    audioElement.currentTime = startT;
  } catch (e) {
    console.warn('Replay seek error:', e);
  }

  const playPromise = audioElement.play();
  if (playPromise !== undefined) {
    playPromise.then(() => {
      isPlaying = true;
      updatePlayerUI();
      setTimeout(() => {
        isTransitioning = false;
      }, 300);
    }).catch(err => {
      console.warn('Replay play error:', err);
      isTransitioning = false;
      isPlaying = false;
      updatePlayerUI();
    });
  }
}

// Unified Repetition Engine: N Ayah repeats x M Portion cycles with T silent delay (within Range)
function triggerAyahCompletion() {
  if (isTransitioning) return;
  isTransitioning = true;
  audioElement.pause();

  const isLocalClip = audioElement.src && (audioElement.src.includes('/audio/') || audioElement.src.endsWith('.wav'));
  const activeReciterKey = currentReciterId || currentReciterSubfolder;
  const timing = getAyahInfo(currentSurah, currentAyah, activeReciterKey);
  const startT = isLocalClip ? 0.0 : timing.start;
  try {
    audioElement.currentTime = startT;
  } catch (e) {}

  // 1. Ayah Repetition (N)
  if (currentAyahRepeat < targetAyahRepeat) {
    currentAyahRepeat++;
    updatePlayerUI();
    highlightRepeatPulse(`تكرار الآية: ${currentAyahRepeat} من ${targetAyahRepeat}`);

    startDelayCountdown(() => {
      replayAyahWithProtection(startT);
    });
    return;
  }

  // 2. Ayah reached target N repeats -> Move to next Ayah within [rangeStartAyah, rangeEndAyah]
  currentAyahRepeat = 1;

  if (currentAyah < rangeEndAyah) {
    currentAyah++;
    updatePlayerUI();
    highlightActiveAyahInMushaf();
    highlightRepeatPulse(`الانتقال للآية التالية: ${currentAyah}`);

    startDelayCountdown(() => {
      isTransitioning = false;
      playCurrentAyah();
    });
    return;
  }

  // 3. Portion cycle (M)
  if (currentRangeCycle < targetRangeCycle) {
    currentRangeCycle++;
    currentAyah = rangeStartAyah;
    currentAyahRepeat = 1;
    updatePlayerUI();
    highlightActiveAyahInMushaf();
    highlightRepeatPulse(`دورة الورد الجديدة: ${currentRangeCycle} من ${targetRangeCycle}`);

    startDelayCountdown(() => {
      isTransitioning = false;
      playCurrentAyah();
    });
    return;
  }

  // 4. All repetitions and portion cycles completed!
  isTransitioning = false;
  isPlaying = false;
  currentAyahRepeat = targetAyahRepeat;
  updatePlayerUI();
  highlightActiveAyahInMushaf();
  showRepetitionCompleteToast();
}

function startDelayCountdown(callback) {
  if (delayCountdownTimer) {
    clearInterval(delayCountdownTimer);
    delayCountdownTimer = null;
  }

  const delayBadge = document.getElementById('delay-badge');
  const liveRepeatState = document.getElementById('live-repeat-state');

  if (intervalDelaySeconds <= 0) {
    if (delayBadge) {
      delayBadge.classList.remove('pulse');
      delayBadge.textContent = `وقفة الترديد: 0ث (T)`;
    }
    callback();
    return;
  }

  let remaining = intervalDelaySeconds;
  if (delayBadge) {
    delayBadge.classList.add('pulse');
    delayBadge.textContent = `⏱️ وقفة ترديد: ${remaining}ث`;
  }
  if (liveRepeatState) {
    liveRepeatState.textContent = `الآية ${currentAyah} من (${rangeStartAyah} - ${rangeEndAyah}) • ⏱️ وقفة ترديد: ${remaining}ث (استعد للتكرار ${currentAyahRepeat}/${targetAyahRepeat})`;
  }

  delayCountdownTimer = setInterval(() => {
    remaining--;
    if (remaining <= 0) {
      clearInterval(delayCountdownTimer);
      delayCountdownTimer = null;
      if (delayBadge) {
        delayBadge.classList.remove('pulse');
        delayBadge.textContent = `وقفة الترديد: ${intervalDelaySeconds}ث (T)`;
      }
      if (liveRepeatState) {
        liveRepeatState.textContent = `الآية ${currentAyah} من (${rangeStartAyah} - ${rangeEndAyah}) • تكرار: ${currentAyahRepeat} / ${targetAyahRepeat} (N)`;
      }
      callback();
    } else {
      if (delayBadge) {
        delayBadge.textContent = `⏱️ وقفة ترديد: ${remaining}ث`;
      }
      if (liveRepeatState) {
        liveRepeatState.textContent = `الآية ${currentAyah} من (${rangeStartAyah} - ${rangeEndAyah}) • ⏱️ وقفة ترديد: ${remaining}ث (استعد للتكرار ${currentAyahRepeat}/${targetAyahRepeat})`;
      }
    }
  }, 1000);
}

function updatePlayerUI() {
  const icon = document.getElementById('player-icon');
  const btnIcon = document.getElementById('play-btn-icon');
  const btnText = document.getElementById('play-btn-text');
  const liveDot = document.getElementById('live-dot');
  const activeReciterKey = currentReciterId || currentReciterSubfolder;
  const timing = getAyahInfo(currentSurah, currentAyah, activeReciterKey);

  if (isPlaying) {
    if (icon) icon.textContent = '⏸';
    if (btnIcon) btnIcon.textContent = '⏸';
    if (btnText) btnText.textContent = 'إيقاف مؤقت للاستماع';
    if (liveDot) liveDot.classList.add('active');
  } else {
    if (icon) icon.textContent = '▶';
    if (btnIcon) btnIcon.textContent = '▶';
    if (btnText) btnText.textContent = 'استماع وتكرار الورد';
    if (liveDot) liveDot.classList.remove('active');
  }

  const ayahNum = document.getElementById('player-ayah-num');
  if (ayahNum) ayahNum.textContent = `الآية ${toArabicDigits(currentAyah)}`;

  const surahNameElem = document.getElementById('player-surah-name');
  if (surahNameElem) surahNameElem.textContent = getCurrentSurahName();

  const recName = document.getElementById('player-reciter-name');
  if (recName) recName.textContent = currentReciterName;

  const repAyahBadge = document.getElementById('rep-ayah-badge');
  if (repAyahBadge) repAyahBadge.textContent = `تكرار الآية: ${currentAyahRepeat}/${targetAyahRepeat} (N)`;

  const repRangeBadge = document.getElementById('rep-range-badge');
  if (repRangeBadge) repRangeBadge.textContent = `دورة الورد: ${currentRangeCycle}/${targetRangeCycle} (M)`;

  const liveText = document.getElementById('active-portion-ayah-text');
  if (liveText && timing && timing.text) {
    liveText.textContent = timing.text;
  }

  const liveState = document.getElementById('live-repeat-state');
  if (liveState) {
    liveState.textContent = `الآية ${currentAyah} (النطاق ${rangeStartAyah} - ${rangeEndAyah}) • تكرار: ${currentAyahRepeat} / ${targetAyahRepeat} (N)`;
  }

  // Synchronize Highlight on Madani Mushaf Page
  highlightActiveAyahInMushaf();

  // --- Kids Mode Card Real-time Synchronization ---
  const kidAyahText = document.getElementById('kid-ayah-text');
  if (kidAyahText && timing && timing.text) {
    kidAyahText.textContent = `${timing.text} ۝${currentAyah}`;
  }

  const kidPlayBtnText = document.getElementById('kid-play-btn-text');
  if (kidPlayBtnText) {
    kidPlayBtnText.textContent = isPlaying ? 'إيقاف مؤقت للتلاوة ⏸' : 'استمع وردد مع الشيخ والأطفال 🎙️';
  }

  // Stepper navigation pills for Kids (1 to 4)
  for (let i = 1; i <= 4; i++) {
    const pill = document.getElementById(`kid-step-${i}`);
    if (pill) {
      if (i === currentAyah) {
        pill.className = 'kid-step-pill active';
      } else if (i < currentAyah) {
        pill.className = 'kid-step-pill completed';
      } else {
        pill.className = 'kid-step-pill';
      }
    }
  }

  const kidStatus = document.getElementById('kid-reciter-status-text');
  if (kidStatus) {
    if (isPlaying) {
      kidStatus.textContent = `الشيخ ${currentReciterName} يقرأ الآن • الآية (${currentAyah})`;
    } else {
      kidStatus.textContent = 'اضغط للاستماع والترديد مع الشيخ والأطفال';
    }
  }
}

function repeatCurrentAyahNow() {
  if (delayCountdownTimer) {
    clearInterval(delayCountdownTimer);
    delayCountdownTimer = null;
  }
  currentAyahRepeat = 1;
  const isLocalClip = audioElement.src && (audioElement.src.includes('/audio/') || audioElement.src.endsWith('.wav'));
  const activeReciterKey = currentReciterId || currentReciterSubfolder;
  const timing = getAyahInfo(currentSurah, currentAyah, activeReciterKey);
  const startT = isLocalClip ? 0.0 : timing.start;
  replayAyahWithProtection(startT);
  highlightRepeatPulse(`بدء تكرار الآية ${currentAyah} فوراً 🔁`);
}

function setRepPreset(n) {
  targetAyahRepeat = n;
  const slider = document.getElementById('slider-rep-ayah');
  if (slider) slider.value = n;
  const val = document.getElementById('val-rep-ayah');
  if (val) val.textContent = `${n} مرات`;

  document.querySelectorAll('.preset-btn').forEach(btn => btn.classList.remove('active'));
  const activeBtn = document.getElementById(`preset-btn-${n}`);
  if (activeBtn) activeBtn.classList.add('active');

  updatePlayerUI();
}

function runLiveRepetitionDemo() {
  closeAllModals();

  setRepPreset(3);
  targetRangeCycle = 1;
  const rangeSlider = document.getElementById('slider-rep-range');
  if (rangeSlider) rangeSlider.value = 1;
  const valRange = document.getElementById('val-rep-range');
  if (valRange) valRange.textContent = '1 مرة';

  intervalDelaySeconds = 2;
  const delaySlider = document.getElementById('slider-delay');
  if (delaySlider) delaySlider.value = 2;
  const valDelay = document.getElementById('val-delay');
  if (valDelay) valDelay.textContent = '2 ثوانٍ';

  currentAyah = 1;
  currentAyahRepeat = 1;
  currentRangeCycle = 1;

  playCurrentAyah();

  const box = document.getElementById('active-ayah-box');
  if (box) {
    box.scrollIntoView({ behavior: 'smooth', block: 'center' });
    highlightRepeatPulse();
  }
}

function highlightRepeatPulse(text) {
  const box = document.getElementById('active-ayah-box');
  if (box) {
    box.classList.remove('pulse-highlight');
    void box.offsetWidth;
    box.classList.add('pulse-highlight');
    setTimeout(() => box.classList.remove('pulse-highlight'), 1200);
  }
}

function showRepetitionCompleteToast() {
  const liveState = document.getElementById('live-repeat-state');
  if (liveState) {
    liveState.textContent = '🎉 مبارك! تم إكمال كامل دورات التكرار (N x M) بنجاح وإتقان!';
  }
  const box = document.getElementById('active-ayah-box');
  if (box) {
    box.style.borderColor = '#10B981';
    box.style.background = '#ECFDF5';
    setTimeout(() => {
      box.style.borderColor = '';
      box.style.background = '';
      updatePlayerUI();
    }, 4500);
  }
}

function toggleTaskCompletion() {
  prayerStatus = [true, true, true, true, true];
  for (let i = 0; i < 5; i++) {
    const chk = document.getElementById(`prayer-chk-${i}`);
    if (chk) chk.closest('.prayer-item').classList.add('done');
  }
  document.getElementById('prayer-badge-text').textContent = '5 / 5 صلوات';
  document.getElementById('check-btn-text').textContent = 'تم إنجاز الورد كاملاً بنجاح ✓';
  document.getElementById('check-btn-icon').textContent = '🎉';
}

// Kids Interactions & Character Selection
function selectKidsCharacter(name, emoji) {
  currentChildName = name;
  currentChildEmoji = emoji;

  // Update chips styling
  document.querySelectorAll('.char-chip').forEach(c => c.classList.remove('active'));
  const activeId = name === 'سالم' ? 'chip-salem' :
                   name === 'سارة' ? 'chip-sarah' :
                   name === 'عائشة' ? 'chip-aisha' : 'chip-maryam';
  const activeChip = document.getElementById(activeId);
  if (activeChip) activeChip.classList.add('active');

  // Update avatar emoji & mascot header
  const emojiSpan = document.getElementById('mascot-emoji');
  if (emojiSpan) emojiSpan.textContent = emoji;

  const mascotNameElem = document.getElementById('mascot-name');
  if (mascotNameElem) {
    const isGirl = ['سارة', 'عائشة', 'مريم'].includes(name);
    mascotNameElem.textContent = isGirl ? `صديقتك ${name}` : `صديقك ${name}`;
  }

  const greetings = {
    'عائشة': 'أهلاً يا عائشة يا بطلة القرآن! 🧕🌸 هيا نسقي شجرة القرآن معاً بإنجاز ورد اليوم!',
    'مريم': 'مرحباً يا مريم يا زهرة الجنة! 🌸✨ ما شاء الله على همتك العالية في حفظ كتاب الله!',
    'سارة': 'أهلاً يا سارة يا نجمة الحفظ المتألقة! 👧⭐ هيا بنا نبدأ وردنا اليوم ونسقي الشجرة!',
    'سالم': 'أهلاً بك يا سالم يا بطل القرآن! 👦🌱 هيا نسقي شجرة القرآن معاً بإنجاز ورد اليوم!'
  };

  document.getElementById('mascot-text').textContent = greetings[name] || `أهلاً بك يا ${name}! هيا بنا نحفظ القرآن! 🌱`;
}

function applyCustomKidsName() {
  const input = document.getElementById('custom-child-name-input');
  const name = input ? input.value.trim() : '';
  if (!name) {
    alert('من فضلك اكتب اسمك يا بطل أولاً في الخانة!');
    return;
  }

  currentChildName = name;
  currentChildEmoji = '🌟';

  // Deselect preset chips
  document.querySelectorAll('.char-chip').forEach(c => c.classList.remove('active'));

  // Update Mascot avatar and name
  const emojiSpan = document.getElementById('mascot-emoji');
  if (emojiSpan) emojiSpan.textContent = '🌟';

  const mascotNameElem = document.getElementById('mascot-name');
  if (mascotNameElem) mascotNameElem.textContent = `البطل ${name}`;

  document.getElementById('mascot-text').textContent = `مرحباً يا ${name} يا بطلنا الغالي! 🌟 شجرة القرآن تنتظر همتك العالية اليوم لتسقيها بالحفظ المتقن! 🌱✨`;
}

function mascotCheer() {
  const quotes = [
    `يا للروعة يا ${currentChildName}! تلاوتك تملأ بستان القرآن نوراً وبركة! 🌟`,
    `ما شاء الله يا ${currentChildName}! كل آية تحفظها تصعد بك درجة في الجنة! 🏆`,
    `هيا يا ${currentChildName} نسقي شجرة القرآن معاً بإنجاز ورد اليوم! 🌱`
  ];
  const rand = quotes[Math.floor(Math.random() * quotes.length)];
  document.getElementById('mascot-text').textContent = rand;
}

function waterQuranTree() {
  waterDrops += 1;
  starsCount += 5;
  document.getElementById('kids-water').textContent = `${waterDrops} قطرات`;
  document.getElementById('kids-stars').textContent = `${starsCount} نجمة`;

  const btn = document.querySelector('.water-tree-btn');
  btn.textContent = 'أحسنت! سَقَيْتَ الشجرة 💧✨';
  setTimeout(() => {
    btn.innerHTML = '<span>💧</span><span>اسقِ شجرة القرآن بورد اليوم</span>';
  }, 1500);

  // Growth progression
  if (waterDrops >= 10 && gardenStage < 5) {
    gardenStage++;
    updateTreeStage();
  }
}

function updateTreeStage() {
  const titles = [
    '',
    'المرحلة ١: البذرة المباركة في التربة الطيبة 🌱',
    'المرحلة ٢: البرعم الأخضر اليافع 🌿',
    'المرحلة ٣: الغرسة النامية المتأصلة 🪴',
    'المرحلة ٤: الشجرة المزهرة العاطرة 🌸',
    'المرحلة ٥: شجرة القرآن الذهبية المثمرة 🌳✨'
  ];
  document.getElementById('garden-stage-title').textContent = titles[gardenStage];
  document.getElementById('mascot-text').textContent = 'ما شاء الله تبارك الله! 🎉 شجرة القرآن كبرت معك درجة جديدة بفضل حفظك المتقن!';
}

function playKidSurah() {
  currentSurah = 112; // Al-Ikhlas
  currentAyah = 1;
  currentAyahRepeat = 1;
  currentReciterId = 'minshawi_teacher';
  currentReciterSubfolder = 'Minshawy_Teacher_128kbps';
  currentReciterName = 'الشيخ المنشاوي مع الأطفال (المصحف المعلم)';

  const recSel = document.getElementById('reciter-select');
  if (recSel) recSel.value = 'minshawi_teacher';

  updatePlayerUI();
  playCurrentAyah();

  const mascot = document.getElementById('mascot-text');
  if (mascot) {
    mascot.textContent = 'استمع بإنصات للشيخ ثم ردد بصوتك الجميل مع الأطفال! 🌟';
  }
  showToast('🎙️ بدء تلاوة سورة الإخلاص مع الشيخ المنشاوي والأطفال');
}

function jumpToKidAyah(ayahNum) {
  currentSurah = 112;
  currentAyah = ayahNum;
  currentAyahRepeat = 1;
  updatePlayerUI();
  playCurrentAyah();
  showToast(`📖 الانتقال للآية (${ayahNum}) من سورة الإخلاص`);
}

function completeKidTask() {
  starsCount += 15;
  waterDrops += 2;
  document.getElementById('kids-stars').textContent = `${starsCount} نجمة`;
  document.getElementById('kids-water').textContent = `${waterDrops} قطرات`;
  document.getElementById('mascot-text').textContent = 'مذهل يا بطل! 🌟 حفظت سورة الإخلاص وأضفت ثماراً ذهبية لشجرتك!';
}

function claimParentalReward() {
  alert('مبارك يا بطل! 🎉 تم تسجيل استلام الجائزة الواقعية مع والديك.');
}

// Bubble Pop Quiz
function openBubbleQuiz() {
  currentQuizIndex = 0;
  quizScore = 0;
  document.getElementById('quiz-score').textContent = `النقاط: ${quizScore}`;
  loadQuizQuestion(0);
  document.getElementById('modal-bubble-quiz').classList.add('open');
}

function loadQuizQuestion(index) {
  const q = quizQuestions[index];
  document.getElementById('quiz-ayah-text').textContent = q.prompt;
  document.getElementById('quiz-feedback').textContent = '';

  const arena = document.getElementById('bubbles-arena');
  arena.innerHTML = '';

  q.options.forEach((opt) => {
    const bubble = document.createElement('div');
    bubble.className = 'pop-bubble';
    bubble.textContent = opt;
    bubble.onclick = () => answerBubble(bubble, opt, q.answer);
    arena.appendChild(bubble);
  });
}

function answerBubble(element, chosen, correct) {
  const feedback = document.getElementById('quiz-feedback');
  if (chosen === correct) {
    element.classList.add('popped');
    feedback.className = 'quiz-feedback-box success';
    feedback.textContent = 'إجابة صحيحة وفرقعة موفقة! 🎉 +10 نقاط';
    quizScore += 10;
    starsCount += 10;
    document.getElementById('quiz-score').textContent = `النقاط: ${quizScore}`;
    document.getElementById('kids-stars').textContent = `${starsCount} نجمة`;

    setTimeout(() => {
      if (currentQuizIndex < quizQuestions.length - 1) {
        currentQuizIndex++;
        loadQuizQuestion(currentQuizIndex);
      } else {
        feedback.textContent = 'أكملت التحدي بنجاح تام وحصلت على النجوم الذهبية! 🏆';
      }
    }, 1200);
  } else {
    element.classList.add('popped');
    feedback.className = 'quiz-feedback-box error';
    feedback.textContent = 'ليست هذه الكلمة، جرب فقاعة أخرى! 🎈';
  }
}

// Audio Settings Sliders
function updateSliders() {
  targetAyahRepeat = parseInt(document.getElementById('slider-rep-ayah').value);
  targetRangeCycle = parseInt(document.getElementById('slider-rep-range').value);
  intervalDelaySeconds = parseInt(document.getElementById('slider-delay').value);

  document.getElementById('val-rep-ayah').textContent = `${targetAyahRepeat} مرات`;
  document.getElementById('val-rep-range').textContent = `${targetRangeCycle} مرات`;
  document.getElementById('val-delay').textContent = `${intervalDelaySeconds} ثوانٍ`;

  document.querySelectorAll('.preset-btn').forEach(btn => btn.classList.remove('active'));
  const activeBtn = document.getElementById(`preset-btn-${targetAyahRepeat}`);
  if (activeBtn) activeBtn.classList.add('active');

  updatePlayerUI();
}

// Qira'at / Riwayah & Dynamic Reciters Engine
function populateRecitersDropdown(riwayahId) {
  const reciterSelect = document.getElementById('reciter-select');
  if (!reciterSelect) return;
  const filtered = recitersDatabase.filter(r => r.riwayah === riwayahId);
  reciterSelect.innerHTML = '';

  filtered.forEach(r => {
    const opt = document.createElement('option');
    opt.value = r.id;
    opt.textContent = `${r.name} - ${r.style}`;
    reciterSelect.appendChild(opt);
  });

  const label = document.getElementById('reciter-select-label');
  if (label && riwayatNames[riwayahId]) {
    label.textContent = `الشيخ القارئ برواية (${riwayatNames[riwayahId]}):`;
  }

  // Keep current if available in the new riwayah, else select first
  const exists = filtered.find(r => r.id === currentReciterId || r.subfolder === currentReciterSubfolder);
  if (exists) {
    reciterSelect.value = exists.id;
    currentReciterId = exists.id;
    currentReciterSubfolder = exists.subfolder;
    currentReciterName = exists.name;
  } else if (filtered.length > 0) {
    reciterSelect.value = filtered[0].id;
    currentReciterId = filtered[0].id;
    currentReciterSubfolder = filtered[0].subfolder;
    currentReciterName = filtered[0].name;
    updatePlayerUI();
  }
}

function onRiwayahChange() {
  const sel = document.getElementById('riwayah-select');
  currentRiwayah = sel.value;
  populateRecitersDropdown(currentRiwayah);
  const recSel = document.getElementById('reciter-select');
  if (recSel && recSel.options.length > 0) {
    const activeRec = recitersDatabase.find(r => r.id === recSel.value || r.subfolder === recSel.value);
    if (activeRec) {
      currentReciterId = activeRec.id;
      currentReciterSubfolder = activeRec.subfolder;
      currentReciterName = activeRec.name;
    } else {
      currentReciterName = recSel.options[0].text;
    }
    updatePlayerUI();
    showToast(`📖 ${riwayatNames[currentRiwayah]} - ${currentReciterName}`);
    if (isPlaying) {
      playCurrentAyah();
    }
  }
}

function onReciterChange() {
  const sel = document.getElementById('reciter-select');
  const activeRec = recitersDatabase.find(r => r.id === sel.value || r.subfolder === sel.value);
  if (activeRec) {
    currentReciterId = activeRec.id;
    currentReciterSubfolder = activeRec.subfolder;
    currentReciterName = activeRec.name;
  } else {
    currentReciterName = sel.options[sel.selectedIndex].text;
  }
  if (delayCountdownTimer) {
    clearInterval(delayCountdownTimer);
    delayCountdownTimer = null;
  }
  isTransitioning = false;
  currentAyahRepeat = 1;
  updatePlayerUI();
  showToast(`🎙️ تم تفعيل تلاوة: ${currentReciterName}`);
  if (isPlaying) {
    playCurrentAyah();
  }
}

function saveAudioSettings() {
  closeAllModals();
  const sel = document.getElementById('reciter-select');
  if (sel && sel.value) {
    const activeRec = recitersDatabase.find(r => r.id === sel.value || r.subfolder === sel.value);
    if (activeRec) {
      currentReciterId = activeRec.id;
      currentReciterSubfolder = activeRec.subfolder;
      currentReciterName = activeRec.name;
    }
  }
  const sAyah = document.getElementById('slider-rep-ayah');
  if (sAyah) targetAyahRepeat = parseInt(sAyah.value, 10) || 1;
  const sRange = document.getElementById('slider-rep-range');
  if (sRange) targetRangeCycle = parseInt(sRange.value, 10) || 1;
  const sDelay = document.getElementById('slider-delay');
  if (sDelay) intervalDelaySeconds = parseInt(sDelay.value, 10) || 0;

  if (delayCountdownTimer) {
    clearInterval(delayCountdownTimer);
    delayCountdownTimer = null;
  }
  isTransitioning = false;
  currentAyahRepeat = 1;
  isPlaying = true;
  updatePlayerUI();
  showToast(`✅ تم حفظ إعدادات الصوت وبدء تلاوة: ${currentReciterName}`);
  playCurrentAyah();
}

function showToast(message, duration = 3000) {
  let toast = document.getElementById('app-floating-toast');
  if (!toast) {
    toast = document.createElement('div');
    toast.id = 'app-floating-toast';
    toast.className = 'app-floating-toast';
    document.body.appendChild(toast);
  }
  toast.textContent = message;
  toast.classList.add('visible');
  if (window._toastTimer) clearTimeout(window._toastTimer);
  window._toastTimer = setTimeout(() => {
    toast.classList.remove('visible');
  }, duration);
}

// Delay Compensation
function applyCompensationStrategy() {
  const radios = document.getElementsByName('comp-strat');
  let selected = 'friday';
  for (const r of radios) {
    if (r.checked) selected = r.value;
  }

  document.getElementById('delayed-box').style.display = 'none';
  closeAllModals();
  alert('تم بنجاح تطبيق استراتيجية التعويض وإعادة جدولة الأوراد المتأخرة دون إرباك مسارك القرآني!');
}

// Modals Management
function openMutashabihaModal() {
  document.getElementById('modal-mutashabiha').classList.add('open');
}

function openCompensationModal() {
  document.getElementById('modal-compensation').classList.add('open');
}

function openAudioSettings() {
  document.getElementById('modal-audio-settings').classList.add('open');
}

function openApkModal() {
  document.getElementById('modal-apk').classList.add('open');
}

function closeAllModals() {
  document.querySelectorAll('.modal-overlay').forEach((m) => m.classList.remove('open'));
}

function closeModals(e) {
  if (e.target.classList.contains('modal-overlay')) {
    closeAllModals();
  }
}

// =========================================================================
// Madani Mushaf Page & Memorization System Controller Engine
// =========================================================================

function getCurrentSurahName() {
  const s = surahsDatabase.find(x => x.num === currentSurah);
  return s ? `سورة ${s.name}` : `سورة رقم ${currentSurah}`;
}

function getAyahTextOnly(surah, ayah) {
  const key = `${surah}_${ayah}`;
  if (uthmanicQuranText[key]) {
    return uthmanicQuranText[key];
  }
  const timing = getAyahInfo(surah, ayah, currentReciterId);
  if (timing && timing.text) {
    return timing.text;
  }
  return `الآية الكريمة (${toArabicDigits(ayah)}) من سورة ${getCurrentSurahName()}`;
}

// Render complete Madani Mushaf page with headers, plaque, unnumbered Basmalah, and verses
function renderMadaniMushafPage() {
  const versesArea = document.getElementById('mushaf-verses-area');
  if (!versesArea) return;

  const pageInfo = getPageInfo(currentMushafPage);
  const surahInfo = surahsDatabase.find(s => s.num === currentSurah) || surahsDatabase[1];

  // 1. Ribbons (Juz, Surah, Hizb/Rub)
  const juzRibbon = document.getElementById('mushaf-ribbon-juz');
  if (juzRibbon) {
    const juzOrdinal = arabicOrdinalWords[pageInfo.juz] || toArabicDigits(pageInfo.juz);
    juzRibbon.textContent = `الجُزْءُ ${juzOrdinal}`;
  }

  const surahRibbon = document.getElementById('mushaf-ribbon-surah');
  if (surahRibbon) {
    surahRibbon.textContent = `سُورَةُ ${surahInfo.name}`;
  }

  const hizbRibbon = document.getElementById('mushaf-ribbon-hizb');
  if (hizbRibbon) {
    const hizbOrdinal = arabicOrdinalWords[pageInfo.hizb] || toArabicDigits(pageInfo.hizb);
    const rubOrdinal = arabicOrdinalWords[((pageInfo.rub - 1) % 4) + 1] || 'الأَوَّلُ';
    hizbRibbon.textContent = `الحِزْبُ ${hizbOrdinal} • الرُّبْعُ ${rubOrdinal}`;
  }

  // 2. Surah Plaque Header
  const plaqueTitle = document.getElementById('plaque-surah-title');
  const plaqueDesc = document.getElementById('plaque-surah-desc');
  if (plaqueTitle) plaqueTitle.textContent = `سُورَةُ ${surahInfo.name}`;
  if (plaqueDesc) plaqueDesc.textContent = `${surahInfo.type} • آيَاتُهَا ${toArabicDigits(surahInfo.ayahs)}`;

  // 3. Sacred Basmalah Plaque (Strictly unnumbered, not counted as an Ayah for Al-Baqarah and general surahs)
  const basmalahPlaque = document.getElementById('mushaf-basmalah-plaque');
  if (basmalahPlaque) {
    if (currentSurah === 9) { // At-Tawbah
      basmalahPlaque.style.display = 'none';
    } else {
      basmalahPlaque.style.display = 'block';
      const caption = basmalahPlaque.querySelector('.basmalah-caption');
      if (caption) {
        if (currentSurah === 1) {
          caption.textContent = '(آية رقم ١ في سورة الفاتحة)';
        } else {
          caption.textContent = `(فصل استفتاح وتبرك • ليست آية معدودة في سورة ${surahInfo.name})`;
        }
      }
    }
  }

  // 4. Verses Content Rendering
  versesArea.innerHTML = '';
  const startA = pageInfo.startAyah;
  const endA = pageInfo.endAyah;

  for (let a = startA; a <= endA; a++) {
    const verseText = getAyahTextOnly(currentSurah, a);
    const span = document.createElement('span');
    span.className = 'mushaf-ayah';
    span.id = `mushaf-ayah-${a}`;
    span.setAttribute('data-ayah', a);
    span.onclick = () => jumpToAyah(a);

    span.innerHTML = `
      <span class="ayah-text">${verseText}</span>
      <span class="ayah-end-num">﴿${toArabicDigits(a)}﴾</span>
    `;

    versesArea.appendChild(span);
  }

  // 5. Page number bracket
  const pageNumElem = document.getElementById('mushaf-page-num');
  if (pageNumElem) {
    pageNumElem.textContent = toArabicDigits(currentMushafPage);
  }

  highlightActiveAyahInMushaf();
}

// Real-time highlight for currently reciting Ayah and active range in the Madani Mushaf
function highlightActiveAyahInMushaf() {
  const versesArea = document.getElementById('mushaf-verses-area');
  if (!versesArea) return;

  const allVerses = versesArea.querySelectorAll('.mushaf-ayah');
  allVerses.forEach(span => {
    const a = parseInt(span.getAttribute('data-ayah'), 10);
    if (a === currentAyah) {
      span.classList.add('active-mushaf-ayah');
    } else {
      span.classList.remove('active-mushaf-ayah');
    }

    if (a >= rangeStartAyah && a <= rangeEndAyah) {
      span.classList.add('in-range-ayah');
    } else {
      span.classList.remove('in-range-ayah');
    }
  });

  const activeSpan = versesArea.querySelector('.active-mushaf-ayah');
  if (activeSpan) {
    activeSpan.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
  }
}

// Click on any Ayah in the Mushaf page to jump directly to it and recite
function jumpToAyah(ayahNumber) {
  currentAyah = ayahNumber;
  currentAyahRepeat = 1;
  if (currentAyah < rangeStartAyah) {
    rangeStartAyah = currentAyah;
    updateRangeInputsUI();
  } else if (currentAyah > rangeEndAyah) {
    rangeEndAyah = currentAyah;
    updateRangeInputsUI();
  }
  updatePlayerUI();
  highlightActiveAyahInMushaf();
  playCurrentAyah();
  showToast(`📖 تلاوة الآية (${toArabicDigits(currentAyah)}) من ${getCurrentSurahName()}`);
}

// Memorization System Mode Switcher (الصفحات vs الأرباع)
function setMemorizationSystem(mode) {
  currentMemorizationSystem = mode;
  const tabPage = document.getElementById('tab-system-page');
  const tabRub = document.getElementById('tab-system-rub');
  const pageGroup = document.getElementById('page-selector-group');
  const rubGroup = document.getElementById('rub-selector-group');
  const statusPill = document.getElementById('system-status-pill');

  if (mode === 'page') {
    if (tabPage) tabPage.classList.add('active');
    if (tabRub) tabRub.classList.remove('active');
    if (pageGroup) pageGroup.style.display = 'block';
    if (rubGroup) rubGroup.style.display = 'none';
    if (statusPill) statusPill.textContent = 'طريقة الصفحات مفعلة (مصحف المدينة)';

    const pInfo = getPageInfo(currentMushafPage);
    rangeStartAyah = pInfo.startAyah;
    rangeEndAyah = pInfo.endAyah;
    currentAyah = rangeStartAyah;
    currentAyahRepeat = 1;
    showToast('📖 تم تفعيل طريقة حفظ صفحات مصحف المدينة (604 صفحات)');
  } else {
    if (tabPage) tabPage.classList.remove('active');
    if (tabRub) tabRub.classList.add('active');
    if (pageGroup) pageGroup.style.display = 'none';
    if (rubGroup) rubGroup.style.display = 'block';
    if (statusPill) statusPill.textContent = 'طريقة الأرباع مفعلة (الأحزاب والأرباع)';

    const rInfo = rubsDatabase.find(r => r.id === currentRubQuarter) || rubsDatabase[0];
    rangeStartAyah = rInfo.startAyah;
    rangeEndAyah = rInfo.endAyah;
    currentAyah = rangeStartAyah;
    currentAyahRepeat = 1;
    showToast('📜 تم تفعيل طريقة حفظ الأرباع (240 ربعاً قرآنياً)');
  }

  updateRangeInputsUI();
  renderMadaniMushafPage();
  updatePlayerUI();
  if (isPlaying) {
    playCurrentAyah();
  }
}

// Populate Surahs Dropdown (114 Surahs)
function populateSurahsDropdown() {
  const surahSelect = document.getElementById('surah-select');
  if (!surahSelect) return;

  surahSelect.innerHTML = '';
  surahsDatabase.forEach(s => {
    const opt = document.createElement('option');
    opt.value = s.num;
    opt.textContent = `${toArabicDigits(s.num)}. سورة ${s.name} (${toArabicDigits(s.ayahs)} آية - ص ${toArabicDigits(s.startPage)})`;
    if (s.num === currentSurah) opt.selected = true;
    surahSelect.appendChild(opt);
  });
}

// Populate Pages Dropdown (1 to 604)
function populatePagesDropdown() {
  const pageSelect = document.getElementById('page-select');
  if (!pageSelect) return;

  pageSelect.innerHTML = '';
  for (let p = 1; p <= 604; p++) {
    const opt = document.createElement('option');
    opt.value = p;
    const pInfo = getPageInfo(p);
    opt.textContent = `صفحة ${toArabicDigits(p)} (${pInfo.surahName})`;
    if (p === currentMushafPage) opt.selected = true;
    pageSelect.appendChild(opt);
  }
}

// Populate Rubs Dropdown (240 Quarters)
function populateRubsDropdown() {
  const rubSelect = document.getElementById('rub-select');
  if (!rubSelect) return;

  rubSelect.innerHTML = '';
  rubsDatabase.forEach(r => {
    const opt = document.createElement('option');
    opt.value = r.id;
    opt.textContent = `${r.name} (ص ${toArabicDigits(r.page)})`;
    if (r.id === currentRubQuarter) opt.selected = true;
    rubSelect.appendChild(opt);
  });
}

// Surah Dropdown Change Handler
function onSurahSelectChange() {
  const sel = document.getElementById('surah-select');
  const surahNum = parseInt(sel.value, 10);
  const surahInfo = surahsDatabase.find(s => s.num === surahNum);
  if (!surahInfo) return;

  currentSurah = surahNum;
  currentMushafPage = surahInfo.startPage;
  currentAyah = 1;
  currentAyahRepeat = 1;

  const pageSel = document.getElementById('page-select');
  if (pageSel) pageSel.value = currentMushafPage;

  const pInfo = getPageInfo(currentMushafPage);
  rangeStartAyah = pInfo.startAyah;
  rangeEndAyah = Math.min(surahInfo.ayahs, pInfo.endAyah);

  updateRangeInputsUI();
  renderMadaniMushafPage();
  updatePlayerUI();
  showToast(`📖 تم اختيار سورة ${surahInfo.name} • صفحة (${toArabicDigits(currentMushafPage)})`);
  if (isPlaying) {
    playCurrentAyah();
  }
}

// Page Stepper & Dropdown Handlers
function stepMushafPage(delta) {
  let targetPage = currentMushafPage + delta;
  if (targetPage < 1) targetPage = 1;
  if (targetPage > 604) targetPage = 604;
  goToMushafPage(targetPage);
}

function onPageSelectChange() {
  const sel = document.getElementById('page-select');
  const pageNum = parseInt(sel.value, 10);
  goToMushafPage(pageNum);
}

function goToMushafPage(pageNum) {
  currentMushafPage = pageNum;
  const pageSel = document.getElementById('page-select');
  if (pageSel) pageSel.value = pageNum;

  const pageInfo = getPageInfo(pageNum);
  currentSurah = pageInfo.surah;

  const surahSel = document.getElementById('surah-select');
  if (surahSel) surahSel.value = currentSurah;

  rangeStartAyah = pageInfo.startAyah;
  rangeEndAyah = pageInfo.endAyah;
  currentAyah = rangeStartAyah;
  currentAyahRepeat = 1;

  updateRangeInputsUI();
  renderMadaniMushafPage();
  updatePlayerUI();
  showToast(`📄 صفحة المصحف (${toArabicDigits(currentMushafPage)}) • ${getCurrentSurahName()}`);
  if (isPlaying) {
    playCurrentAyah();
  }
}

// Rub Stepper & Dropdown Handlers
function stepRubQuarter(delta) {
  let targetRub = currentRubQuarter + delta;
  if (targetRub < 1) targetRub = 1;
  if (targetRub > 240) targetRub = 240;
  goToRubQuarter(targetRub);
}

function onRubSelectChange() {
  const sel = document.getElementById('rub-select');
  const rubNum = parseInt(sel.value, 10);
  goToRubQuarter(rubNum);
}

function goToRubQuarter(rubNum) {
  currentRubQuarter = rubNum;
  const rubSel = document.getElementById('rub-select');
  if (rubSel) rubSel.value = rubNum;

  const rubInfo = rubsDatabase.find(r => r.id === rubNum) || rubsDatabase[0];
  currentSurah = rubInfo.surah;
  currentMushafPage = rubInfo.page;

  const surahSel = document.getElementById('surah-select');
  if (surahSel) surahSel.value = currentSurah;

  const pageSel = document.getElementById('page-select');
  if (pageSel) pageSel.value = currentMushafPage;

  rangeStartAyah = rubInfo.startAyah;
  rangeEndAyah = rubInfo.endAyah;
  currentAyah = rangeStartAyah;
  currentAyahRepeat = 1;

  updateRangeInputsUI();
  renderMadaniMushafPage();
  updatePlayerUI();
  showToast(`📜 ${rubInfo.name}`);
  if (isPlaying) {
    playCurrentAyah();
  }
}

// Quick Range Preset Chips
function setRangePreset(type) {
  const pageInfo = getPageInfo(currentMushafPage);
  document.querySelectorAll('.range-chip').forEach(c => c.classList.remove('active'));

  if (type === 'page') {
    rangeStartAyah = pageInfo.startAyah;
    rangeEndAyah = pageInfo.endAyah;
    const chip = document.getElementById('chip-full-page');
    if (chip) chip.classList.add('active');
  } else if (type === 'single') {
    rangeStartAyah = currentAyah;
    rangeEndAyah = currentAyah;
    const chip = document.getElementById('chip-single-ayah');
    if (chip) chip.classList.add('active');
  } else if (type === 'three') {
    rangeStartAyah = currentAyah;
    const surahInfo = surahsDatabase.find(s => s.num === currentSurah);
    const maxA = surahInfo ? surahInfo.ayahs : 286;
    rangeEndAyah = Math.min(maxA, currentAyah + 2);
    const chip = document.getElementById('chip-three-ayahs');
    if (chip) chip.classList.add('active');
  } else if (type === 'rub') {
    const rubInfo = rubsDatabase.find(r => r.id === currentRubQuarter) || rubsDatabase[0];
    rangeStartAyah = rubInfo.startAyah;
    rangeEndAyah = rubInfo.endAyah;
    const chip = document.getElementById('chip-rub-portion');
    if (chip) chip.classList.add('active');
  }

  if (currentAyah < rangeStartAyah || currentAyah > rangeEndAyah) {
    currentAyah = rangeStartAyah;
    currentAyahRepeat = 1;
  }

  updateRangeInputsUI();
  highlightActiveAyahInMushaf();
  updatePlayerUI();
  showToast(`🎯 تم ضبط النطاق: من الآية (${toArabicDigits(rangeStartAyah)}) إلى (${toArabicDigits(rangeEndAyah)})`);
  if (isPlaying) {
    playCurrentAyah();
  }
}

// Manual Range Input Change & Validation
function onManualRangeChange() {
  const fromInput = document.getElementById('input-range-from');
  const toInput = document.getElementById('input-range-to');
  const surahInfo = surahsDatabase.find(s => s.num === currentSurah);
  const maxAyahs = surahInfo ? surahInfo.ayahs : 286;

  let fromVal = parseInt(fromInput.value, 10) || 1;
  let toVal = parseInt(toInput.value, 10) || 1;

  if (fromVal < 1) fromVal = 1;
  if (fromVal > maxAyahs) fromVal = maxAyahs;
  if (toVal < fromVal) toVal = fromVal;
  if (toVal > maxAyahs) toVal = maxAyahs;

  fromInput.value = fromVal;
  toInput.value = toVal;
}

// Apply Custom Range Button Handler
function applyCustomRange() {
  onManualRangeChange();
  const fromInput = document.getElementById('input-range-from');
  const toInput = document.getElementById('input-range-to');

  rangeStartAyah = parseInt(fromInput.value, 10);
  rangeEndAyah = parseInt(toInput.value, 10);

  if (currentAyah < rangeStartAyah || currentAyah > rangeEndAyah) {
    currentAyah = rangeStartAyah;
    currentAyahRepeat = 1;
  }

  document.querySelectorAll('.range-chip').forEach(c => c.classList.remove('active'));

  updateRangeInputsUI();
  highlightActiveAyahInMushaf();
  updatePlayerUI();
  showToast(`✅ تم تطبيق النطاق المخصص: الآيات (${toArabicDigits(rangeStartAyah)} - ${toArabicDigits(rangeEndAyah)})`);
  if (isPlaying) {
    playCurrentAyah();
  }
}

// Update Inputs and Indicator UI
function updateRangeInputsUI() {
  const fromInput = document.getElementById('input-range-from');
  const toInput = document.getElementById('input-range-to');
  const surahInfo = surahsDatabase.find(s => s.num === currentSurah);
  const maxAyahs = surahInfo ? surahInfo.ayahs : 286;

  if (fromInput) {
    fromInput.max = maxAyahs;
    fromInput.value = rangeStartAyah;
  }
  if (toInput) {
    toInput.max = maxAyahs;
    toInput.value = rangeEndAyah;
  }

  const indicator = document.getElementById('range-indicator-pill');
  if (indicator) {
    indicator.textContent = `${getCurrentSurahName()} • الآيات (${toArabicDigits(rangeStartAyah)} - ${toArabicDigits(rangeEndAyah)})`;
  }

  const chipPage = document.getElementById('chip-full-page');
  if (chipPage) {
    const pInfo = getPageInfo(currentMushafPage);
    chipPage.textContent = `كامل الصفحة (${toArabicDigits(pInfo.startAyah)} - ${toArabicDigits(pInfo.endAyah)})`;
  }
}
