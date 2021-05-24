import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationManager {
  static void createAvailableNotification(List<String> availableCenters) {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings('app_icon'));
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            "12345", "Cowin Alerts", "Alerts for Covid Vaccination");
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidNotificationDetails);
    flutterLocalNotificationsPlugin.show(
        12345,
        "Cowin Notifications",
        availableCenters.length > 1
            ? "${availableCenters[0]} + ${availableCenters.length - 1} Centers have open slots available"
            : "${availableCenters[0]} has open slots available for vaccination",
        platformChannelSpecifics,
        payload: 'data');
  }
}
