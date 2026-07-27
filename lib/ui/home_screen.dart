
import 'package:flutter/material.dart';
import 'package:zabet_app/core/app_colors.dart';
import 'package:zabet_app/screen/zabet_diet_screen.dart';
import 'package:zabet_app/screen/zabet_timer_screen.dart';
import '../screen/zabet_tests.dart';
import 'screen/zabet_workouts.dart'; // تأكد إن مسار الملف صح حسب ما سميته عندك


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
                        borderRadius: BorderRadius.circular(13), // تخليها دائرية
                        child: Image.asset(
                          'assets/images/app_logo.png', // مسار صورة اللوجو بتاعك
                          width: 28,
                          height: 28,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'ZABET',
                        style: TextStyle(
                          fontSize: 28, // كبّرنا الحجم
                          fontWeight: FontWeight.w900, // خليناه عريض جداً (Bold تقيل)
                          letterSpacing: 2.0, // وسّعنا المسافات بين الحروف عشان تاخد العرض والطول
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),

                ],
              ),
              const SizedBox(height: 24),

              // 2. عنوان الترحيب
              const Text(
                'HELLO ZABET!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 16),


              const SizedBox(height: 24),

              // 4. شبكة الخدمات - الصف الأول
              Row(
                children: <Widget>[
                  // --- كارت الـ Workouts الجديد متغلف ومتقفل صح ---
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
                        title: 'Zabet Workouts',
                        titleColor: AppColors.cardWorkouts,
                        description: 'Explore pro training programs & heavy lifting splits.',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // --- كارت الـ Timer متغلف ومتقفل بالملي ---
                  Expanded(
                    child: InkWell(
                      // جوه الـ InkWell أو GestureDetector الخاص بـ Zabet Timer
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
                        title: 'Zabet Timer',
                        titleColor: AppColors.cardTimer,
                        description: 'Set your rest time between sets with zero tolerance.',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // شبكة الخدمات - الصف الثاني
              // 143. شبكة الخدمات - الصف الثاني
              Row(
                children: <Widget>[
                  // --- كارت الـ Diet متغلف بالـ InkWell وجاهز للتنقل ---
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
                        title: 'Zabet Diet',
                        titleColor: AppColors.cardDiet,
                        description: 'Turn your meals into clean fuel for your muscles.',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // --- كارت الـ Tests متغلف بالـ InkWell وجاهز للتنقل ---
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
                        title: 'Zabet Tests',
                        titleColor: AppColors.cardTests,
                        description: 'Track your progress in pull-ups, push-ups, and running.',
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
                  height: 140, // حافظ على نفس الارتفاع اللي إنت كاتباه في كودك الأصلي
                  decoration: BoxDecoration(
                    color: Colors.black, // الخلفية سوداء سادة تماماً زي ما طلبت
                    borderRadius: BorderRadius.circular(16), // نفس حواف إطار كودك الأصلي
                    // لو عندك boxShadow أو border في كودك الأصلي سيبهم زي ما هما هنا
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0), // مسافة أمان عشان الأيقونة متلمسش الإطار
                      child: Image.asset(
                        "assets/images/app_logo.png", // مسار الأيقونة اللي هتصممها وتضيفها في الـ assets
                        fit: BoxFit.contain, // بيضمن إن الأيقونة تحافظ على أبعادها المربعة في النص
                      ),
                    ),
                  ),
                )
              ),
            ], // قفلة الـ children بتاعة الـ Column (سطر 229 في الصورة)
          ), // قفلة الـ Column نفسه (سطر 230 في الصورة)
        ), // قفلة الـ SingleChildScrollView (سطر 231 في الصورة)
      ), // قفلة الـ SafeArea (سطر 232 في الصورة)
    ); // قفلة الـ Scaffold (سطر 233 في الصورة)
  } // القوس المتعرج الأخير الخالص المقفل لميثود الـ build (سطر 234 في الصورة)

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
            style: TextStyle(
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
