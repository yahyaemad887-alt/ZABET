import 'package:flutter/material.dart';
import 'package:zabet_app/core/app_colors.dart';
import 'package:zabet_app/ui/home_screen.dart';

class ZabetSplashScreen extends StatefulWidget {
  const ZabetSplashScreen({super.key});

  @override
  State<ZabetSplashScreen> createState() => _ZabetSplashScreenState();
}

class _ZabetSplashScreenState extends State<ZabetSplashScreen> with SingleTickerProviderStateMixin {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // بعد بناء الشاشة، نبدأ نرفع الـ opacity عشان تعمل Fade In
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });

    // نité فترة عرض اللوجو، وبعدين نعمل Fade Out وننقل للـ HomeScreen
    _navigateToHome();
  }

  _navigateToHome() async {
    // الوقت اللي هيفضل فيه الانيميشن ظاهر (مثلاً ثانيتين ونص)
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    // نبدأ نخفي اللوجو تدريجياً (Fade Out)
    setState(() {
      _opacity = 0.0;
    });

    // ننتظر نصف ثانية حتى تكتمل حركة الاختفاء، ثم ننقل للرئيسية
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // لون الخلفية المناسب لتطبيقك
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 1000), // مدة ظهور واختفاء الانيميشن
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // لوجو التطبيق
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
              // اسم التطبيق أو شعار ترحيبي
              const Text(
                'ZABET',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'READY FOR MISSION',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}