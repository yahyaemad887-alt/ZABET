import 'package:flutter/material.dart';

class AppColors {
  // منع إنشاء كائن من هذا الكلاس (Utility Class) لأنه مخصص لحتواء الثوابت فقط
  AppColors._();

  // اللون الأساسي الداكن للتطبيق (يُستخدم في العناوين أو الخلفيات الداكنة)
  static const Color primaryDark = Color(0xFF0D1B2A);

  // ألوان بطارية التمارين (Workouts) - لون رئيسي وخلفية متناسقة
  static const Color cardWorkouts = Color(0xFF0D47A1);
  static const Color cardWorkoutsBg = Color(0xFFE3F2FD);

  // ألوان بطارية العداد أو المؤقت (Timer)
  static const Color cardTimer = Color(0xFFE65100);
  static const Color cardTimerBg = Color(0xFFFFF3E0);

  // ألوان بطارية الدايت (Diet & AI)
  static const Color cardDiet = Color(0xFF006064);
  static const Color cardDietBg = Color(0xFFE0F7FA);

  // ألوان بطارية الاختبارات أو المهام (Tests)
  static const Color cardTests = Color(0xFF1B5E20);
  static const Color cardTestsBg = Color(0xFFE8F5E9);

  // اللون العام لخلفية التطبيق
  static const Color background = Colors.white;

  // خلفية حقول البحث أو الإدخال
  static const Color searchFieldBg = Color(0xFFF5F5F7);

  // لون النصوص الفرعية أو الرمادية
  static const Color textGrey = Color(0xFF757575);
}
