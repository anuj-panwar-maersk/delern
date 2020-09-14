import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// TODO: use callbacks instead of streams
class Notifications {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationAppLaunchDetails _notificationAppLaunchDetails;

  final StreamController<ReceivedNotification> _onReceiveLocalNotification =
      StreamController<ReceivedNotification>();

  Stream<ReceivedNotification> get _onReceiveLocalNotificationsStream =>
      _onReceiveLocalNotification.stream;

  final StreamController<String> _onSelectNotification =
      StreamController<String>();

  Stream<String> get onSelectNotification => _onSelectNotification.stream;

  void _init() async {
    _notificationAppLaunchDetails = await _flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();
    const initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    // Notification permissions are not requested to be able to ask it later.
    final initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification: (id, title, body, payload) async {
          _onReceiveLocalNotification.add(ReceivedNotification(
              id: id, title: title, body: body, payload: payload));
        });
    final initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
      }
      _onSelectNotification.add(payload);
    });
  }

  void requestIOSPermissions() {
    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }
}

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.payload,
    this.body,
  });
}
