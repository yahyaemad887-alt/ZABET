import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:zabet_app/core/app_colors.dart';
import 'package:zabet_app/screen/zabet_diet_screen.dart';
import 'package:zabet_app/screen/zabet_tests.dart';
import 'package:zabet_app/screen/zabet_timer_screen.dart';
import 'package:zabet_app/ui/screen/zabet_workouts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  // قائمة الـ 8 لغات المتاحة في التطبيق
  final List<Map<String, String>> _languages = const [
    {'code': 'ar', 'name': 'العربية'},
    {'code': 'en', 'name': 'English'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'de', 'name': 'Deutsch'},
    {'code': 'pt', 'name': 'Português'},
    {'code': 'ru', 'name': 'Русский'},
    {'code': 'tr', 'name': 'Türkçe'},
  ];

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-8862179519549672/2901887666',
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return Directionality(
          textDirection: ui.TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Language / اختر اللغة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _languages.length,
                    itemBuilder: (context, index) {
                      final lang = _languages[index];
                      final isSelected = context.locale.languageCode == lang['code'];
                      return ListTile(
                        leading: const Icon(Icons.language, color: Colors.deepOrange),
                        title: Text(
                          lang['name']!,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.deepOrange : Colors.black87,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Colors.deepOrange)
                            : null,
                        onTap: () async {
                          await context.setLocale(Locale(lang['code']!));
                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentLang = context.locale.languageCode.toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. شريط التنقل العلوي مع اللوجو وزر اللغة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          width: 28,
                          height: 28,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'ZABET',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),

                  // زر تغيير اللغة
                  Directionality(
                    textDirection: ui.TextDirection.ltr,
                    child: InkWell(
                      onTap: () => _showLanguageBottomSheet(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.deepOrange.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.language, size: 16, color: Colors.deepOrange),
                            const SizedBox(width: 6),
                            Text(
                              currentLang,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. عنوان الترحيب
              Text(
                'hello_zabet'.tr(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 24),

              // 3. شبكة الخدمات - الصف الأول
              Row(
                children: [
                  Expanded(
                    child: _ServiceCard(
                      icon: Icons.fitness_center,
                      iconColor: AppColors.cardWorkoutsBg,
                      iconIconColor: AppColors.cardWorkouts,
                      title: 'zabet_workouts'.tr(),
                      titleColor: AppColors.cardWorkouts,
                      description: 'workouts_desc'.tr(),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ZabetWorkoutsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ServiceCard(
                      icon: Icons.timer_outlined,
                      iconColor: AppColors.cardTimerBg,
                      iconIconColor: AppColors.cardTimer,
                      title: 'zabet_timer'.tr(),
                      titleColor: AppColors.cardTimer,
                      description: 'timer_desc'.tr(),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ZabetTimerScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // شبكة الخدمات - الصف الثاني
              Row(
                children: [
                  Expanded(
                    child: _ServiceCard(
                      icon: Icons.restaurant_menu,
                      iconColor: AppColors.cardDietBg,
                      iconIconColor: AppColors.cardDiet,
                      title: 'zabet_diet'.tr(),
                      titleColor: AppColors.cardDiet,
                      description: 'diet_desc'.tr(),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ZabetDietScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ServiceCard(
                      icon: Icons.analytics_outlined,
                      iconColor: AppColors.cardTestsBg,
                      iconIconColor: AppColors.cardTests,
                      title: 'zabet_tests'.tr(),
                      titleColor: AppColors.cardTests,
                      description: 'tests_desc'.tr(),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ZabetTestsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // 4. حاوية إعلان البانر المحجوزة في الأسفل
      bottomNavigationBar: _isAdLoaded && _bannerAd != null
          ? SafeArea(
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      )
          : null,
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconIconColor;
  final String title;
  final Color titleColor;
  final String description;
  final VoidCallback onTap;

  const _ServiceCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconIconColor,
    required this.title,
    required this.titleColor,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 175,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconIconColor, size: 20),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: titleColor, size: 14),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textGrey,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}