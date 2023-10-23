import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final notificationPlugin = FlutterLocalNotificationsPlugin();

  NotificationService() {
    initNotifications();
  }

  Future<void> initNotifications() async {
    var initializeMacOs = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: (id, title, body, payload) {});

    var initializeSettings = InitializationSettings(macOS: initializeMacOs);
    await notificationPlugin.initialize(initializeSettings,
        onDidReceiveNotificationResponse: (details) {});
  }

  Future showNotification(
      {int id = 0, String? title, String? body, String? payload}) {
    return notificationPlugin.show(id, title, body,
        NotificationDetails(macOS: DarwinNotificationDetails()));
  }
}
