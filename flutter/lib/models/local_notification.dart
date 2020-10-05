import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'local_notification.g.dart';

abstract class LocalNotification
    implements Built<LocalNotification, LocalNotificationBuilder> {
  String get title;
  @nullable
  String get body;
  static Serializer<LocalNotification> get serializer =>
      _$localNotificationSerializer;

  factory LocalNotification([void Function(LocalNotificationBuilder) updates]) =
      _$LocalNotification;

  LocalNotification._();
}
