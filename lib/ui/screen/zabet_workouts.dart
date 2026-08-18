import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// ==========================================
// 1. Data Models (هيكلية البيانات المترجمة)
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
// 2. Data Repository (بيانات الأنظمة كاملة)
// ==========================================

class WorkoutData {
  static List<WorkoutSystem> getSystems() {
    return [
      // ---------------- النظام الأول: Yahya Split ----------------
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

      // ---------------- النظام الثاني: Arnold Split ----------------
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

      // ---------------- النظام الثالث: Push/Pull/Legs ----------------
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
      appBar: AppBar(
        title: Text('zabet_workouts'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: systems.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              title: Text(systems[index].systemName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.blue),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SystemDaysScreen(system: systems[index]),
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
      appBar: AppBar(
        title: Text(system.systemName, style: const TextStyle(fontSize: 18)),
      ),
      body: ListView.builder(
        itemCount: system.days.length,
        itemBuilder: (context, index) {
          final day = system.days[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(day.getDayName(context), style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.fitness_center),
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
// 5. الشاشة الثالثة: التمارين التفاعلية (Checkboxes)
// ==========================================

class ExercisesScreen extends StatefulWidget {
  final WorkoutDay day;
  const ExercisesScreen({super.key, required this.day});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.day.getDayName(context), style: const TextStyle(fontSize: 18)),
      ),
      body: ListView.builder(
        itemCount: widget.day.exercises.length,
        itemBuilder: (context, index) {
          final exercise = widget.day.exercises[index];
          final note = exercise.getNote(context);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ExpansionTile(
              title: Text(exercise.getName(context), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.getReps(context), style: const TextStyle(color: Colors.grey)),
                  if (note != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      note,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ]
                ],
              ),
              children: List.generate(exercise.sets, (setIndex) {
                return CheckboxListTile(
                  activeColor: Colors.green,
                  title: Text(
                    "${'set_label'.tr(args: ['${setIndex + 1}'])}  •  ${exercise.getReps(context)}",
                    style: TextStyle(
                      decoration: exercise.completedSets[setIndex] ? TextDecoration.lineThrough : null,
                      color: exercise.completedSets[setIndex] ? Colors.grey : Colors.black,
                    ),
                  ),
                  value: exercise.completedSets[setIndex],
                  onChanged: (bool? value) {
                    setState(() {
                      exercise.completedSets[setIndex] = value ?? false;
                    });
                  },
                );
              }),
            ),
          );
        },
      ),
    );
  }
}