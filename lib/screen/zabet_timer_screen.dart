import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:easy_localization/easy_localization.dart';

class ZabetTimerScreen extends StatefulWidget {
  const ZabetTimerScreen({super.key});

  @override
  State<ZabetTimerScreen> createState() => _ZabetTimerScreenState();
}

class _ZabetTimerScreenState extends State<ZabetTimerScreen> with SingleTickerProviderStateMixin {
  static const int defaultTime = 60;
  int _totalSeconds = defaultTime;
  int _remainingSeconds = defaultTime;
  Timer? _timer;
  bool _isRunning = false;

  late AnimationController _pulseController;
  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _initNotifications();
  }

  void _initNotifications() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(initSettings);

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // 1. إنشاء القناة صراحةً لضمان عمل الإشعارات في نسخة الـ Release
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'zabet_timer_channel',
        'مؤقت ضابط',
        description: 'إشعارات تقدم الوقت لمؤقت التمرين',
        importance: Importance.low,
      );

      await androidPlugin.createNotificationChannel(channel);

      // 2. طلب إذن الإشعارات لأندرويد 13+
      await androidPlugin.requestNotificationsPermission();
    }
  }

  void _updateNotification(int secondsLeft) async {
    final String timeStr = _formatTime(secondsLeft);

    final androidDetails = AndroidNotificationDetails(
      'zabet_timer_channel',
      'timer_channel_name'.tr(),
      channelDescription: 'timer_channel_desc'.tr(),
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      icon: '@mipmap/launcher_icon', // استخدام أيقونة التطبيق المسجلة دائماً
      styleInformation: BigTextStyleInformation(
        'timer_notification_big_text'.tr(args: [timeStr]),
        contentTitle: 'timer_notification_title'.tr(),
        summaryText: 'Zabet Timer',
      ),
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    try {
      await _notificationsPlugin.show(
        888,
        'timer_notification_title'.tr(),
        'timer_notification_body'.tr(args: [timeStr]),
        notificationDetails,
      );
    } catch (e) {
      debugPrint("Notification Release Error: $e");
    }
  }

  void _cancelNotification() async {
    await _notificationsPlugin.cancel(888);
  }

  void _startTimer() {
    if (_isRunning) return;
    HapticFeedback.mediumImpact();

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (_remainingSeconds <= 3) {
          HapticFeedback.lightImpact();
        }
        setState(() {
          _remainingSeconds--;
        });
        _updateNotification(_remainingSeconds);
      } else {
        _stopTimer();
        HapticFeedback.heavyImpact();
        _cancelNotification();
        _showTimerFinishedDialog();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    HapticFeedback.selectionClick();
    _cancelNotification();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _pauseTimer();
    HapticFeedback.lightImpact();
    setState(() {
      _remainingSeconds = _totalSeconds;
    });
  }

  void _adjustTime(int seconds) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_isRunning) {
        _remainingSeconds = (_remainingSeconds + seconds).clamp(1, 3600);
        if (_remainingSeconds > _totalSeconds) {
          _totalSeconds = _remainingSeconds;
        }
      } else {
        _totalSeconds = (_totalSeconds + seconds).clamp(10, 600);
        _remainingSeconds = _totalSeconds;
      }
    });

    if (_isRunning) {
      _updateNotification(_remainingSeconds);
    }
  }

  void _setTimerDuration(int seconds) {
    _pauseTimer();
    HapticFeedback.selectionClick();
    setState(() {
      _totalSeconds = seconds;
      _remainingSeconds = seconds;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _showTimerFinishedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.bolt, color: Colors.deepOrange, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'timer_finished_title'.tr(),
                style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          'timer_finished_body'.tr(),
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetTimer();
            },
            child: Text(
              'let_us_go'.tr(),
              style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSecs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSecs';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cancelNotification();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progress = _totalSeconds > 0 ? _remainingSeconds / _totalSeconds : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'zabet_timer_title'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ScaleTransition(
                scale: _isRunning
                    ? Tween<double>(begin: 1.0, end: 1.02).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut))
                    : const AlwaysStoppedAnimation(1.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 14,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(_remainingSeconds),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: 2,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: _isRunning ? Colors.deepOrange.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _isRunning ? 'timer_status_running'.tr() : 'timer_status_ready'.tr(),
                            style: TextStyle(
                              color: _isRunning ? Colors.deepOrange : Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildQuickAdjustButton(
                    label: 'sub_15_sec'.tr(),
                    onTap: () => _adjustTime(-15),
                  ),
                  const SizedBox(width: 16),
                  _buildQuickAdjustButton(
                    label: 'add_30_sec'.tr(),
                    onTap: () => _adjustTime(30),
                  ),
                ],
              ),

              Column(
                children: [
                  Text(
                    'quick_rest_programs'.tr(),
                    style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildPresetButton(label: '30 ${'sec_short'.tr()}', seconds: 30),
                      _buildPresetButton(label: '60 ${'sec_short'.tr()}', seconds: 60),
                      _buildPresetButton(label: '90 ${'sec_short'.tr()}', seconds: 90),
                      _buildPresetButton(label: '2 ${'min_short'.tr()}', seconds: 120),
                      _buildPresetButton(label: '3 ${'min_short'.tr()}', seconds: 180),
                    ],
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    heroTag: 'resetBtn',
                    onPressed: _resetTimer,
                    backgroundColor: const Color(0xFFE2E8F0),
                    elevation: 0,
                    child: const Icon(Icons.refresh_rounded, color: Color(0xFF1E293B), size: 28),
                  ),
                  const SizedBox(width: 24),
                  SizedBox(
                    width: 75,
                    height: 75,
                    child: FloatingActionButton(
                      heroTag: 'playPauseBtn',
                      onPressed: _isRunning ? _pauseTimer : _startTimer,
                      backgroundColor: Colors.deepOrange,
                      elevation: 3,
                      child: Icon(
                        _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAdjustButton({required String label, required VoidCallback onTap}) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFCBD5E1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFF1E293B), fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPresetButton({required String label, required int seconds}) {
    final isSelected = _totalSeconds == seconds;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.deepOrange,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF1E293B),
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: isSelected ? Colors.deepOrange : const Color(0xFFCBD5E1)),
      ),
      onSelected: (selected) {
        if (selected) {
          _setTimerDuration(seconds);
        }
      },
    );
  }
}