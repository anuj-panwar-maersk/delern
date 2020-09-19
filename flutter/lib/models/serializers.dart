library serializers;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/notification_payload.dart';
import 'package:delern_flutter/models/notification_schedule.dart';
import 'package:delern_flutter/models/scheduled_card_model.dart';
import 'package:flutter/material.dart';

part 'serializers.g.dart';

class FirebaseDateTimeSerializer implements PrimitiveSerializer<DateTime> {
  final bool structured = false;
  @override
  final Iterable<Type> types = BuiltList(<Type>[DateTime]);
  @override
  final String wireName = 'DateTime';

  @override
  Object serialize(Serializers serializers, DateTime dateTime,
          {FullType specifiedType = FullType.unspecified}) =>
      dateTime.millisecondsSinceEpoch;

  @override
  DateTime deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) =>
      serialized is num
          ? DateTime.fromMillisecondsSinceEpoch(serialized.toInt())
          : null;
}

class TimeOfDaySerializer implements PrimitiveSerializer<TimeOfDay> {
  @override
  TimeOfDay deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      serialized is num
          ? TimeOfDay(hour: serialized ~/ 60, minute: serialized.toInt() % 60)
          : null;

  @override
  Iterable<Type> get types => BuiltList(<Type>[TimeOfDay]);

  @override
  Object serialize(Serializers serializers, TimeOfDay timeOfDay,
          {FullType specifiedType = FullType.unspecified}) =>
      timeOfDay.hour * 60 + timeOfDay.minute;

  @override
  String get wireName => 'TimeOfDay';
}

@SerializersFor([
  CardModel,
  DeckModel,
  AccessType,
  DeckType,
  DeckAccessModel,
  ScheduledCardModel,
  NotificationSchedule,
  NotificationPayload,
])
final Serializers serializers = (_$serializers.toBuilder()
      ..addPlugin(StandardJsonPlugin())
      ..add(FirebaseDateTimeSerializer())
      ..add(TimeOfDaySerializer())
      ..addBuilderFactory(
          const FullType(BuiltList, [FullType(int)]), () => ListBuilder<int>()))
    .build();
