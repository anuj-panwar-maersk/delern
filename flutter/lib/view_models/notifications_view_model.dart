import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:built_collection/built_collection.dart';
import 'package:delern_flutter/models/local_notification.dart';
import 'package:delern_flutter/models/notification_payload.dart';
import 'package:delern_flutter/models/notification_schedule.dart';
import 'package:delern_flutter/models/serializers.dart';
import 'package:delern_flutter/remote/analytics.dart';
import 'package:delern_flutter/remote/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pedantic/pedantic.dart';

var _week = BuiltList<int>(<int>[
  DateTime.monday,
  DateTime.tuesday,
  DateTime.wednesday,
  DateTime.thursday,
  DateTime.friday,
  DateTime.saturday,
  DateTime.sunday,
]);

// DateTime for day of week is int
final _dateTimeWeekToDay = <int, Day>{
  DateTime.monday: Day.Monday,
  DateTime.tuesday: Day.Tuesday,
  DateTime.wednesday: Day.Wednesday,
  DateTime.thursday: Day.Thursday,
  DateTime.friday: Day.Friday,
  DateTime.saturday: Day.Saturday,
  DateTime.sunday: Day.Sunday,
};

typedef NotificationPressedCallback = void Function(
    NotificationPayload payload);

class LocalNotifications extends ChangeNotifier with DiagnosticableTreeMixin {
  final NotificationPressedCallback onNotificationPressed;
  final List<LocalNotification> messages;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  bool _isNotificationScheduled = false;
  bool _iosPermissionGranted = false;
  final String notificationPurpose;

  bool get isNotificationScheduled => _isNotificationScheduled;

  LocalNotifications({
    @required this.onNotificationPressed,
    @required this.messages,
    @required this.flutterLocalNotificationsPlugin,
    @required this.notificationPurpose,
  }) {
    _init();
    _initUserScheduledNotifications();
  }

  BuiltMap<TimeOfDay, BuiltList<int>> get userSchedule =>
      _notificationsSchedule.notificationSchedule.build();

  NotificationScheduleBuilder _notificationsSchedule =
      NotificationScheduleBuilder();

  Future<void> _init() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('delern');
    // Notification permissions are not requested to be able to ask it later.
    const initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false);
    const initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payload) async {
      final payloadData = serializers.deserializeWith(
          NotificationPayload.serializer, json.decode(payload));
      onNotificationPressed?.call(payloadData);
    });
  }

  void showNotificationSuggestion() {
    _isNotificationScheduled = true;
    AppConfig.instance.isNotificationsSet = true;
  }

  void _saveNotificationsToAppSettings() {
    AppConfig.instance.isNotificationsSet = true;
    AppConfig.instance.notificationSchedule =
        json.encode(serializers.serialize(_notificationsSchedule.build()));
    _isNotificationScheduled = true;
  }

  Future<void> _initUserScheduledNotifications() async {
    if (AppConfig.instance.isNotificationsSet) {
      final notificationScheduleFromAppSettings = serializers.deserializeWith(
          NotificationSchedule.serializer,
          json.decode(AppConfig.instance.notificationSchedule ?? '{}'));
      _notificationsSchedule = notificationScheduleFromAppSettings.toBuilder();
      _isNotificationScheduled = true;
    }
  }

  Future<bool> _checkPermissions() async {
    if (Platform.isIOS && !_iosPermissionGranted) {
      _iosPermissionGranted = await _requestIOSPermissions();
      unawaited(
          logIosNotificationPermissions(isGranted: _iosPermissionGranted));
    }
    if (Platform.isIOS) {
      return _iosPermissionGranted;
    } else {
      return true;
    }
  }

  Future<void> scheduleDefaultNotifications() async {
    await addNewReminderRule(time: TimeOfDay.now(), isDefaultRule: true);
    _saveNotificationsToAppSettings();
  }

  bool isTimeAlreadyScheduled(TimeOfDay time) =>
      _notificationsSchedule.build().notificationSchedule.containsKey(time);

  Future<void> _scheduleWeeklyNotification(TimeOfDay time, int day) async {
    final notificationTime = Time(time.hour, time.minute);
    final notificationDay = _dateTimeWeekToDay[day];
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      notificationPurpose,
      notificationPurpose,
      notificationPurpose,
      importance: Importance.Max,
      priority: Priority.High,
      ticker: 'ticker',
    );
    const iOSPlatformChannelSpecifics = IOSNotificationDetails();
    final platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics,
      iOSPlatformChannelSpecifics,
    );
    final title = messages[Random().nextInt(messages.length)].title;
    final body = messages[Random().nextInt(messages.length)].body;
    final payloadBuilder = NotificationPayloadBuilder()
      ..title = title
      ..body = body ?? ''
      ..time = time
      ..day = day;

    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
        _calculateNotificationId(time, day),
        title,
        body,
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

  Future<bool> _requestIOSPermissions() => flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

  int _calculateNotificationId(TimeOfDay time, int day) =>
      time.hour * 60 + time.minute + day * 24 * 60;

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

  void changedTime(TimeOfDay previousTime, TimeOfDay newTime) {
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

  Future<void> addNewReminderRule(
      {@required TimeOfDay time, bool isDefaultRule = false}) async {
    if (await _checkPermissions()) {
      _notificationsSchedule.notificationSchedule[time] = _week;
      for (final day in _week) {
        await _scheduleWeeklyNotification(time, day);
      }
      _saveNotificationsToAppSettings();
      notifyListeners();
    } else if (!isDefaultRule) {
      await AppSettings.openNotificationSettings();
    }
  }

  void deleteReminderRule(TimeOfDay time) {
    for (final day in _notificationsSchedule.notificationSchedule[time]) {
      _cancelWeeklyNotification(time, day);
    }
    // If nothing is sheduled, make sure to cancel all notifications
    if (userSchedule.isEmpty) {
      flutterLocalNotificationsPlugin.cancelAll();
    }
    _notificationsSchedule.notificationSchedule.remove(time);
    _saveNotificationsToAppSettings();
    notifyListeners();
  }
}
