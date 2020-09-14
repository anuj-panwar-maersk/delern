import 'dart:async';
import 'dart:math';

import 'package:delern_flutter/remote/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef NotificationReceivedCallback = void Function(
    ReceivedNotification notification);
typedef NotificationPressedCallback = void Function(String payload);

class LocalNotifications with ChangeNotifier, DiagnosticableTreeMixin {
  final NotificationReceivedCallback onNotificationReceived;
  final NotificationPressedCallback onNotificationPressed;

  LocalNotifications(
      {this.onNotificationReceived, this.onNotificationPressed}) {
    _init();
    _initUserScheduledNotifications();
  }

  final _notificationsSchedule = <TimeOfDay, List<int>>{};

  Map<TimeOfDay, List<int>> get userSchedule => _notificationsSchedule;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationAppLaunchDetails _notificationAppLaunchDetails;

  Future<void> _init() async {
    _notificationAppLaunchDetails = await _flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();
    const initializationSettingsAndroid =
        AndroidInitializationSettings('delern');
    // Notification permissions are not requested to be able to ask it later.
    final initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification: (id, title, body, payload) async {
          onNotificationReceived(ReceivedNotification(
              id: id, title: title, body: body, payload: payload));
        });
    final initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payload) async {
      onNotificationPressed?.call(payload);
    });
  }

  void _initUserScheduledNotifications() {
    if (AppConfig.instance.isNotificationsSet) {
      // TODO: restore notifications
    } else {
      addNewReminderRule();
    }
  }

  void _scheduleWeeklyNotification(TimeOfDay time, int day) async {
    final notificationTime = Time(time.hour, time.minute);
    Day notificationDay;
    switch (day) {
      case DateTime.monday:
        notificationDay = Day.Monday;
        break;
      case DateTime.tuesday:
        notificationDay = Day.Tuesday;
        break;
      case DateTime.wednesday:
        notificationDay = Day.Wednesday;
        break;
      case DateTime.thursday:
        notificationDay = Day.Thursday;
        break;
      case DateTime.friday:
        notificationDay = Day.Friday;
        break;
      case DateTime.saturday:
        notificationDay = Day.Saturday;
        break;

      default:
        notificationDay = Day.Sunday;
    }
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '${time.hour}:${time.minute} on $day day of week',
        '${time.hour}:${time.minute} on $day day of week', '''
Shows weekly notifications at ${time.hour}:${time.minute} on $day day of week''');
    const iOSPlatformChannelSpecifics = IOSNotificationDetails();
    final platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
        _calculateNotificationId(time, day),
        'show weekly title',
        null,
        notificationDay,
        notificationTime,
        platformChannelSpecifics);
  }

  void _cancelWeeklyNotification(TimeOfDay time, int day) {
    _flutterLocalNotificationsPlugin.cancel(
      _calculateNotificationId(time, day),
    );
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

  int _calculateNotificationId(TimeOfDay time, int day) {
    return (time.hashCode + day.hashCode).hashCode;
  }

  // TODO: remove it
  Future<void> showNotificationNow() async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    final iOSPlatformChannelSpecifics = IOSNotificationDetails();
    final platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
        0, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item x');
  }

  void changedDayForWeekByTime(TimeOfDay time, int weekDay) {
    final weekSchedule = _notificationsSchedule[time];
    if (weekSchedule.contains(weekDay)) {
      weekSchedule.remove(weekDay);
    } else {
      weekSchedule.add(weekDay);
    }
    notifyListeners();
  }

  void changeTime(TimeOfDay previousTime, TimeOfDay newTime) {
    final weekSchedule = _notificationsSchedule[previousTime];
    _notificationsSchedule.remove(previousTime);
    _notificationsSchedule[newTime] = weekSchedule;
    notifyListeners();
  }

  void addNewReminderRule() {
    var now = TimeOfDay.now();
    if (_notificationsSchedule.containsKey(now)) {
      final randomNumber = Random().nextInt(10) + 1;
      now = TimeOfDay(
          hour: TimeOfDay.now().hour,
          minute: TimeOfDay.now().minute + randomNumber);
    }
    _notificationsSchedule[now] = <int>[
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
      DateTime.sunday,
    ];
    notifyListeners();
  }

  void deleteNotificationRule(TimeOfDay time) {
    _notificationsSchedule.remove(time);
    notifyListeners();
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
