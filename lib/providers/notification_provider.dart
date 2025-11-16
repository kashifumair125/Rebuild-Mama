import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'preferences_provider.dart';

part 'notification_provider.g.dart';

/// Notification types
enum NotificationType {
  workout,
  progress,
  reminder,
}

/// Notification model
class NotificationConfig {
  final int id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime scheduledTime;

  const NotificationConfig({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.scheduledTime,
  });
}

/// Provider for FlutterLocalNotificationsPlugin instance
@Riverpod(keepAlive: true)
FlutterLocalNotificationsPlugin notificationPlugin(
  NotificationPluginRef ref,
) {
  final plugin = FlutterLocalNotificationsPlugin();

  // Initialize the plugin
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  plugin.initialize(initSettings);

  return plugin;
}

/// Provider for notification service
@riverpod
NotificationService notificationService(NotificationServiceRef ref) {
  final plugin = ref.watch(notificationPluginProvider);
  final areNotificationsEnabled = ref.watch(areNotificationsEnabledProvider);

  return NotificationService(
    plugin: plugin,
    enabled: areNotificationsEnabled,
  );
}

/// Notification service class
class NotificationService {
  final FlutterLocalNotificationsPlugin plugin;
  final bool enabled;

  NotificationService({
    required this.plugin,
    required this.enabled,
  });

  /// Request notification permissions (iOS)
  Future<bool> requestPermissions() async {
    final result = await plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    return result ?? false;
  }

  /// Schedule a notification
  Future<void> scheduleNotification(NotificationConfig config) async {
    if (!enabled) {
      return;
    }

    final scheduledDate = tz.TzDateTime.from(
      config.scheduledTime,
      tz.local,
    );

    await plugin.zonedSchedule(
      config.id,
      config.title,
      config.body,
      scheduledDate,
      _notificationDetails(config.type),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Schedule a daily notification
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required Time time,
    required NotificationType type,
  }) async {
    if (!enabled) {
      return;
    }

    await plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(time),
      _notificationDetails(type),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedule a weekly notification
  Future<void> scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required Day day,
    required Time time,
    required NotificationType type,
  }) async {
    if (!enabled) {
      return;
    }

    await plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfDayAndTime(day, time),
      _notificationDetails(type),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// Cancel a notification
  Future<void> cancelNotification(int id) async {
    await plugin.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await plugin.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await plugin.pendingNotificationRequests();
  }

  /// Show an immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required NotificationType type,
  }) async {
    if (!enabled) {
      return;
    }

    await plugin.show(
      id,
      title,
      body,
      _notificationDetails(type),
    );
  }

  /// Get notification details based on type
  NotificationDetails _notificationDetails(NotificationType type) {
    const androidDetails = AndroidNotificationDetails(
      'postpartum_app_channel',
      'Postpartum App Notifications',
      channelDescription: 'Notifications for workout reminders and progress',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  /// Calculate next instance of time
  tz.TzDateTime _nextInstanceOfTime(Time time) {
    final now = tz.TzDateTime.now(tz.local);
    var scheduledDate = tz.TzDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      time.second,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Calculate next instance of day and time
  tz.TzDateTime _nextInstanceOfDayAndTime(Day day, Time time) {
    final now = tz.TzDateTime.now(tz.local);
    final targetDay = _dayToWeekday(day);

    var scheduledDate = tz.TzDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      time.second,
    );

    while (scheduledDate.weekday != targetDay || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Convert Day enum to weekday integer
  int _dayToWeekday(Day day) {
    switch (day) {
      case Day.monday:
        return DateTime.monday;
      case Day.tuesday:
        return DateTime.tuesday;
      case Day.wednesday:
        return DateTime.wednesday;
      case Day.thursday:
        return DateTime.thursday;
      case Day.friday:
        return DateTime.friday;
      case Day.saturday:
        return DateTime.saturday;
      case Day.sunday:
        return DateTime.sunday;
    }
  }
}

/// Provider to schedule a workout reminder
@riverpod
class WorkoutReminderScheduler extends _$WorkoutReminderScheduler {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Schedule a daily workout reminder
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(notificationServiceProvider);

      await service.scheduleDailyNotification(
        id: 1, // Workout reminder ID
        title: 'Time for your workout!',
        body: 'Complete your postpartum recovery exercises today.',
        time: Time(hour, minute),
        type: NotificationType.workout,
      );

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Cancel workout reminder
  Future<void> cancelReminder() async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(notificationServiceProvider);
      await service.cancelNotification(1);

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Provider to schedule a progress check reminder
@riverpod
class ProgressReminderScheduler extends _$ProgressReminderScheduler {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Schedule a weekly progress check reminder
  Future<void> scheduleWeeklyReminder({
    required Day day,
    required int hour,
    required int minute,
  }) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(notificationServiceProvider);

      await service.scheduleWeeklyNotification(
        id: 2, // Progress reminder ID
        title: 'Time to track your progress!',
        body: 'Record your diastasis and pelvic floor measurements.',
        day: day,
        time: Time(hour, minute),
        type: NotificationType.progress,
      );

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Cancel progress reminder
  Future<void> cancelReminder() async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(notificationServiceProvider);
      await service.cancelNotification(2);

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
