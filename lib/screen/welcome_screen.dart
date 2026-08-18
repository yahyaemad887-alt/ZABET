import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zabet_app/core/app_colors.dart';
import 'package:zabet_app/screen/zabet_splash_screen.dart'; // توجيه لشاشة Splash المطلوبة

import '../ui/screen/workout_notification_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final String currentLang = context.locale.languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/app_logo.png',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.shield,
                    color: AppColors.primaryDark,
                    size: 90,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'welcome_title'.tr(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Text(
                'welcome_subtitle'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _languageButton(
                    title: 'العربية',
                    languageCode: 'ar',
                    isSelected: currentLang == 'ar',
                  ),
                  const SizedBox(width: 16),
                  _languageButton(
                    title: 'English',
                    languageCode: 'en',
                    isSelected: currentLang == 'en',
                  ),
                ],
              ),
              const SizedBox(height: 56),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    // حفظ المفتاح باسم isFirstTime ومطابقته لـ main.dart
                    try {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isFirstTime', false);
                    } catch (e) {
                      debugPrint("SharedPreferences Error: $e");
                    }

                    if (!context.mounted) return;

                    // الانتقال لشاشة ZabetSplashScreen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ZabetSplashScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'start_now'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _languageButton({
    required String title,
    required String languageCode,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          await context.setLocale(Locale(languageCode));
          await WorkoutNotificationService.scheduleWorkoutReminder();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepOrange.withValues(alpha: 0.1) : Colors.transparent,
            border: Border.all(
              color: isSelected ? Colors.deepOrange : Colors.grey[400]!,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.deepOrange : Colors.grey[700],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}