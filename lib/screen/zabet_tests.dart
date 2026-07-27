import 'package:flutter/material.dart';

class ZabetTestsScreen extends StatefulWidget {
  const ZabetTestsScreen({Key? key}) : super(key: key);

  @override
  State<ZabetTestsScreen> createState() => _ZabetTestsScreenState();
}

class TestModel {
  final String titleAr;
  final String titleEn;
  final IconData icon;
  final Color color;
  final int target;
  final String targetUnit;
  int currentScore;
  final bool isTime;

  TestModel({
    required this.titleAr,
    required this.titleEn,
    required this.icon,
    required this.color,
    required this.target,
    required this.targetUnit,
    required this.currentScore,
    this.isTime = false,
  });

  String get statusText {
    if (isTime) {
      if (currentScore <= target) return "ممتاز (جاهزية كاملة) 💪";
      if (currentScore <= target + 60) return "جيد جداً (قريب من الهدف) 👍";
      return "مقبول (تحتاج جهد إضافي) ⚡";
    } else {
      double ratio = currentScore / target;
      if (ratio >= 1.0) return "ممتاز (جاهزية كاملة) 💪";
      if (ratio >= 0.5) return "مقبول (تحتاج جهد إضافي) ⚡";
      return "يحتاج تحسين ⚠️";
    }
  }

  Color get statusColor {
    if (isTime) {
      if (currentScore <= target) return Colors.green;
      if (currentScore <= target + 60) return Colors.green.shade700;
      return Colors.amber.shade800;
    } else {
      double ratio = currentScore / target;
      if (ratio >= 1.0) return Colors.green;
      if (ratio >= 0.5) return Colors.amber.shade800;
      return Colors.red;
    }
  }

  double get progressRatio {
    if (target == 0) return 0;
    if (isTime) {
      return (target / currentScore).clamp(0.0, 1.0);
    }
    return (currentScore / target).clamp(0.0, 1.0);
  }
}

class _ZabetTestsScreenState extends State<ZabetTestsScreen> {
  double get overallProgress {
    if (tests.isEmpty) return 0.0;

    double totalRatio = 0.0;
    for (var test in tests) {
      double ratio;
      if (test.isTime) {
        // للجري: النسب من الوقت المستهدف / الوقت الحالي
        ratio = (test.target / test.currentScore).clamp(0.0, 1.0);
      } else {
        // للتمارين الأخرى: الحالي / المستهدف
        ratio = (test.currentScore / test.target).clamp(0.0, 1.0);
      }
      totalRatio += ratio;
    }

    return totalRatio / tests.length; // المتوسط الكلي
  }
  final List<TestModel> tests = [
    TestModel(
      titleAr: "اختبار العقلة",
      titleEn: "Pull-ups Test",
      icon: Icons.fitness_center,
      color: Colors.blue,
      target: 10,
      targetUnit: "تكرار",
      currentScore: 5,
    ),
    TestModel(
      titleAr: "اختبار الضغط",
      titleEn: "Push-ups Test",
      icon: Icons.accessibility_new,
      color: Colors.orange,
      target: 40,
      targetUnit: "تكرار",
      currentScore: 20,
    ),
    TestModel(
      titleAr: "اختبار البطن",
      titleEn: "Sit-ups Test",
      icon: Icons.airline_seat_recline_extra,
      color: Colors.purple,
      target: 40,
      targetUnit: "تكرار",
      currentScore: 25,
    ),
    TestModel(
      titleAr: "اختبار الجري (1500 متر)",
      titleEn: "1500m Running",
      icon: Icons.directions_run,
      color: Colors.green,
      target: 360,
      targetUnit: "ثانية",
      currentScore: 420,
      isTime: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F5FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Zabet Tests",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. كارت الجاهزية العلوية
              _buildReadinessCard(),
              const SizedBox(height: 20),

              // 2. العنوان الجانبي
              const Text(
                ":تتبع وقم بتحديث أرقامك اليومية",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // 3. قائمة الكروت
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildTestCard(tests[index]);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadinessCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF212B36),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            "معدل الجاهزية البدنية للأكاديمية",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 70,
            height: 70,
            child: CircularProgressIndicator(
              value: 0.62,
              strokeWidth: 8,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            // بدلاً من "62%" اكتب:
            "${(overallProgress * 100).toInt()}%",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "!استمر في التطوير، النجم يقترب",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard(TestModel test) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // الصف الرئيسي: الأيقونة + العنوان (مرن) + أزرار العداد
          Row(
            children: [
              // الأيقونة
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: test.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(test.icon, color: test.color, size: 22),
              ),
              const SizedBox(width: 10),

              // النصوص (محاطة بـ Expanded لتقليص المساحة تلقائياً بدون Overflow)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test.titleAr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      test.titleEn,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              // منطقة العداد (الناقص ثم الرقم ثم الزائد)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (test.currentScore > 0) {
                        setState(() {
                          test.currentScore -= (test.isTime ? 5 : 1);
                        });
                      }
                    },
                    child: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.redAccent,
                      size: 26,
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 32),
                    alignment: Alignment.center,
                    child: Text(
                      "${test.currentScore}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        test.currentScore += (test.isTime ? 5 : 1);
                      });
                    },
                    child: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.green,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // صف الحالة والهدف
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "مستهدف الكلية: ${test.target} ${test.targetUnit}",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                test.statusText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: test.statusColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

// شريط التقدم
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: test.isTime
                  ? (test.target / test.currentScore).clamp(0.0, 1.0)
                  : (test.currentScore / test.target).clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(test.statusColor),
            ),
          ),
        ],
      ),
    );
  }
}
