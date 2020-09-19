// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<NotificationPayload> _$notificationPayloadSerializer =
    new _$NotificationPayloadSerializer();

class _$NotificationPayloadSerializer
    implements StructuredSerializer<NotificationPayload> {
  @override
  final Iterable<Type> types = const [
    NotificationPayload,
    _$NotificationPayload
  ];
  @override
  final String wireName = 'NotificationPayload';

  @override
  Iterable<Object> serialize(
      Serializers serializers, NotificationPayload object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'title',
      serializers.serialize(object.title,
          specifiedType: const FullType(String)),
      'subtitle',
      serializers.serialize(object.subtitle,
          specifiedType: const FullType(String)),
      'day',
      serializers.serialize(object.day, specifiedType: const FullType(int)),
      'time',
      serializers.serialize(object.time,
          specifiedType: const FullType(flutter_material.TimeOfDay)),
    ];
    if (object.route != null) {
      result
        ..add('route')
        ..add(serializers.serialize(object.route,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  NotificationPayload deserialize(
      Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new NotificationPayloadBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'route':
          result.route = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'title':
          result.title = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'subtitle':
          result.subtitle = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'day':
          result.day = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
        case 'time':
          result.time = serializers.deserialize(value,
                  specifiedType: const FullType(flutter_material.TimeOfDay))
              as flutter_material.TimeOfDay;
          break;
      }
    }

    return result.build();
  }
}

class _$NotificationPayload extends NotificationPayload {
  @override
  final String route;
  @override
  final String title;
  @override
  final String subtitle;
  @override
  final int day;
  @override
  final flutter_material.TimeOfDay time;

  factory _$NotificationPayload(
          [void Function(NotificationPayloadBuilder) updates]) =>
      (new NotificationPayloadBuilder()..update(updates)).build();

  _$NotificationPayload._(
      {this.route, this.title, this.subtitle, this.day, this.time})
      : super._() {
    if (title == null) {
      throw new BuiltValueNullFieldError('NotificationPayload', 'title');
    }
    if (subtitle == null) {
      throw new BuiltValueNullFieldError('NotificationPayload', 'subtitle');
    }
    if (day == null) {
      throw new BuiltValueNullFieldError('NotificationPayload', 'day');
    }
    if (time == null) {
      throw new BuiltValueNullFieldError('NotificationPayload', 'time');
    }
  }

  @override
  NotificationPayload rebuild(
          void Function(NotificationPayloadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NotificationPayloadBuilder toBuilder() =>
      new NotificationPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationPayload &&
        route == other.route &&
        title == other.title &&
        subtitle == other.subtitle &&
        day == other.day &&
        time == other.time;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc($jc(0, route.hashCode), title.hashCode), subtitle.hashCode),
            day.hashCode),
        time.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('NotificationPayload')
          ..add('route', route)
          ..add('title', title)
          ..add('subtitle', subtitle)
          ..add('day', day)
          ..add('time', time))
        .toString();
  }
}

class NotificationPayloadBuilder
    implements Builder<NotificationPayload, NotificationPayloadBuilder> {
  _$NotificationPayload _$v;

  String _route;
  String get route => _$this._route;
  set route(String route) => _$this._route = route;

  String _title;
  String get title => _$this._title;
  set title(String title) => _$this._title = title;

  String _subtitle;
  String get subtitle => _$this._subtitle;
  set subtitle(String subtitle) => _$this._subtitle = subtitle;

  int _day;
  int get day => _$this._day;
  set day(int day) => _$this._day = day;

  flutter_material.TimeOfDay _time;
  flutter_material.TimeOfDay get time => _$this._time;
  set time(flutter_material.TimeOfDay time) => _$this._time = time;

  NotificationPayloadBuilder();

  NotificationPayloadBuilder get _$this {
    if (_$v != null) {
      _route = _$v.route;
      _title = _$v.title;
      _subtitle = _$v.subtitle;
      _day = _$v.day;
      _time = _$v.time;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationPayload other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$NotificationPayload;
  }

  @override
  void update(void Function(NotificationPayloadBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$NotificationPayload build() {
    final _$result = _$v ??
        new _$NotificationPayload._(
            route: route,
            title: title,
            subtitle: subtitle,
            day: day,
            time: time);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
