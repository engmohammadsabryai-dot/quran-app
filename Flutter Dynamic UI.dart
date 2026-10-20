import 'package:flutter/material.dart';

class QuranAdaptiveHomeScreen extends StatelessWidget {
  final UserProfile currentUser;
  final VoidCallback onSwitchUser;

  const QuranAdaptiveHomeScreen({
    super.key,
    required this.currentUser,
    required this.onSwitchUser,
  });

  @override
  Widget build(BuildContext context) {
    return currentUser.isChild 
      ? _buildKidsHomeScreen(context) 
      : _buildAdultHomeScreen(context);
  }

  // 1. واجهة الكبار (الرسمية الهادئة المبنية على الجداول)
  Widget _buildAdultHomeScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('خطة الحفظ - ${currentUser.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline_rounded),
            tooltip: 'تبديل المستخدم',
            onPressed: onSwitchUser,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // مؤشرات الإنجاز، وأيام التأخير، وجدول الأرباع
            const Text('مرحباً بك في وردك اليومي'),
          ],
        ),
      ),
    );
  }

  // 2. واجهة الأطفال الجذابة والملونة (Kids Mode)
  Widget _buildKidsHomeScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4), // خلفية مبهجة خضراء فاتحة
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.amber,
              child: const Icon(Icons.child_care, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(
              'بطل القرآن: ${currentUser.name} 🌟',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.switch_account_rounded, color: Colors.green),
            tooltip: 'تبديل المستخدم',
            onPressed: onSwitchUser,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // بطاقة رصيد النجوم والجواهر
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.orangeAccent, Colors.deepOrangeAccent]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: Colors.yellow, size: 28),
                      SizedBox(width: 4),
                      Text('240 نقطة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.local_florist_rounded, color: Colors.lightGreenAccent, size: 28),
                      SizedBox(width: 4),
                      Text('المستوى 3', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // شجرة القرآن التفاعلية (The Growing Tree)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.green.shade200, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.park_rounded, size: 85, color: Colors.green),
                  const SizedBox(height: 8),
                  const Text(
                    'شجرة حسناتك تنمو مع كل آية!',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'احفظ ورد اليوم لتزهر الشجرة بالتفاح الذهبي 🍎',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // زر الحفظ الكبير ثلاثي الأبعاد
            GestureDetector(
              onTap: () {
                // فتح شاشة الحفظ الكرتونية مع المنشاوي المعلم وترديد الأطفال
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFF004D40), offset: Offset(0, 5)),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
                    SizedBox(width: 8),
                    Text(
                      'ابدأ مغامرة اليوم 🚀',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}