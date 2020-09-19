import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:delern_flutter/models/notification_payload.dart';
import 'package:delern_flutter/models/notification_schedule.dart';
import 'package:delern_flutter/models/serializers.dart';
import 'package:delern_flutter/remote/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

var week = BuiltList<int>.build((l) => l.addAll([
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
      DateTime.sunday,
    ])).toBuiltList();

typedef NotificationReceivedCallback = void Function(
    NotificationPayload notification);

typedef NotificationPressedCallback = void Function(
    NotificationPayload payload);

class LocalNotifications extends ChangeNotifier with DiagnosticableTreeMixin {
  final NotificationReceivedCallback onNotificationReceived;
  final NotificationPressedCallback onNotificationPressed;
  final List<String> messages;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  LocalNotifications({
    @required this.onNotificationReceived,
    @required this.onNotificationPressed,
    @required this.messages,
    @required this.flutterLocalNotificationsPlugin,
  }) {
    _init();
    _initUserScheduledNotifications();
  }

  BuiltMap<TimeOfDay, BuiltList<int>> get userSchedule =>
      _notificationsSchedule.notificationSchedule.build();

  NotificationScheduleBuilder _notificationsSchedule =
      NotificationScheduleBuilder()
        ..notificationSchedule[TimeOfDay.now()] = week;

  //NotificationAppLaunchDetails _notificationAppLaunchDetails;

  Future<void> _init() async {
    // _notificationAppLaunchDetails = await _flutterLocalNotificationsPlugin
    //     .getNotificationAppLaunchDetails();

    const initializationSettingsAndroid =
        AndroidInitializationSettings('delern');
    // Notification permissions are not requested to be able to ask it later.
    final initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification: (id, title, body, payload) async {
          final payloadData = serializers.deserializeWith(
              NotificationPayload.serializer, json.decode(payload));
          onNotificationReceived(payloadData);
        });
    final initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payload) async {
      final payloadData = serializers.deserializeWith(
          NotificationPayload.serializer, json.decode(payload));
      onNotificationPressed?.call(payloadData);
    });
  }

  void _saveNotificationsToAppSettings() {
    AppConfig.instance.isNotificationsSet = true;
    AppConfig.instance.notificationSchedule =
        json.encode(serializers.serialize(_notificationsSchedule.build()));
  }

  Future<void> _initUserScheduledNotifications() async {
    if (AppConfig.instance.isNotificationsSet &&
        (await getPendingNotifications()).isNotEmpty) {
      final notificationScheduleFromAppSettings = serializers.deserializeWith(
          NotificationSchedule.serializer,
          json.decode(AppConfig.instance.notificationSchedule));
      _notificationsSchedule = notificationScheduleFromAppSettings.toBuilder();
    } else {
      // If notifications weren't setup, set default value
      _saveNotificationsToAppSettings();
    }
  }

  Future<void> _scheduleWeeklyNotification(TimeOfDay time, int day) async {
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
        '${time.hour}:${time.minute} on $day day of week',
        '''
Shows weekly notifications at ${time.hour}:${time.minute} on $day day of week''',
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'ticker');
    const iOSPlatformChannelSpecifics = IOSNotificationDetails();
    final platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics,
      iOSPlatformChannelSpecifics,
    );
    final title = messages[Random().nextInt(messages.length)];
    final payloadBuilder = NotificationPayloadBuilder()
      ..title = title
      ..subtitle = ''
      ..time = time
      ..day = day;

    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
        _calculateNotificationId(time, day),
        title,
        null,
        notificationDay,
        notificationTime,
        platformChannelSpecifics,
        payload: json.encode(serializers.serialize(payloadBuilder.build())));
  }

  void _cancelWeeklyNotification(TimeOfDay time, int day) {
    flutterLocalNotificationsPlugin.cancel(
      _calculateNotificationId(time, day),
    );
  }

  void requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  int _calculateNotificationId(TimeOfDay time, int day) =>
      (time.hashCode + day.hashCode).hashCode;

  void changedWeekDaysForTime(TimeOfDay time, int weekDay) {
    final weekSchedule = _notificationsSchedule.notificationSchedule[time];
    BuiltList<int> updatedWeekSchedule;
    if (weekSchedule.contains(weekDay)) {
      updatedWeekSchedule = weekSchedule.rebuild((w) => w.remove(weekDay));
      _cancelWeeklyNotification(time, weekDay);
    } else {
      _scheduleWeeklyNotification(time, weekDay);
      updatedWeekSchedule = weekSchedule.rebuild((w) => w.add(weekDay));
    }
    _notificationsSchedule.notificationSchedule[time] = updatedWeekSchedule;
    _saveNotificationsToAppSettings();
    notifyListeners();
  }

  void changeTime(TimeOfDay previousTime, TimeOfDay newTime) {
    final weekSchedule =
        _notificationsSchedule.notificationSchedule[previousTime];
    _notificationsSchedule.notificationSchedule.remove(previousTime);
    for (final day in weekSchedule) {
      _cancelWeeklyNotification(previousTime, day);
    }
    _notificationsSchedule.notificationSchedule[newTime] = weekSchedule;
    for (final day in weekSchedule) {
      _scheduleWeeklyNotification(newTime, day);
    }
    _saveNotificationsToAppSettings();
    notifyListeners();
  }

  void addNewReminderRule() {
    var now = TimeOfDay.now();

    if (_notificationsSchedule.notificationSchedule.build().containsKey(now)) {
      final randomNumber = Random().nextInt(10) + 1;
      now = TimeOfDay(
          hour: TimeOfDay.now().hour,
          minute: TimeOfDay.now().minute + randomNumber);
    }

    _notificationsSchedule.notificationSchedule[now] = week;
    for (final day in week) {
      _scheduleWeeklyNotification(now, day);
    }
    _saveNotificationsToAppSettings();
    notifyListeners();
  }

  void deleteReminderRule(TimeOfDay time) {
    for (final day in _notificationsSchedule.notificationSchedule[time]) {
      _cancelWeeklyNotification(time, day);
    }
    _notificationsSchedule.notificationSchedule.remove(time);
    _saveNotificationsToAppSettings();
    notifyListeners();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async =>
      flutterLocalNotificationsPlugin.pendingNotificationRequests();
}
