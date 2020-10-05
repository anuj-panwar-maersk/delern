import 'dart:core';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:flutter/material.dart' as flutter_material;

part 'notification_schedule.g.dart';

abstract class NotificationSchedule
    implements Built<NotificationSchedule, NotificationScheduleBuilder> {
  // int is used to save day of week, for Monday it is 1, Tuesday is 2, etc
  BuiltMap<flutter_material.TimeOfDay, BuiltList<int>> get notificationSchedule;

  static Serializer<NotificationSchedule> get serializer =>
      _$notificationScheduleSerializer;

  factory NotificationSchedule(
          [void Function(NotificationScheduleBuilder) updates]) =
      _$NotificationSchedule;

  NotificationSchedule._();
}
