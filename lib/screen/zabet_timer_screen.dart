import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:vibration/vibration.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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

  // إعلانات جوجل أداموب
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  // ميزات كتم الصوت وحساب الجولات
  bool _isMuted = false;
  int _currentSet = 1;
  int _totalSets = 4;

  late AnimationController _pulseController;
  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _initNotifications();
    _initAudioPlayer();
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

  void _initAudioPlayer() async {
    await _audioPlayer.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.alarm,
          audioFocus: AndroidAudioFocus.gainTransient,
        ),
      ),
    );
  }

  void _initNotifications() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(initSettings);

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'zabet_timer_channel',
        'مؤقت ضابط',
        description: 'إشعارات تقدم الوقت لمؤقت التمرين',
        importance: Importance.low,
      );

      await androidPlugin.createNotificationChannel(channel);
      await androidPlugin.requestNotificationsPermission();
    }
  }

  void _playAlarmSound() async {
    if (_isMuted) return;
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
    } catch (e) {
      debugPrint("خطأ في تشغيل الصوت: $e");
    }
  }

  void _stopAlarmSound() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint("خطأ في إيقاف الصوت: $e");
    }
  }

  void _triggerVibrationPattern() async {
    try {
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(pattern: [0, 400, 150, 400, 150, 600]);
      } else {
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
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
      icon: '@mipmap/launcher_icon',
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
    _stopAlarmSound();
    HapticFeedback.mediumImpact();

    WakelockPlus.enable();

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
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
        _triggerVibrationPattern();
        _cancelNotification();
        _playAlarmSound();
        if (mounted) {
          _showTimerFinishedDialog();
        }
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _stopAlarmSound();
    WakelockPlus.disable();
    HapticFeedback.selectionClick();
    _cancelNotification();
    if (mounted) {
      setState(() {
        _isRunning = false;
      });
    }
  }

  void _resetTimer() {
    _pauseTimer();
    _stopAlarmSound();
    HapticFeedback.lightImpact();
    if (mounted) {
      setState(() {
        _remainingSeconds = _totalSeconds;
      });
    }
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
    WakelockPlus.disable();
    if (mounted) {
      setState(() {
        _isRunning = false;
      });
    }
  }

  void _showTimerFinishedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.bolt_rounded, color: Colors.deepOrange, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'timer_finished_title'.tr(),
                style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'timer_finished_body'.tr(),
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.deepOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('set_completed'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                  Text("$_currentSet / $_totalSets", style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w900, fontSize: 15)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _stopAlarmSound();
              Vibration.cancel();
              Navigator.pop(context);
              if (mounted) {
                setState(() {
                  if (_currentSet < _totalSets) {
                    _currentSet++;
                  }
                });
                _resetTimer();
              }
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
    _audioPlayer.dispose();
    _bannerAd?.dispose();
    WakelockPlus.disable();
    Vibration.cancel();
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
        actions: [
          IconButton(
            icon: Icon(
              _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: _isMuted ? Colors.redAccent : Colors.deepOrange,
            ),
            tooltip: _isMuted ? 'unmute'.tr() : 'mute'.tr(),
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() {
                _isMuted = !_isMuted;
                if (_isMuted) _stopAlarmSound();
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.fitness_center_rounded, color: Colors.deepOrange, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'set_progress'.tr(args: ['$_currentSet', '$_totalSets']),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.remove_circle_outline_rounded, size: 22, color: Colors.black54),
                          onPressed: () {
                            if (_totalSets > 1) {
                              setState(() {
                                _totalSets--;
                                if (_currentSet > _totalSets) _currentSet = _totalSets;
                              });
                            }
                          },
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.add_circle_outline_rounded, size: 22, color: Colors.deepOrange),
                          onPressed: () {
                            setState(() {
                              _totalSets++;
                            });
                          },
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.refresh_rounded, size: 20, color: Colors.black45),
                          tooltip: 'reset_sets'.tr(),
                          onPressed: () {
                            setState(() {
                              _currentSet = 1;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

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