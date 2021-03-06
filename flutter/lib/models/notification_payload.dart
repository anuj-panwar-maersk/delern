import 'dart:core';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:flutter/material.dart' as flutter_material;

part 'notification_payload.g.dart';

abstract class NotificationPayload
    implements Built<NotificationPayload, NotificationPayloadBuilder> {
  // Route is a param for future implementations of a case when user presses
  // on notification and goes to a different route than main
  @nullable
  String get route;
  String get title;
  String get body;
  int get day;
  flutter_material.TimeOfDay get time;

  static Serializer<NotificationPayload> get serializer =>
      _$notificationPayloadSerializer;

  factory NotificationPayload(
          [void Function(NotificationPayloadBuilder) updates]) =
      _$NotificationPayload;

  NotificationPayload._();
}
