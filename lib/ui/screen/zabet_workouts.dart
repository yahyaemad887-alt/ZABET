import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ==========================================
// 1. Data Models
// ==========================================

class Exercise {
  final String nameAr;
  final String nameEn;
  final int sets;
  final String repsAr;
  final String repsEn;
  final String? noteAr;
  final String? noteEn;
  List<bool> completedSets;

  Exercise({
    required this.nameAr,
    required this.nameEn,
    required this.sets,
    required this.repsAr,
    required this.repsEn,
    this.noteAr,
    this.noteEn,
  }) : completedSets = List.generate(sets, (index) => false);

  String getName(BuildContext context) {
    return context.locale.languageCode == 'ar' ? nameAr : nameEn;
  }

  String getReps(BuildContext context) {
    return context.locale.languageCode == 'ar' ? repsAr : repsEn;
  }

  String? getNote(BuildContext context) {
    return context.locale.languageCode == 'ar' ? noteAr : noteEn;
  }
}

class WorkoutDay {
  final String dayNameAr;
  final String dayNameEn;
  final List<Exercise> exercises;

  WorkoutDay({
    required this.dayNameAr,
    required this.dayNameEn,
    required this.exercises,
  });

  String getDayName(BuildContext context) {
    return context.locale.languageCode == 'ar' ? dayNameAr : dayNameEn;
  }
}

class WorkoutSystem {
  final String systemName;
  final List<WorkoutDay> days;

  WorkoutSystem({
    required this.systemName,
    required this.days,
  });
}

// ==========================================
// 2. Data Repository
// ==========================================

