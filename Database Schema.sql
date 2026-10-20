-- 1. جدول الحسابات والملفات الشخصية (يدعم فتح الطفل من جهاز والديه)
CREATE TABLE user_profiles (
    user_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    age INTEGER NOT NULL,
    gender TEXT CHECK(gender IN ('male', 'female')),
    avatar_id TEXT DEFAULT 'default_avatar',
    is_child BOOLEAN GENERATED ALWAYS AS (age < 15) VIRTUAL, -- يتم احتسابه تلقائياً
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2. جدول تتبع نقاط وتقدم الطفل (Gamification & Rewards)
CREATE TABLE child_game_progress (
    user_id TEXT PRIMARY KEY,
    points INTEGER DEFAULT 0,
    coins INTEGER DEFAULT 0,
    current_level INTEGER DEFAULT 1,
    current_tree_stage INTEGER DEFAULT 1,  -- مراحل نمو شجرة القرآن (1: بذرة -> 5: شجرة مثمرة)
    active_character_id TEXT DEFAULT 'hero_boy',
    unlocked_badges TEXT DEFAULT '[]',     -- JSON Array: ["juz_30_badge", "streak_7_badge"]
    FOREIGN KEY (user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE
);

-- 3. جدول قاعدة بيانات المتشابهات اللفظية (Master Data)
CREATE TABLE mutashabihat (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_surah INTEGER NOT NULL,
    source_ayah INTEGER NOT NULL,
    target_surah INTEGER NOT NULL,
    target_ayah INTEGER NOT NULL,
    source_text TEXT NOT NULL,
    target_text TEXT NOT NULL,
    difference_note TEXT NOT NULL,         -- ضبط الفارق (مثال: بالواو في البقرة، وبدون واو في آل عمران)
    rule_hint TEXT                         -- قاعدة نحوية أو معنوية للضبط
);

-- 4. جدول خطة توزيع الورد على الصلوات اليومية
CREATE TABLE prayer_portions (
    allocation_id TEXT PRIMARY KEY,
    task_id TEXT NOT NULL,                 -- مرتبط بالورد اليومي (سواء ربع أو صفحة)
    fajr_range TEXT,                       -- نطاق الآيات لسنة وفريضة الفجر
    dhuhr_range TEXT,                      -- للظهر
    asr_range TEXT,                        -- للعصر
    maghrib_range TEXT,                    -- للمغرب
    isha_qiyam_range TEXT,                 -- للعشاء وقيام الليل/الشفع والوتر
    is_fajr_done BOOLEAN DEFAULT 0,
    is_dhuhr_done BOOLEAN DEFAULT 0,
    is_asr_done BOOLEAN DEFAULT 0,
    is_maghrib_done BOOLEAN DEFAULT 0,
    is_isha_done BOOLEAN DEFAULT 0,
    FOREIGN KEY (task_id) REFERENCES daily_tasks(task_id) ON DELETE CASCADE
);