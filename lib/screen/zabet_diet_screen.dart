import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==========================================
// 1. موديل بيانات الجسم ومحرك الحسابات الديناميكي
// ==========================================
class UserMetrics {
  final double weightKg;
  final double heightCm;
  final int age;
  final double activityMultiplier;
  final bool? isRapidLoss;

  const UserMetrics({
    required this.weightKg,
    required this.heightCm,
    required this.age,
    this.activityMultiplier = 1.2,
    this.isRapidLoss,
  });
}

class ZabetCalculationEngine {
  final UserMetrics metrics;
  ZabetCalculationEngine(this.metrics);

  double calculateTargetCalories() {
    double bmr = (10 * metrics.weightKg) + (6.25 * metrics.heightCm) - (5 * metrics.age) + 5;
    return bmr * metrics.activityMultiplier;
  }

  double calculateWaterGoalLiters() {
    return (metrics.weightKg * 0.035).clamp(2.0, 5.0);
  }
}

// ==========================================
// 2. الشاشة الأولى: إدخال أو جلب بيانات الجسم
// ==========================================
class ZabetDietScreen extends StatefulWidget {
  const ZabetDietScreen({super.key});

  @override
  State<ZabetDietScreen> createState() => _ZabetDietScreenState();
}

class _ZabetDietScreenState extends State<ZabetDietScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  bool _isLoading = true;
  UserMetrics? _savedMetrics;

  @override
  void initState() {
    super.initState();
    _checkSavedMetrics();
  }

  Future<void> _checkSavedMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    final double? weight = prefs.getDouble('user_weight');
    final double? height = prefs.getDouble('user_height');
    final int? age = prefs.getInt('user_age');

    if (weight != null && height != null && age != null) {
      setState(() {
        _savedMetrics = UserMetrics(weightKg: weight, heightCm: height, age: age);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _calculateAndSave(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final double weight = double.parse(_weightController.text);
      final double height = double.parse(_heightController.text);
      final int age = int.parse(_ageController.text);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('user_weight', weight);
      await prefs.setDouble('user_height', height);
      await prefs.setInt('user_age', age);

      final userMetrics = UserMetrics(
        weightKg: weight,
        heightCm: height,
        age: age,
        activityMultiplier: 1.2,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ZabetDashboardScreen(userMetrics: userMetrics),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.deepOrange)),
      );
    }

    if (_savedMetrics != null) {
      return ZabetDashboardScreen(userMetrics: _savedMetrics!);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('body_metrics_title'.tr(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'weight_lbl'.tr(),
                  hintText: 'weight_hint'.tr(),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.deepOrange)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'weight_err'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'height_lbl'.tr(),
                  hintText: 'height_hint'.tr(),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.deepOrange)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'height_err'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'age_lbl'.tr(),
                  hintText: 'age_hint'.tr(),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.deepOrange)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null) {
                    return 'age_err'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 56),
              ElevatedButton(
                onPressed: () => _calculateAndSave(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'calc_meals_btn'.tr(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. الشاشة الثانية: الداشبورد التفاعلي مع زرار الريسيت والترجمة
// ==========================================
class ZabetDashboardScreen extends StatefulWidget {
  final UserMetrics userMetrics;
  const ZabetDashboardScreen({super.key, required this.userMetrics});

  @override
  State<ZabetDashboardScreen> createState() => _ZabetDashboardScreenState();
}

class _ZabetDashboardScreenState extends State<ZabetDashboardScreen> {
  final Map<int, bool> _mealStatus = {0: false, 1: false, 2: false, 3: false};

  Future<void> _resetUserMetrics(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_weight');
    await prefs.remove('user_height');
    await prefs.remove('user_age');

    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ZabetDietScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final engine = ZabetCalculationEngine(widget.userMetrics);
    final targetCalories = engine.calculateTargetCalories();
    final waterGoal = engine.calculateWaterGoalLiters();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: Text('diet_dashboard_title'.tr(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.deepOrange),
            tooltip: 'reset_metrics'.tr(),
            onPressed: () => _resetUserMetrics(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildCircularMetricCard(
                    title: 'target_calories'.tr(),
                    value: targetCalories.toStringAsFixed(0),
                    unit: 'kcal_unit'.tr(),
                    progress: 0.85,
                    progressColor: Colors.deepOrange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCircularMetricCard(
                    title: 'hydration_goal'.tr(),
                    value: waterGoal.toStringAsFixed(1),
                    unit: 'liters_unit'.tr(),
                    progress: 0.70,
                    progressColor: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'fuel_plan_title'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            _buildMealCard(
              index: 0,
              title: 'meal_1_title'.tr(),
              calories: '${(targetCalories * 0.25).toStringAsFixed(0)} ${'kcal_unit'.tr()}',
              description: 'meal_1_desc'.tr(),
            ),
            const SizedBox(height: 12),
            _buildMealCard(
              index: 1,
              title: 'meal_2_title'.tr(),
              calories: '${(targetCalories * 0.35).toStringAsFixed(0)} ${'kcal_unit'.tr()}',
              description: 'meal_2_desc'.tr(),
            ),
            const SizedBox(height: 12),
            _buildMealCard(
              index: 2,
              title: 'meal_3_title'.tr(),
              calories: '${(targetCalories * 0.15).toStringAsFixed(0)} ${'kcal_unit'.tr()}',
              description: 'meal_3_desc'.tr(),
            ),
            const SizedBox(height: 12),
            _buildMealCard(
              index: 3,
              title: 'meal_4_title'.tr(),
              calories: '${(targetCalories * 0.25).toStringAsFixed(0)} ${'kcal_unit'.tr()}',
              description: 'meal_4_desc'.tr(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularMetricCard({
    required String title,
    required String value,
    required String unit,
    required double progress,
    required Color progressColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.06), blurRadius: 8, spreadRadius: 2),
        ],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 75,
                height: 75,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 7,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(unit, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard({
    required int index,
    required String title,
    required String calories,
    required String description,
  }) {
    final bool isChecked = _mealStatus[index] ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isChecked ? Colors.deepOrange.withValues(alpha: 0.04) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isChecked ? Colors.deepOrange : Colors.transparent,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 6, spreadRadius: 2),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: isChecked,
            activeColor: Colors.deepOrange,
            onChanged: (bool? value) {
              setState(() {
                _mealStatus[index] = value ?? false;
              });
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration: isChecked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Text(calories, style: const TextStyle(fontSize: 13, color: Colors.deepOrange, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}