class WorkoutData {
  static List<WorkoutSystem> getSystems() {
    return [
      WorkoutSystem(
        systemName: "Yahya Split",
        days: [
          WorkoutDay(
            dayNameAr: "اليوم الأول: باي، تراي، ساعد",
            dayNameEn: "Day 1: Biceps, Triceps, Forearms",
            exercises: [
              Exercise(
                nameAr: "بايسبس (تجميع)",
                nameEn: "Biceps Curl",
                sets: 10,
                repsAr: "حتى الفشل العضلي",
                repsEn: "Till Failure",
                noteAr: "نزول تكتيكي بالوزن (Drop Set) في نفس المجموعة",
                noteEn: "Tactical weight drop (Drop Set) in the same set",
              ),
              Exercise(
                nameAr: "ترايسبس (تجميع)",
                nameEn: "Triceps Extension",
                sets: 10,
                repsAr: "حتى الفشل العضلي",
                repsEn: "Till Failure",
                noteAr: "نزول تكتيكي بالوزن (Drop Set)",
                noteEn: "Tactical weight drop (Drop Set)",
              ),
              Exercise(
                nameAr: "ساعد",
                nameEn: "Forearms",
                sets: 5,
                repsAr: "حتى الفشل العضلي",
                repsEn: "Till Failure",
              ),
            ],
          ),
          WorkoutDay(
            dayNameAr: "اليوم الثاني: بنش وكتف",
            dayNameEn: "Day 2: Chest & Shoulders",
            exercises: [
              Exercise(
                nameAr: "بنش عالي",
                nameEn: "Incline Bench Press",
                sets: 5,
                repsAr: "حتى الفشل العضلي",
                repsEn: "Till Failure",
                noteAr: "نزول تكتيكي بالوزن (Drop Set)",
                noteEn: "Tactical weight drop (Drop Set)",
              ),
              Exercise(
                nameAr: "بنش مستوي",
                nameEn: "Flat Bench Press",
                sets: 5,
                repsAr: "حتى الفشل العضلي",
                repsEn: "Till Failure",
                noteAr: "نزول تكتيكي بالوزن (Drop Set)",
                noteEn: "Tactical weight drop (Drop Set)",
              ),
              Exercise(
                nameAr: "بنش سفلي",
                nameEn: "Decline Bench Press",
                sets: 5,
                repsAr: "حتى الفشل العضلي",
                repsEn: "Till Failure",
                noteAr: "نزول تكتيكي بالوزن (Drop Set)",
                noteEn: "Tactical weight drop (Drop Set)",
              ),
              Exercise(
                nameAr: "كتف (تجميع)",
                nameEn: "Shoulders Press/Raises",
                sets: 5,
                repsAr: "حتى الفشل العضلي",
                repsEn: "Till Failure",
                noteAr: "نزول تكتيكي بالوزن (Drop Set)",
                noteEn: "Tactical weight drop (Drop Set)",
              ),
            ],
          ),
          WorkoutDay(
            dayNameAr: "اليوم الثالث: ظهر",
            dayNameEn: "Day 3: Back",
            exercises: [
              Exercise(nameAr: "سحب أمامي واسع", nameEn: "Wide Lat Pulldown", sets: 4, repsAr: "8-12 تكرار", repsEn: "8-12 reps"),
              Exercise(nameAr: "تجديف بالبار", nameEn: "Barbell Row", sets: 4, repsAr: "8-12 تكرار", repsEn: "8-12 reps"),
              Exercise(nameAr: "سحب أرضي", nameEn: "Seated Cable Row", sets: 4, repsAr: "8-12 تكرار", repsEn: "8-12 reps"),
            ],
          ),
          WorkoutDay(
            dayNameAr: "اليوم الرابع: رجل (انفجاري)",
            dayNameEn: "Day 4: Legs (Explosive)",
            exercises: [
              Exercise(
                nameAr: "سكوات بالبار",
                nameEn: "Barbell Squat",
                sets: 5,
                repsAr: "8-10 تكرار",
                repsEn: "8-10 reps",
                noteAr: "أوزان انفجارية - أداء صحيح بنسبة 120%",
                noteEn: "Explosive weights - 120% strict form",
              ),
              Exercise(
                nameAr: "مكبس رجل",
                nameEn: "Leg Press",
                sets: 4,
                repsAr: "10-12 تكرار",
                repsEn: "10-12 reps",
                noteAr: "أوزان انفجارية",
                noteEn: "Explosive weights",
              ),
              Exercise(nameAr: "رفرفة أمامي", nameEn: "Leg Extension", sets: 4, repsAr: "12-15 تكرار", repsEn: "12-15 reps"),
            ],
          ),
        ],
      ),
      WorkoutSystem(
        systemName: "Arnold Split (5 Days)",
        days: [
          WorkoutDay(
            dayNameAr: "اليوم 1: أرجل",
            dayNameEn: "Day 1: Legs",
            exercises: [
              Exercise(nameAr: "قرفصاء بالبار", nameEn: "Barbell Squat", sets: 4, repsAr: "16 تكرار", repsEn: "16 reps"),
              Exercise(nameAr: "مكبس رجل", nameEn: "Leg Press", sets: 4, repsAr: "15 تكرار", repsEn: "15 reps"),
              Exercise(nameAr: "سمانة على المكبس", nameEn: "Calf Press", sets: 4, repsAr: "20 تكرار", repsEn: "20 reps"),
            ],
          ),
          WorkoutDay(
            dayNameAr: "اليوم 2: صدر",
            dayNameEn: "Day 2: Chest",
            exercises: [
              Exercise(nameAr: "ضغط صدر بار مستوي", nameEn: "Barbell Bench Press", sets: 4, repsAr: "20 تكرار", repsEn: "20 reps"),
              Exercise(nameAr: "ضغط صدر بار عالي", nameEn: "Incline Bench Press", sets: 4, repsAr: "20 تكرار", repsEn: "20 reps"),
              Exercise(nameAr: "تجميع كيبل صدر", nameEn: "Cable Crossover", sets: 4, repsAr: "16 تكرار", repsEn: "16 reps"),
            ],
          ),
          WorkoutDay(
            dayNameAr: "اليوم 3: ظهر",
            dayNameEn: "Day 3: Back",
            exercises: [
              Exercise(nameAr: "رفعة ميتة", nameEn: "Deadlift", sets: 3, repsAr: "8 تكرارات", repsEn: "8 reps"),
              Exercise(nameAr: "تجديف بالبار", nameEn: "Barbell Bent Over Row", sets: 3, repsAr: "12 تكرار", repsEn: "12 reps"),
              Exercise(nameAr: "سحب أمامي واسع", nameEn: "Wide Grip Lat Pulldown", sets: 3, repsAr: "12 تكرار", repsEn: "12 reps"),
            ],
          ),
        ],
      ),
      WorkoutSystem(
        systemName: "Push/Pull/Legs (PPL)",
        days: [
          WorkoutDay(
            dayNameAr: "يوم الدفع (بنش، كتف، تراي)",
            dayNameEn: "Push Day (Chest, Shoulders, Triceps)",
            exercises: [
              Exercise(
                nameAr: "ضغط كتف بار",
                nameEn: "Military Press",
                sets: 5,
                repsAr: "5 تكرارات",
                repsEn: "5 reps",
                noteAr: "راحة 1-2 دقيقة",
                noteEn: "Rest 1-2 mins",
              ),
              Exercise(nameAr: "ضغط صدر دامبل", nameEn: "Dumbbell Bench Press", sets: 3, repsAr: "5 تكرارات", repsEn: "5 reps"),
              Exercise(nameAr: "غطس تراي", nameEn: "Tricep Dip", sets: 3, repsAr: "8 تكرارات", repsEn: "8 reps"),
            ],
          ),
          WorkoutDay(
            dayNameAr: "يوم السحب (ظهر، باي)",
            dayNameEn: "Pull Day (Back, Biceps)",
            exercises: [
              Exercise(nameAr: "عقلة", nameEn: "Pull Up", sets: 5, repsAr: "5 تكرارات", repsEn: "5 reps"),
              Exercise(nameAr: "تجديف بالبار", nameEn: "Bent-Over Row", sets: 3, repsAr: "5 تكرارات", repsEn: "5 reps"),
              Exercise(nameAr: "مرجحة باي", nameEn: "Barbell Curl", sets: 3, repsAr: "8 تكرارات", repsEn: "8 reps"),
            ],
          ),
          WorkoutDay(
            dayNameAr: "يوم الأرجل",
            dayNameEn: "Leg Day",
            exercises: [
              Exercise(nameAr: "سكوات", nameEn: "Barbell Squat", sets: 5, repsAr: "5 تكرارات", repsEn: "5 reps"),
              Exercise(nameAr: "رفعة ميتة", nameEn: "Deadlift", sets: 3, repsAr: "5 تكرارات", repsEn: "5 reps"),
              Exercise(nameAr: "مكبس", nameEn: "Leg Press", sets: 3, repsAr: "8 تكرارات", repsEn: "8 reps"),
            ],
          ),
        ],
      ),
    ];
  }
}

