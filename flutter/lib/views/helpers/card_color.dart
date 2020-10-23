import 'dart:ui';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'card_color.g.dart';

abstract class CardColor implements Built<CardColor, CardColorBuilder> {
  Color get frontSideBackground;
  Color get backSideBackground;
  Color get defaultBackground => frontSideBackground;

  factory CardColor({
    Color frontSideBackground,
    Color backSideBackground,
  }) =>
      _$CardColor._(
        frontSideBackground: frontSideBackground,
        backSideBackground: backSideBackground,
      );
  CardColor._();

  static Serializer<CardColor> get serializer => _$cardColorSerializer;
}
