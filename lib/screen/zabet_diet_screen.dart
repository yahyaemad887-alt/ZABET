import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==========================================
// 1. الموديل ومحرك الحسابات الذكي للماكروز
// ==========================================
enum FitnessGoal { cut, maintain, bulk }

class UserMetrics {
  final double weightKg;
  final double heightCm;
  final int age;
  final double activityMultiplier;
  final FitnessGoal goal;

  const UserMetrics({
    required this.weightKg,
    required this.heightCm,
    required this.age,
    this.activityMultiplier = 1.375,
    this.goal = FitnessGoal.maintain,
  });
}

class ZabetDietEngine {
  final UserMetrics metrics;
  ZabetDietEngine(this.metrics);

  double get bmr => (10 * metrics.weightKg) + (6.25 * metrics.heightCm) - (5 * metrics.age) + 5;
  double get tdee => bmr * metrics.activityMultiplier;

  double get targetCalories {
    switch (metrics.goal) {
      case FitnessGoal.cut:
        return tdee - 450;
      case FitnessGoal.bulk:
        return tdee + 350;
      case FitnessGoal.maintain:
        return tdee;
    }
  }

  double get targetProteinGrams => (metrics.weightKg * 2.0).clamp(60.0, 250.0);
  double get targetFatGrams => (metrics.weightKg * 0.8).clamp(30.0, 120.0);
  double get targetCarbsGrams {
    double proteinCal = targetProteinGrams * 4;
    double fatCal = targetFatGrams * 9;
    double remainingCal = targetCalories - (proteinCal + fatCal);
    return (remainingCal / 4).clamp(50.0, 500.0);
  }

  double get targetWaterLiters => (metrics.weightKg * 0.035 + 0.5).clamp(2.5, 5.0);
}

// ==========================================
// 2. الشاشة الرئيسية للدايت
// ==========================================
class ZabetDietScreen extends StatefulWidget {
  const ZabetDietScreen({super.key});

  @override
  State<ZabetDietScreen> createState() => _ZabetDietScreenState();
}

class _ZabetDietScreenState extends State<ZabetDietScreen> {
  bool _isLoading = true;
  UserMetrics? _savedMetrics;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final double? weight = prefs.getDouble('user_weight');
    final double? height = prefs.getDouble('user_height');
    final int? age = prefs.getInt('user_age');
    final int? goalIndex = prefs.getInt('user_goal');

    if (weight != null && height != null && age != null) {
      setState(() {
        _savedMetrics = UserMetrics(
          weightKg: weight,
          heightCm: height,
          age: age,
          goal: goalIndex != null ? FitnessGoal.values[goalIndex] : FitnessGoal.maintain,
        );
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onMetricsSaved(UserMetrics newMetrics) {
    setState(() {
      _savedMetrics = newMetrics;
    });
  }

  void _resetMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_weight');
    await prefs.remove('user_height');
    await prefs.remove('user_age');
    await prefs.remove('user_goal');
    setState(() {
      _savedMetrics = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator(color: Colors.deepOrange)),
      );
    }

    if (_savedMetrics == null) {
      return ZabetMetricsInputForm(onSaved: _onMetricsSaved);
    }

    return ZabetDietDashboardScreen(
      userMetrics: _savedMetrics!,
      onResetMetrics: _resetMetrics,
      onGoalChanged: (newGoal) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_goal', newGoal.index);
        setState(() {
          _savedMetrics = UserMetrics(
            weightKg: _savedMetrics!.weightKg,
            heightCm: _savedMetrics!.heightCm,
            age: _savedMetrics!.age,
            goal: newGoal,
          );
        });
      },
    );
  }
}

// ==========================================
// 3. نموذج إدخال البيانات
// ==========================================
class ZabetMetricsInputForm extends StatefulWidget {
  final Function(UserMetrics) onSaved;
  const ZabetMetricsInputForm({super.key, required this.onSaved});

  @override
  State<ZabetMetricsInputForm> createState() => _ZabetMetricsInputFormState();
}

