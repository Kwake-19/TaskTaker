import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// 🔔 Centralized notification manager
/// - System notifications (Android / iOS)
/// - In-app fallback (guaranteed while app is alive)
class NotificationService {
  NotificationService._(); // no instances

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'task_channel';

  /// In-app fallback timers (per task)
  static final Map<int, Timer> _inAppTimers = {};

  // ───────────────── INIT ─────────────────

  static Future<void> init() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    // ───────────────── 🔥 FIX #1: FORCE CORRECT LOCAL TIMEZONE 🔥 ─────────────────
    // Tecno & some Android devices resolve tz.local as UTC → notifications never show
    // Cameroon is UTC+1 with NO DST → Africa/Douala is 100% correct
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Douala'));

    if (kDebugMode) {
      debugPrint('🌍 Forced timezone: ${tz.local.name}');
    }
    // ───────────────── END FIX ─────────────────

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        if (kDebugMode) {
          debugPrint('🔔 Notification tapped: ${details.payload}');
        }
      },
    );

    if (Platform.isAndroid) {
      await _createAndroidChannel();
      await _requestAndroidPermissions();
    } else if (Platform.isIOS) {
      await _requestIOSPermissions();
    }

    if (kDebugMode) {
      debugPrint('✅ NotificationService initialized');
    }
  }

  // ───────────────── ANDROID SETUP ─────────────────

  static Future<void> _createAndroidChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      'Task Reminders',
      description: 'Notifications for scheduled tasks',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(channel);

    if (kDebugMode) {
      debugPrint('📱 Android notification channel created');
    }
  }

  static Future<void> _requestAndroidPermissions() async {
    // Android 13+ notification permission
    final notificationStatus = await Permission.notification.request();

    if (kDebugMode) {
      debugPrint('📱 Notification permission: $notificationStatus');
    }

    // Android 12+ exact alarm permission
    if (await Permission.scheduleExactAlarm.isDenied) {
      final alarmStatus = await Permission.scheduleExactAlarm.request();

      if (kDebugMode) {
        debugPrint('⏰ Exact alarm permission: $alarmStatus');
      }
    }
  }

  static Future<void> _requestIOSPermissions() async {
    final plugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    final granted = await plugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      debugPrint('🍎 iOS permissions granted: $granted');
    }
  }

  // ───────────────── PUBLIC API ─────────────────

  /// ✅ Schedule notification for a specific task & time
  static Future<void> schedule({
    required int id,
    required String title,
    required DateTime time,
    VoidCallback? onInAppReminder,
  }) async {
    if (kDebugMode) {
      debugPrint('🔔 Scheduling notification');
      debugPrint('   ID: $id');
      debugPrint('   Title: $title');
      debugPrint('   Time (local): $time');
      debugPrint('   Now: ${DateTime.now()}');
      debugPrint('   Difference: ${time.difference(DateTime.now())}');
    }

    // ❌ Do not allow past scheduling
    if (time.isBefore(DateTime.now())) {
      if (kDebugMode) {
        debugPrint('⚠️ Cannot schedule notification in the past');
      }
      return;
    }

    // Cancel any existing reminder for this task
    await cancel(id);

    // 1️⃣ In-app fallback (guaranteed while app is open)
    if (onInAppReminder != null) {
      _scheduleInApp(
        id: id,
        time: time,
        onFire: onInAppReminder,
      );
    }

    // 2️⃣ System notification (Android / iOS)
    await _scheduleSystem(id, title, time);
  }

  /// ❌ Cancel task notification
  static Future<void> cancel(int id) async {
    _cancelInApp(id);
    await _plugin.cancel(id);

    if (kDebugMode) {
      debugPrint('🚫 Cancelled notification: $id');
    }
  }

  // ───────────────── INTERNAL: IN-APP FALLBACK ─────────────────

  static void _scheduleInApp({
    required int id,
    required DateTime time,
    required VoidCallback onFire,
  }) {
    final delay = time.difference(DateTime.now());

    if (delay.isNegative) return;

    _inAppTimers[id] = Timer(delay, () {
      if (kDebugMode) {
        debugPrint('🔔 In-app reminder fired for task: $id');
      }
      onFire();
    });

    if (kDebugMode) {
      debugPrint('⏲️ In-app timer scheduled (${delay.inSeconds}s)');
    }
  }

  static void _cancelInApp(int id) {
    _inAppTimers[id]?.cancel();
    _inAppTimers.remove(id);
  }

  // ───────────────── INTERNAL: SYSTEM NOTIFICATION ─────────────────

  static Future<void> _scheduleSystem(
    int id,
    String title,
    DateTime time,
  ) async {
    // ───────────────── 🔥 FIX #2: BUILD TZDateTime MANUALLY 🔥 ─────────────────
    // DO NOT use tz.TZDateTime.from()
    // It converts back to UTC on some Android devices
    final scheduled = tz.TZDateTime(
      tz.local,
      time.year,
      time.month,
      time.day,
      time.hour,
      time.minute,
      time.second,
    );
    // ───────────────── END FIX ─────────────────

    if (kDebugMode) {
      debugPrint('📅 FINAL SYSTEM TIME (LOCAL): $scheduled');
    }

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      'Task Reminders',
      channelDescription: 'Exact-time task reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      'Task Reminder',
      title,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    if (kDebugMode) {
      debugPrint('✅ System notification scheduled successfully');
    }
  }
}
