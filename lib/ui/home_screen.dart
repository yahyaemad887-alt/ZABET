import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zabet_app/core/app_colors.dart';
import 'package:zabet_app/screen/zabet_diet_screen.dart';
import 'package:zabet_app/screen/zabet_timer_screen.dart';
import '../screen/zabet_tests.dart';
import 'screen/zabet_workouts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. شريط التنقل العلوي
              Row(
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
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ZabetWorkoutsScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: _buildServiceCard(
                        icon: Icons.fitness_center,
                        iconColor: AppColors.cardWorkoutsBg,
                        iconIconColor: AppColors.cardWorkouts,
                        title: 'zabet_workouts'.tr(),
                        titleColor: AppColors.cardWorkouts,
                        description: 'workouts_desc'.tr(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ZabetTimerScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: _buildServiceCard(
                        icon: Icons.timer_outlined,
                        iconColor: AppColors.cardTimerBg,
                        iconIconColor: AppColors.cardTimer,
                        title: 'zabet_timer'.tr(),
                        titleColor: AppColors.cardTimer,
                        description: 'timer_desc'.tr(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // شبكة الخدمات - الصف الثاني
              Row(
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ZabetDietScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: _buildServiceCard(
                        icon: Icons.restaurant_menu,
                        iconColor: AppColors.cardDietBg,
                        iconIconColor: AppColors.cardDiet,
                        title: 'zabet_diet'.tr(),
                        titleColor: AppColors.cardDiet,
                        description: 'diet_desc'.tr(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ZabetTestsScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: _buildServiceCard(
                        icon: Icons.analytics_outlined,
                        iconColor: AppColors.cardTestsBg,
                        iconIconColor: AppColors.cardTests,
                        title: 'zabet_tests'.tr(),
                        titleColor: AppColors.cardTests,
                        description: 'tests_desc'.tr(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              InkWell(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset(
                        "assets/images/app_logo.png",
                        fit: BoxFit.contain,
                      ),
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

  Widget _buildServiceCard({
    required IconData icon,
    required Color iconColor,
    required Color iconIconColor,
    required String title,
    required Color titleColor,
    required String description,
  }) {
    return Container(
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
              Icon(Icons.arrow_forward, color: titleColor, size: 16),
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
    );
  }
}