class _ZabetMetricsInputFormState extends State<ZabetMetricsInputForm> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  FitnessGoal _selectedGoal = FitnessGoal.maintain;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final double weight = double.parse(_weightController.text);
      final double height = double.parse(_heightController.text);
      final int age = int.parse(_ageController.text);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('user_weight', weight);
      await prefs.setDouble('user_height', height);
      await prefs.setInt('user_age', age);
      await prefs.setInt('user_goal', _selectedGoal.index);

      final metrics = UserMetrics(
        weightKg: weight,
        heightCm: height,
        age: age,
        goal: _selectedGoal,
      );

      widget.onSaved(metrics);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('body_metrics_title'.tr(), style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'weight_lbl'.tr(),
                  hintText: 'weight_hint'.tr(),
                  prefixIcon: const Icon(Icons.monitor_weight_outlined, color: Colors.deepOrange),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => (val == null || val.isEmpty || double.tryParse(val) == null) ? 'weight_err'.tr() : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'height_lbl'.tr(),
                  hintText: 'height_hint'.tr(),
                  prefixIcon: const Icon(Icons.height_rounded, color: Colors.deepOrange),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => (val == null || val.isEmpty || double.tryParse(val) == null) ? 'height_err'.tr() : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'age_lbl'.tr(),
                  hintText: 'age_hint'.tr(),
                  prefixIcon: const Icon(Icons.calendar_today_rounded, color: Colors.deepOrange),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => (val == null || val.isEmpty || int.tryParse(val) == null) ? 'age_err'.tr() : null,
              ),
              const SizedBox(height: 24),
              Text('select_goal_title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
              const SizedBox(height: 10),
              SegmentedButton<FitnessGoal>(
                segments: [
                  ButtonSegment(value: FitnessGoal.cut, label: Text('goal_cut'.tr()), icon: const Icon(Icons.trending_down)),
                  ButtonSegment(value: FitnessGoal.maintain, label: Text('goal_maintain'.tr()), icon: const Icon(Icons.remove)),
                  ButtonSegment(value: FitnessGoal.bulk, label: Text('goal_bulk'.tr()), icon: const Icon(Icons.trending_up)),
                ],
                selected: {_selectedGoal},
                onSelectionChanged: (Set<FitnessGoal> newSelection) {
                  setState(() {
                    _selectedGoal = newSelection.first;
                  });
                },
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: Colors.deepOrange,
                  selectedForegroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('calc_meals_btn'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 4. لوحة التحكم التفاعلية للدايت
// ==========================================
class ZabetDietDashboardScreen extends StatefulWidget {
  final UserMetrics userMetrics;
  final VoidCallback onResetMetrics;
  final Function(FitnessGoal) onGoalChanged;

  const ZabetDietDashboardScreen({
    super.key,
    required this.userMetrics,
    required this.onResetMetrics,
    required this.onGoalChanged,
  });

  @override
  State<ZabetDietDashboardScreen> createState() => _ZabetDietDashboardScreenState();
}

class _ZabetDietDashboardScreenState extends State<ZabetDietDashboardScreen> {
  double _waterConsumedMl = 0;
  double _consumedCalories = 0;
  double _consumedProtein = 0;
  double _consumedCarbs = 0;
  double _consumedFat = 0;

  final Map<String, bool> _supplementsStatus = {
    'creatine': false,
    'whey_protein': false,
    'omega3': false,
    'multivitamin': false,
  };

  final Map<int, bool> _mealStatus = {0: false, 1: false, 2: false, 3: false};

  @override
  void initState() {
    super.initState();
    _loadDailyTrackerData();
  }

  Future<void> _loadDailyTrackerData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _waterConsumedMl = prefs.getDouble('water_consumed') ?? 0.0;
      _supplementsStatus['creatine'] = prefs.getBool('supp_creatine') ?? false;
      _supplementsStatus['whey_protein'] = prefs.getBool('supp_whey') ?? false;
      _supplementsStatus['omega3'] = prefs.getBool('supp_omega3') ?? false;
      _supplementsStatus['multivitamin'] = prefs.getBool('supp_multi') ?? false;
    });
  }

  void _recalculateConsumedMacros(ZabetDietEngine engine) {
    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fat = 0;

    if (_mealStatus[0] == true) {
      calories += engine.targetCalories * 0.25;
      protein += engine.targetProteinGrams * 0.25;
      carbs += engine.targetCarbsGrams * 0.25;
      fat += engine.targetFatGrams * 0.25;
    }
    if (_mealStatus[1] == true) {
      calories += engine.targetCalories * 0.35;
      protein += engine.targetProteinGrams * 0.35;
      carbs += engine.targetCarbsGrams * 0.35;
      fat += engine.targetFatGrams * 0.35;
    }
    if (_mealStatus[2] == true) {
      calories += engine.targetCalories * 0.15;
      protein += engine.targetProteinGrams * 0.15;
      carbs += engine.targetCarbsGrams * 0.15;
      fat += engine.targetFatGrams * 0.15;
    }
    if (_mealStatus[3] == true) {
      calories += engine.targetCalories * 0.25;
      protein += engine.targetProteinGrams * 0.25;
      carbs += engine.targetCarbsGrams * 0.25;
      fat += engine.targetFatGrams * 0.25;
    }

    setState(() {
      _consumedCalories = calories;
      _consumedProtein = protein;
      _consumedCarbs = carbs;
      _consumedFat = fat;
    });
  }

  Future<void> _addWater(double amountMl) async {
    final engine = ZabetDietEngine(widget.userMetrics);
    final maxWaterMl = engine.targetWaterLiters * 1000;
    setState(() {
      _waterConsumedMl = (_waterConsumedMl + amountMl).clamp(0.0, maxWaterMl + 1000);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('water_consumed', _waterConsumedMl);
  }

  Future<void> _resetWater() async {
    setState(() {
      _waterConsumedMl = 0.0;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('water_consumed', 0.0);
  }

  void _showQuickPresetsModal(BuildContext context, ZabetDietEngine engine) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.flash_on_rounded, color: Colors.deepOrange),
                  const SizedBox(width: 8),
                  Text('quick_preset_title'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                ],
              ),
              const SizedBox(height: 16),
              _buildPresetTile('preset_1'.tr(), 350, 30, 40, 5, engine),
              _buildPresetTile('preset_2'.tr(), 500, 45, 50, 10, engine),
              _buildPresetTile('preset_3'.tr(), 280, 24, 5, 18, engine),
              _buildPresetTile('preset_4'.tr(), 200, 25, 2, 8, engine),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPresetTile(String title, double cal, double p, double c, double f, ZabetDietEngine engine) {
    return ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    subtitle: Text('$cal ${'kcal_unit'.tr()} | P:${p}g | C:${c}g | F:${f}g', style: const TextStyle(fontSize: 12, color: Colors.grey)),
    trailing: ElevatedButton(
    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
    onPressed: () {
    setState(() {
    _consumedCalories += cal;
    _consumedProtein += p;
    _consumedCarbs += c;
    _consumedFat += f;
    });
    Navigator.pop(context);
    },
    child: Text('add_btn'.tr(), style: const TextStyle(fontSize: 12)),
    ),
    );
  }

  void _showGroceryListModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shopping_cart_rounded, color: Colors.deepOrange),
                  const SizedBox(width: 8),
                  Text('grocery_list_title'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                ],
              ),
              const SizedBox(height: 16),
              _buildGroceryItem('grocery_item_1'.tr()),
              _buildGroceryItem('grocery_item_2'.tr()),
              _buildGroceryItem('grocery_item_3'.tr()),
              _buildGroceryItem('grocery_item_4'.tr()),
              _buildGroceryItem('grocery_item_5'.tr()),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroceryItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF334155))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final engine = ZabetDietEngine(widget.userMetrics);
    final targetCal = engine.targetCalories;
    final targetProtein = engine.targetProteinGrams;
    final targetCarbs = engine.targetCarbsGrams;
    final targetFat = engine.targetFatGrams;
    final targetWater = engine.targetWaterLiters;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('diet_dashboard_title'.tr(), style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded, color: Colors.amber),
            tooltip: 'quick_preset_title'.tr(),
            onPressed: () => _showQuickPresetsModal(context, engine),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.deepOrange),
            tooltip: 'grocery_list_title'.tr(),
            onPressed: () => _showGroceryListModal(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black54),
            tooltip: 'reset_metrics'.tr(),
            onPressed: widget.onResetMetrics,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. شريط تبديل الهدف
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  _buildGoalTab(FitnessGoal.cut, 'goal_cut'.tr()),
                  _buildGoalTab(FitnessGoal.maintain, 'goal_maintain'.tr()),
                  _buildGoalTab(FitnessGoal.bulk, 'goal_bulk'.tr()),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. كارت السعرات والماكروز الديناميكي
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('target_calories'.tr(), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(_consumedCalories.toStringAsFixed(0), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                              Text(' / ${targetCal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 4),
                              Text('kcal_unit'.tr(), style: const TextStyle(fontSize: 12, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFFFFF7ED),
                        child: Icon(Icons.local_fire_department_rounded, color: Colors.deepOrange, size: 28),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      _buildMacroBar('protein'.tr(), _consumedProtein, targetProtein, Colors.deepOrange),
                      const SizedBox(width: 12),
                      _buildMacroBar('carbs'.tr(), _consumedCarbs, targetCarbs, Colors.amber.shade700),
                      const SizedBox(width: 12),
                      _buildMacroBar('fat'.tr(), _consumedFat, targetFat, Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. عداد المياه التفاعلي
            _buildHydrationTracker(targetWater),
            const SizedBox(height: 16),

            // 4. تغذية التمرين
            Text('workout_nutrition_title'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildNutritionCard(
                    title: 'pre_workout_title'.tr(),
                    desc: 'pre_workout_desc'.tr(),
                    icon: Icons.bolt_rounded,
                    color: Colors.amber.shade800,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNutritionCard(
                    title: 'post_workout_title'.tr(),
                    desc: 'post_workout_desc'.tr(),
                    icon: Icons.fitness_center_rounded,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 5. تتبع المكملات
            _buildSupplementsTracker(),
            const SizedBox(height: 16),

            // 6. جدول الوجبات
            Text('fuel_plan_title'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 10),
            _buildMealItem(0, 'meal_1_title'.tr(), (targetCal * 0.25).toStringAsFixed(0), 'meal_1_desc'.tr(), engine),
            _buildMealItem(1, 'meal_2_title'.tr(), (targetCal * 0.35).toStringAsFixed(0), 'meal_2_desc'.tr(), engine),
            _buildMealItem(2, 'meal_3_title'.tr(), (targetCal * 0.15).toStringAsFixed(0), 'meal_3_desc'.tr(), engine),
            _buildMealItem(3, 'meal_4_title'.tr(), (targetCal * 0.25).toStringAsFixed(0), 'meal_4_desc'.tr(), engine),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalTab(FitnessGoal goal, String label) {
    final isSelected = widget.userMetrics.goal == goal;
    return Expanded(
      child: InkWell(
        onTap: () => widget.onGoalChanged(goal),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepOrange : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMacroBar(String label, double consumed, double target, Color color) {
    final double progress = (consumed / target).clamp(0.0, 1.0);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold)),
              Text('${consumed.toStringAsFixed(0)}/${target.toStringAsFixed(0)}${'g_unit'.tr()}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHydrationTracker(double targetWaterLiters) {
    final targetMl = targetWaterLiters * 1000;
    final progress = (_waterConsumedMl / targetMl).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.water_drop_rounded, color: Colors.blue, size: 22),
                  const SizedBox(width: 6),
                  Text('hydration_title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                ],
              ),
              Text(
                '${(_waterConsumedMl / 1000).toStringAsFixed(2)} / ${targetWaterLiters.toStringAsFixed(1)} ${'liters_unit'.tr()}',
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: () => _addWater(250),
                icon: const Icon(Icons.add, size: 16, color: Colors.blue),
                label: Text('+250 ${'ml_unit'.tr()}', style: const TextStyle(color: Colors.blue, fontSize: 12)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.blue)),
              ),
              OutlinedButton.icon(
                onPressed: () => _addWater(500),
                icon: const Icon(Icons.add, size: 16, color: Colors.blue),
                label: Text('+500 ${'ml_unit'.tr()}', style: const TextStyle(color: Colors.blue, fontSize: 12)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.blue)),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18, color: Colors.black45),
                onPressed: _resetWater,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard({required String title, required String desc, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color))),
            ],
          ),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildSupplementsTracker() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medication_rounded, color: Colors.deepOrange, size: 20),
              const SizedBox(width: 8),
              Text('supplements_title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _supplementsStatus.keys.map((key) {
              final isChecked = _supplementsStatus[key] ?? false;
              return FilterChip(
                label: Text(key.tr()),
                selected: isChecked,
                selectedColor: Colors.deepOrange.withValues(alpha: 0.2),
                checkmarkColor: Colors.deepOrange,
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: isChecked ? Colors.deepOrange : Colors.black87,
                  fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (bool selected) async {
                  setState(() {
                    _supplementsStatus[key] = selected;
                  });
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('supp_$key', selected);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMealItem(int index, String title, String calories, String desc, ZabetDietEngine engine) {
    final bool isChecked = _mealStatus[index] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isChecked ? Colors.deepOrange.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isChecked ? Colors.deepOrange : Colors.transparent),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Checkbox(
            value: isChecked,
            activeColor: Colors.deepOrange,
            onChanged: (val) {
              setState(() {
                _mealStatus[index] = val ?? false;
              });
              _recalculateConsumedMacros(engine);
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, decoration: isChecked ? TextDecoration.lineThrough : null)),
                    Text('$calories ${'kcal_unit'.tr()}', style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}