// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_notification.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<LocalNotification> _$localNotificationSerializer =
    new _$LocalNotificationSerializer();

class _$LocalNotificationSerializer
    implements StructuredSerializer<LocalNotification> {
  @override
  final Iterable<Type> types = const [LocalNotification, _$LocalNotification];
  @override
  final String wireName = 'LocalNotification';

  @override
  Iterable<Object> serialize(Serializers serializers, LocalNotification object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'title',
      serializers.serialize(object.title,
          specifiedType: const FullType(String)),
    ];
    if (object.body != null) {
      result
        ..add('body')
        ..add(serializers.serialize(object.body,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  LocalNotification deserialize(
      Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new LocalNotificationBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'title':
          result.title = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'body':
          result.body = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$LocalNotification extends LocalNotification {
  @override
  final String title;
  @override
  final String body;

  factory _$LocalNotification(
          [void Function(LocalNotificationBuilder) updates]) =>
      (new LocalNotificationBuilder()..update(updates)).build();

  _$LocalNotification._({this.title, this.body}) : super._() {
    if (title == null) {
      throw new BuiltValueNullFieldError('LocalNotification', 'title');
    }
  }

  @override
  LocalNotification rebuild(void Function(LocalNotificationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LocalNotificationBuilder toBuilder() =>
      new LocalNotificationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LocalNotification &&
        title == other.title &&
        body == other.body;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, title.hashCode), body.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('LocalNotification')
          ..add('title', title)
          ..add('body', body))
        .toString();
  }
}

class LocalNotificationBuilder
    implements Builder<LocalNotification, LocalNotificationBuilder> {
  _$LocalNotification _$v;

  String _title;
  String get title => _$this._title;
  set title(String title) => _$this._title = title;

  String _body;
  String get body => _$this._body;
  set body(String body) => _$this._body = body;

  LocalNotificationBuilder();

  LocalNotificationBuilder get _$this {
    if (_$v != null) {
      _title = _$v.title;
      _body = _$v.body;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LocalNotification other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$LocalNotification;
  }

  @override
  void update(void Function(LocalNotificationBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$LocalNotification build() {
    final _$result = _$v ?? new _$LocalNotification._(title: title, body: body);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
