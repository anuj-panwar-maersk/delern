// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_model.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<CardModel> _$cardModelSerializer = new _$CardModelSerializer();

class _$CardModelSerializer implements StructuredSerializer<CardModel> {
  @override
  final Iterable<Type> types = const [CardModel, _$CardModel];
  @override
  final String wireName = 'CardModel';

  @override
  Iterable<Object> serialize(Serializers serializers, CardModel object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'front',
      serializers.serialize(object.front,
          specifiedType: const FullType(String)),
      'back',
      serializers.serialize(object.back, specifiedType: const FullType(String)),
      'frontImagesUri',
      serializers.serialize(object.frontImagesUri,
          specifiedType:
              const FullType(BuiltList, const [const FullType(String)])),
      'backImagesUri',
      serializers.serialize(object.backImagesUri,
          specifiedType:
              const FullType(BuiltList, const [const FullType(String)])),
    ];
    if (object.deckKey != null) {
      result
        ..add('deckKey')
        ..add(serializers.serialize(object.deckKey,
            specifiedType: const FullType(String)));
    }
    if (object.key != null) {
      result
        ..add('key')
        ..add(serializers.serialize(object.key,
            specifiedType: const FullType(String)));
    }
    if (object.createdAt != null) {
      result
        ..add('createdAt')
        ..add(serializers.serialize(object.createdAt,
            specifiedType: const FullType(DateTime)));
    }
    if (object.color != null) {
      result
        ..add('color')
        ..add(serializers.serialize(object.color,
            specifiedType: const FullType(int)));
    }
    return result;
  }

  @override
  CardModel deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new CardModelBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'deckKey':
          result.deckKey = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'key':
          result.key = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'front':
          result.front = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'back':
          result.back = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'createdAt':
          result.createdAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime;
          break;
        case 'frontImagesUri':
          result.frontImagesUri.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(String)]))
              as BuiltList<Object>);
          break;
        case 'backImagesUri':
          result.backImagesUri.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(String)]))
              as BuiltList<Object>);
          break;
        case 'color':
          result.color = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
      }
    }

    return result.build();
  }
}

class _$CardModel extends CardModel {
  @override
  final String deckKey;
  @override
  final String key;
  @override
  final String front;
  @override
  final String back;
  @override
  final DateTime createdAt;
  @override
  final BuiltList<String> frontImagesUri;
  @override
  final BuiltList<String> backImagesUri;
  @override
  final int color;

  factory _$CardModel([void Function(CardModelBuilder) updates]) =>
      (new CardModelBuilder()..update(updates)).build();

  _$CardModel._(
      {this.deckKey,
      this.key,
      this.front,
      this.back,
      this.createdAt,
      this.frontImagesUri,
      this.backImagesUri,
      this.color})
      : super._() {
    if (front == null) {
      throw new BuiltValueNullFieldError('CardModel', 'front');
    }
    if (back == null) {
      throw new BuiltValueNullFieldError('CardModel', 'back');
    }
    if (frontImagesUri == null) {
      throw new BuiltValueNullFieldError('CardModel', 'frontImagesUri');
    }
    if (backImagesUri == null) {
      throw new BuiltValueNullFieldError('CardModel', 'backImagesUri');
    }
  }

  @override
  CardModel rebuild(void Function(CardModelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CardModelBuilder toBuilder() => new CardModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CardModel &&
        deckKey == other.deckKey &&
        key == other.key &&
        front == other.front &&
        back == other.back &&
        createdAt == other.createdAt &&
        frontImagesUri == other.frontImagesUri &&
        backImagesUri == other.backImagesUri &&
        color == other.color;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc($jc($jc(0, deckKey.hashCode), key.hashCode),
                            front.hashCode),
                        back.hashCode),
                    createdAt.hashCode),
                frontImagesUri.hashCode),
            backImagesUri.hashCode),
        color.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('CardModel')
          ..add('deckKey', deckKey)
          ..add('key', key)
          ..add('front', front)
          ..add('back', back)
          ..add('createdAt', createdAt)
          ..add('frontImagesUri', frontImagesUri)
          ..add('backImagesUri', backImagesUri)
          ..add('color', color))
        .toString();
  }
}

class CardModelBuilder implements Builder<CardModel, CardModelBuilder> {
  _$CardModel _$v;

  String _deckKey;
  String get deckKey => _$this._deckKey;
  set deckKey(String deckKey) => _$this._deckKey = deckKey;

  String _key;
  String get key => _$this._key;
  set key(String key) => _$this._key = key;

  String _front;
  String get front => _$this._front;
  set front(String front) => _$this._front = front;

  String _back;
  String get back => _$this._back;
  set back(String back) => _$this._back = back;

  DateTime _createdAt;
  DateTime get createdAt => _$this._createdAt;
  set createdAt(DateTime createdAt) => _$this._createdAt = createdAt;

  ListBuilder<String> _frontImagesUri;
  ListBuilder<String> get frontImagesUri =>
      _$this._frontImagesUri ??= new ListBuilder<String>();
  set frontImagesUri(ListBuilder<String> frontImagesUri) =>
      _$this._frontImagesUri = frontImagesUri;

  ListBuilder<String> _backImagesUri;
  ListBuilder<String> get backImagesUri =>
      _$this._backImagesUri ??= new ListBuilder<String>();
  set backImagesUri(ListBuilder<String> backImagesUri) =>
      _$this._backImagesUri = backImagesUri;

  int _color;
  int get color => _$this._color;
  set color(int color) => _$this._color = color;

  CardModelBuilder() {
    CardModel._initializeBuilder(this);
  }

  CardModelBuilder get _$this {
    if (_$v != null) {
      _deckKey = _$v.deckKey;
      _key = _$v.key;
      _front = _$v.front;
      _back = _$v.back;
      _createdAt = _$v.createdAt;
      _frontImagesUri = _$v.frontImagesUri?.toBuilder();
      _backImagesUri = _$v.backImagesUri?.toBuilder();
      _color = _$v.color;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CardModel other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$CardModel;
  }

  @override
  void update(void Function(CardModelBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$CardModel build() {
    _$CardModel _$result;
    try {
      _$result = _$v ??
          new _$CardModel._(
              deckKey: deckKey,
              key: key,
              front: front,
              back: back,
              createdAt: createdAt,
              frontImagesUri: frontImagesUri.build(),
              backImagesUri: backImagesUri.build(),
              color: color);
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'frontImagesUri';
        frontImagesUri.build();
        _$failedField = 'backImagesUri';
        backImagesUri.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'CardModel', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
