// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_color.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<CardColor> _$cardColorSerializer = new _$CardColorSerializer();

class _$CardColorSerializer implements StructuredSerializer<CardColor> {
  @override
  final Iterable<Type> types = const [CardColor, _$CardColor];
  @override
  final String wireName = 'CardColor';

  @override
  Iterable<Object> serialize(Serializers serializers, CardColor object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'frontSideBackground',
      serializers.serialize(object.frontSideBackground,
          specifiedType: const FullType(Color)),
      'backSideBackground',
      serializers.serialize(object.backSideBackground,
          specifiedType: const FullType(Color)),
    ];

    return result;
  }

  @override
  CardColor deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new CardColorBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'frontSideBackground':
          result.frontSideBackground = serializers.deserialize(value,
              specifiedType: const FullType(Color)) as Color;
          break;
        case 'backSideBackground':
          result.backSideBackground = serializers.deserialize(value,
              specifiedType: const FullType(Color)) as Color;
          break;
      }
    }

    return result.build();
  }
}

class _$CardColor extends CardColor {
  @override
  final Color frontSideBackground;
  @override
  final Color backSideBackground;

  factory _$CardColor([void Function(CardColorBuilder) updates]) =>
      (new CardColorBuilder()..update(updates)).build();

  _$CardColor._({this.frontSideBackground, this.backSideBackground})
      : super._() {
    if (frontSideBackground == null) {
      throw new BuiltValueNullFieldError('CardColor', 'frontSideBackground');
    }
    if (backSideBackground == null) {
      throw new BuiltValueNullFieldError('CardColor', 'backSideBackground');
    }
  }

  @override
  CardColor rebuild(void Function(CardColorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CardColorBuilder toBuilder() => new CardColorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CardColor &&
        frontSideBackground == other.frontSideBackground &&
        backSideBackground == other.backSideBackground;
  }

  @override
  int get hashCode {
    return $jf(
        $jc($jc(0, frontSideBackground.hashCode), backSideBackground.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('CardColor')
          ..add('frontSideBackground', frontSideBackground)
          ..add('backSideBackground', backSideBackground))
        .toString();
  }
}

class CardColorBuilder implements Builder<CardColor, CardColorBuilder> {
  _$CardColor _$v;

  Color _frontSideBackground;
  Color get frontSideBackground => _$this._frontSideBackground;
  set frontSideBackground(Color frontSideBackground) =>
      _$this._frontSideBackground = frontSideBackground;

  Color _backSideBackground;
  Color get backSideBackground => _$this._backSideBackground;
  set backSideBackground(Color backSideBackground) =>
      _$this._backSideBackground = backSideBackground;

  CardColorBuilder();

  CardColorBuilder get _$this {
    if (_$v != null) {
      _frontSideBackground = _$v.frontSideBackground;
      _backSideBackground = _$v.backSideBackground;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CardColor other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$CardColor;
  }

  @override
  void update(void Function(CardColorBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$CardColor build() {
    final _$result = _$v ??
        new _$CardColor._(
            frontSideBackground: frontSideBackground,
            backSideBackground: backSideBackground);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
