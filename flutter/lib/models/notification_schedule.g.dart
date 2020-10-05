// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_schedule.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<NotificationSchedule> _$notificationScheduleSerializer =
    new _$NotificationScheduleSerializer();

class _$NotificationScheduleSerializer
    implements StructuredSerializer<NotificationSchedule> {
  @override
  final Iterable<Type> types = const [
    NotificationSchedule,
    _$NotificationSchedule
  ];
  @override
  final String wireName = 'NotificationSchedule';

  @override
  Iterable<Object> serialize(
      Serializers serializers, NotificationSchedule object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'notificationSchedule',
      serializers.serialize(object.notificationSchedule,
          specifiedType: const FullType(BuiltMap, const [
            const FullType(flutter_material.TimeOfDay),
            const FullType(BuiltList, const [const FullType(int)])
          ])),
    ];

    return result;
  }

  @override
  NotificationSchedule deserialize(
      Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new NotificationScheduleBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'notificationSchedule':
          result.notificationSchedule.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltMap, const [
                const FullType(flutter_material.TimeOfDay),
                const FullType(BuiltList, const [const FullType(int)])
              ])));
          break;
      }
    }

    return result.build();
  }
}

class _$NotificationSchedule extends NotificationSchedule {
  @override
  final BuiltMap<flutter_material.TimeOfDay, BuiltList<int>>
      notificationSchedule;

  factory _$NotificationSchedule(
          [void Function(NotificationScheduleBuilder) updates]) =>
      (new NotificationScheduleBuilder()..update(updates)).build();

  _$NotificationSchedule._({this.notificationSchedule}) : super._() {
    if (notificationSchedule == null) {
      throw new BuiltValueNullFieldError(
          'NotificationSchedule', 'notificationSchedule');
    }
  }

  @override
  NotificationSchedule rebuild(
          void Function(NotificationScheduleBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NotificationScheduleBuilder toBuilder() =>
      new NotificationScheduleBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationSchedule &&
        notificationSchedule == other.notificationSchedule;
  }

  @override
  int get hashCode {
    return $jf($jc(0, notificationSchedule.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('NotificationSchedule')
          ..add('notificationSchedule', notificationSchedule))
        .toString();
  }
}

class NotificationScheduleBuilder
    implements Builder<NotificationSchedule, NotificationScheduleBuilder> {
  _$NotificationSchedule _$v;

  MapBuilder<flutter_material.TimeOfDay, BuiltList<int>> _notificationSchedule;
  MapBuilder<flutter_material.TimeOfDay, BuiltList<int>>
      get notificationSchedule => _$this._notificationSchedule ??=
          new MapBuilder<flutter_material.TimeOfDay, BuiltList<int>>();
  set notificationSchedule(
          MapBuilder<flutter_material.TimeOfDay, BuiltList<int>>
              notificationSchedule) =>
      _$this._notificationSchedule = notificationSchedule;

  NotificationScheduleBuilder();

  NotificationScheduleBuilder get _$this {
    if (_$v != null) {
      _notificationSchedule = _$v.notificationSchedule?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationSchedule other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$NotificationSchedule;
  }

  @override
  void update(void Function(NotificationScheduleBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$NotificationSchedule build() {
    _$NotificationSchedule _$result;
    try {
      _$result = _$v ??
          new _$NotificationSchedule._(
              notificationSchedule: notificationSchedule.build());
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'notificationSchedule';
        notificationSchedule.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'NotificationSchedule', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
