import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:zabet_app/core/app_colors.dart';
import 'package:zabet_app/screen/welcome_screen.dart';
import 'package:zabet_app/screen/zabet_splash_screen.dart';
import 'package:zabet_app/ui/screen/workout_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ضبط ألوان شريط النظام العلوي والسفلي للتماشي مع هويّة التطبيق
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 1. تهيئة الإعلانات (Google Mobile Ads)
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint("MobileAds Initialization Error: $e");
  }

  // 2. تهيئة الترجمة
  try {
    await EasyLocalization.ensureInitialized();
  } catch (e) {
    debugPrint("EasyLocalization Error: $e");
  }

  // 3. قراءة التفضيلات المخزنة
  bool isFirstTime = true;
  try {
    final prefs = await SharedPreferences.getInstance();
    isFirstTime = prefs.getBool('isFirstTime') ?? true;
  } catch (e) {
    debugPrint("SharedPreferences Error: $e");
  }

  // 4. تهيئة الإشعارات وطلب الأذونات في الخلفية
  try {
    await WorkoutNotificationService.initNotification();
    await WorkoutNotificationService.requestPermissions();
    await WorkoutNotificationService.scheduleWorkoutReminder();
  } catch (e) {
    debugPrint("Notification Error: $e");
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('ar'), // العربية
        Locale('en'), // الإنجليزية
        Locale('fr'), // الفرنسية
        Locale('es'), // الإسبانية
        Locale('de'), // الألمانية
        Locale('pt'), // البرتغالية
        Locale('ru'), // الروسية
        Locale('tr'), // التركية
      ],
      path: 'assets/lang',
      fallbackLocale: const Locale('ar'),
      child: ZabetApp(isFirstTime: isFirstTime),
    ),
  );
}

class ZabetApp extends StatelessWidget {
  final bool isFirstTime;
  const ZabetApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zabet',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: isFirstTime ? const WelcomeScreen() : const ZabetSplashScreen(),
    );
  }
}