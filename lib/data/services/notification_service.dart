import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tzlib;

import 'user_preferences_service.dart';

/// Background notification tap handler — must be top-level function.
@pragma('vm:entry-point')
void _onBackgroundNotificationTap(NotificationResponse response) {
  // No-op: app will open normally when tapped
}

@lazySingleton
class NotificationService {
  static const int _dailyReminderId = 100;
  static const String _channelId = 'quies_daily_reminder';
  static const String _channelName = 'Daily Reminder';
  static const String _channelDesc =
      'A gentle daily reminder to take a moment of peace';

  final FlutterLocalNotificationsPlugin _plugin;
  final UserPreferencesService _prefs;
  bool _initialized = false;

  /// Whether the notification plugin is available.
  bool get isAvailable => _initialized;

  NotificationService(this._prefs)
    : _plugin = FlutterLocalNotificationsPlugin();

  /// Call once at app startup (after DI is ready).
  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    try {
      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (_) {},
        onDidReceiveBackgroundNotificationResponse:
            _onBackgroundNotificationTap,
      );
      _initialized = true;
    } catch (e) {
      // Plugin channel not available (e.g. hot restart without native rebuild).
      // Notifications will be unavailable this session.
      debugPrint('NotificationService init failed: $e');
      _initialized = false;
      return;
    }

    // Re-schedule if enabled (covers device reboot scenario)
    if (_prefs.notificationsEnabled) {
      await scheduleDailyReminder(
        hour: _prefs.reminderHour,
        minute: _prefs.reminderMinute,
      );
    }
  }

  // ── Permissions ──────────────────────────────────────────────

  Future<bool> requestPermissions() async {
    if (!_initialized) return false;

    if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? false;
    }

    return true;
  }

  // ── Scheduling ───────────────────────────────────────────────

  /// Schedule a daily notification at the given [hour] and [minute].
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) return;

    // Cancel any existing reminder first
    await _plugin.cancel(id: _dailyReminderId);

    final scheduledDate = _nextInstanceOfTime(hour, minute);

    await _plugin.zonedSchedule(
      id: _dailyReminderId,
      title: 'A moment of peace awaits',
      body: 'Take a breath, open Quies, and find your quote.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // repeats daily
    );

    // Persist preferences
    await _prefs.setNotificationsEnabled(true);
    await _prefs.setReminderHour(hour);
    await _prefs.setReminderMinute(minute);
  }

  /// Cancel the daily reminder.
  Future<void> cancelDailyReminder() async {
    if (!_initialized) {
      await _prefs.setNotificationsEnabled(false);
      return;
    }

    await _plugin.cancel(id: _dailyReminderId);
    await _prefs.setNotificationsEnabled(false);
  }

  // ── Helpers ──────────────────────────────────────────────────

  tzlib.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tzlib.TZDateTime.now(tzlib.local);
    var scheduled = tzlib.TZDateTime(
      tzlib.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
