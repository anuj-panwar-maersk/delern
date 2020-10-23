import 'dart:ui';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'card_color.g.dart';

abstract class CardColor implements Built<CardColor, CardColorBuilder> {
  Color get frontSideBackground;
  Color get backSideBackground;
  Color get defaultBackground => frontSideBackground;

  factory CardColor([void Function(CardColorBuilder) updates]) = _$CardColor;
  CardColor._();

  static Serializer<CardColor> get serializer => _$cardColorSerializer;
}