// ==========================================
// 3. الشاشة الأولى: قائمة الأنظمة
// ==========================================

class ZabetWorkoutsScreen extends StatelessWidget {
  const ZabetWorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final systems = WorkoutData.getSystems();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'zabet_workouts'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: systems.length,
        itemBuilder: (context, index) {
          final system = systems[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fitness_center_rounded, color: Colors.deepOrange),
              ),
              title: Text(
                system.systemName,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              subtitle: Text(
                '${system.days.length} ${'days_count'.tr()}',
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.deepOrange),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SystemDaysScreen(system: system),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// 4. الشاشة الثانية: أيام النظام المحدد
// ==========================================

class SystemDaysScreen extends StatelessWidget {
  final WorkoutSystem system;
  const SystemDaysScreen({super.key, required this.system});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          system.systemName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: system.days.length,
        itemBuilder: (context, index) {
          final day = system.days[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              title: Text(
                day.getDayName(context),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              subtitle: Text(
                '${day.exercises.length} ${'exercises_count'.tr()}',
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.deepOrange),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExercisesScreen(day: day),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// 5. الشاشة الثالثة: التمارين التفاعلية ومؤقت الراحة
// ==========================================

class ExercisesScreen extends StatefulWidget {
  final WorkoutDay day;
  const ExercisesScreen({super.key, required this.day});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  bool _isRestActive = false;

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

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

  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    setState(() {
      _restSecondsRemaining = seconds;
      _isRestActive = true;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecondsRemaining > 0) {
        if (mounted) {
          setState(() => _restSecondsRemaining--);
        }
      } else {
        _stopRestTimer();
      }
    });
  }

  void _stopRestTimer() {
    _restTimer?.cancel();
    if (mounted) {
      setState(() {
        _isRestActive = false;
        _restSecondsRemaining = 0;
      });
    }
  }

  double _calculateProgress() {
    int totalSets = 0;
    int completedSets = 0;
    for (var ex in widget.day.exercises) {
      totalSets += ex.sets;
      completedSets += ex.completedSets.where((c) => c).length;
    }
    return totalSets == 0 ? 0 : completedSets / totalSets;
  }

  void _resetDayProgress() {
    setState(() {
      for (var ex in widget.day.exercises) {
        ex.completedSets = List.generate(ex.sets, (_) => false);
      }
      _stopRestTimer();
    });
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.day.getDayName(context),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.deepOrange),
            tooltip: 'reset_day'.tr(),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Text('reset_dialog_title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  content: Text('reset_dialog_desc'.tr()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('cancel'.tr(), style: const TextStyle(color: Colors.black54)),
                    ),
                    TextButton(
                      onPressed: () {
                        _resetDayProgress();
                        Navigator.pop(context);
                      },
                      child: Text('confirm'.tr(), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'workout_progress'.tr(),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0xFFE2E8F0),
                      color: Colors.deepOrange,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(left: 12, right: 12, top: 4, bottom: _isRestActive ? 90 : 20),
                  itemCount: widget.day.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = widget.day.exercises[index];
                    final note = exercise.getNote(context);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 2,
                      shadowColor: Colors.black.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                exercise.getName(context),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.info_outline_rounded, color: Colors.deepOrange, size: 20),
                              onPressed: () => _showExerciseNotesModal(context, exercise),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(exercise.getReps(context), style: const TextStyle(color: Colors.black54, fontSize: 13)),
                            if (note != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                note,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ]
                          ],
                        ),
                        children: List.generate(exercise.sets, (setIndex) {
                          final isCompleted = exercise.completedSets[setIndex];
                          return CheckboxListTile(
                            activeColor: Colors.deepOrange,
                            title: Text(
                              "${'set_label'.tr(args: ['${setIndex + 1}'])}  •  ${exercise.getReps(context)}",
                              style: TextStyle(
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                color: isCompleted ? Colors.grey : const Color(0xFF1E293B),
                                fontSize: 14,
                              ),
                            ),
                            value: isCompleted,
                            onChanged: (bool? value) {
                              setState(() {
                                exercise.completedSets[setIndex] = value ?? false;
                              });
                              if (value == true) {
                                _startRestTimer(60);
                              }
                            },
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          if (_isRestActive)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_rounded, color: Colors.orangeAccent, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('rest_timer_title'.tr(), style: const TextStyle(color: Colors.white70, fontSize: 11)),
                          Text(
                            '${_restSecondsRemaining ~/ 60}:${(_restSecondsRemaining % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _startRestTimer(_restSecondsRemaining + 15),
                      child: const Text('+15s', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: _stopRestTimer,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _isAdLoaded && _bannerAd != null
          ? SafeArea(
        child: Container(
          color: Colors.transparent,
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      )
          : null,
    );
  }

  void _showExerciseNotesModal(BuildContext context, Exercise exercise) {
    final note = exercise.getNote(context);
    showModalBottomSheet(
      context: context,
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
                  const Icon(Icons.fitness_center_rounded, color: Colors.deepOrange),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      exercise.getName(context),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text('${'target_sets'.tr()}: ${exercise.sets}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('${'target_reps'.tr()}: ${exercise.getReps(context)}', style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 16),
              if (note != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.assignment_late_outlined, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(note, style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}