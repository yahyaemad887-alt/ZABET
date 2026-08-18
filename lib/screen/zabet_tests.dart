import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==========================================
// 1. Data Model (موديل بيانات الاختبارات)
// ==========================================

class TestModel {
  final String id;
  final String titleKey;
  final String unitKey;
  final IconData icon;
  final Color color;
  final int target;
  int currentScore;
  final bool isTime;

  TestModel({
    required this.id,
    required this.titleKey,
    required this.unitKey,
    required this.icon,
    required this.color,
    required this.target,
    required this.currentScore,
    this.isTime = false,
  });

  String get statusTextKey {
    if (isTime) {
      if (currentScore <= target) return "status_excellent";
      if (currentScore <= target + 60) return "status_very_good";
      return "status_acceptable";
    } else {
      double ratio = currentScore / target;
      if (ratio >= 1.0) return "status_excellent";
      if (ratio >= 0.5) return "status_acceptable";
      return "status_needs_improvement";
    }
  }

  Color get statusColor {
    if (isTime) {
      if (currentScore <= target) return Colors.green;
      if (currentScore <= target + 60) return Colors.amber.shade800;
      return Colors.red;
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
      return (target / (currentScore == 0 ? 1 : currentScore)).clamp(0.0, 1.0);
    }
    return (currentScore / target).clamp(0.0, 1.0);
  }
}

// ==========================================
// 2. Main Screen (شاشة الاختبارات التفاعلية)
// ==========================================

class ZabetTestsScreen extends StatefulWidget {
  const ZabetTestsScreen({Key? key}) : super(key: key);

  @override
  State<ZabetTestsScreen> createState() => _ZabetTestsScreenState();
}

class _ZabetTestsScreenState extends State<ZabetTestsScreen> {
  final List<TestModel> tests = [
    TestModel(
      id: "pullups",
      titleKey: "test_pullups",
      unitKey: "unit_reps",
      icon: Icons.fitness_center,
      color: Colors.blue,
      target: 10,
      currentScore: 5,
    ),
    TestModel(
      id: "pushups",
      titleKey: "test_pushups",
      unitKey: "unit_reps",
      icon: Icons.accessibility_new,
      color: Colors.orange,
      target: 40,
      currentScore: 20,
    ),
    TestModel(
      id: "situps",
      titleKey: "test_situps",
      unitKey: "unit_reps",
      icon: Icons.airline_seat_recline_extra,
      color: Colors.purple,
      target: 40,
      currentScore: 25,
    ),
    TestModel(
      id: "run1500",
      titleKey: "test_run1500",
      unitKey: "unit_seconds",
      icon: Icons.directions_run,
      color: Colors.green,
      target: 360,
      currentScore: 420,
      isTime: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedScores();
  }

  Future<void> _loadSavedScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var test in tests) {
        final savedVal = prefs.getInt('zabet_test_${test.id}');
        if (savedVal != null) {
          test.currentScore = savedVal;
        }
      }
    });
  }

  Future<void> _updateScore(TestModel test, int newScore) async {
    setState(() {
      test.currentScore = newScore;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('zabet_test_${test.id}', newScore);
  }

  double get overallProgress {
    if (tests.isEmpty) return 0.0;
    double totalRatio = 0.0;
    for (var test in tests) {
      totalRatio += test.progressRatio;
    }
    return totalRatio / tests.length;
  }

  void _showStopwatchDialog(TestModel test) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _StopwatchBottomSheet(
        test: test,
        onSave: (seconds) {
          _updateScore(test, seconds);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "zabet_tests_title".tr(),
          style: const TextStyle(
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
            _buildReadinessCard(),
            const SizedBox(height: 20),
            Text(
              "track_update_daily".tr(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
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
    );
  }

  Widget _buildReadinessCard() {
    final int progressPercent = (overallProgress * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF212B36),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            "readiness_card_title".tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 75,
            height: 75,
            child: CircularProgressIndicator(
              value: overallProgress.clamp(0.0, 1.0),
              strokeWidth: 8,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "$progressPercent%",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "readiness_motto".tr(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
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
          Row(
            children: [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test.titleKey.tr(),
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
                      "${test.target} ${test.unitKey.tr()}",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (test.isTime) ...[
                IconButton(
                  icon: const Icon(Icons.timer_outlined, color: Colors.deepOrange),
                  onPressed: () => _showStopwatchDialog(test),
                  tooltip: 'stopwatch_title'.tr(),
                ),
              ],
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (test.currentScore > 0) {
                        _updateScore(test, test.currentScore - (test.isTime ? 5 : 1));
                      }
                    },
                    child: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.redAccent,
                      size: 26,
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 36),
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
                      _updateScore(test, test.currentScore + (test.isTime ? 5 : 1));
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "target_college".tr(args: [test.target.toString(), test.unitKey.tr()]),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                test.statusTextKey.tr(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: test.statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: test.progressRatio,
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

// ==========================================
// 3. Stopwatch Bottom Sheet (مؤقت الاختبارات)
// ==========================================

class _StopwatchBottomSheet extends StatefulWidget {
  final TestModel test;
  final Function(int seconds) onSave;

  const _StopwatchBottomSheet({
    required this.test,
    required this.onSave,
  });

  @override
  State<_StopwatchBottomSheet> createState() => _StopwatchBottomSheetState();
}

class _StopwatchBottomSheetState extends State<_StopwatchBottomSheet> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _elapsedSeconds = widget.test.currentScore;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _elapsedSeconds++;
        });
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _elapsedSeconds = 0;
      _isRunning = false;
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'stopwatch_title'.tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            _formatTime(_elapsedSeconds),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _toggleTimer,
                icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                label: Text(_isRunning ? 'stopwatch_pause'.tr() : 'stopwatch_start'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning ? Colors.amber.shade800 : Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _resetTimer,
                icon: const Icon(Icons.refresh),
                label: Text('stopwatch_reset'.tr()),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onSave(_elapsedSeconds);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text('stopwatch_save'.tr()),
            ),
          ),
        ],
      ),
    );
  }
}