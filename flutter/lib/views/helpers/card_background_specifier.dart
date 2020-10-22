import 'dart:ui';

import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/views/helpers/number_converter.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:delern_flutter/views/helpers/styles.dart';

enum Gender {
  masculine,
  feminine,
  neuter,
  noGender,
}

// If user assigned color when created a card, prefer color chosen by user
app_styles.CardColor specifyCardColors(DeckType deckType, String text,
    {int cardColorValue}) {
  int hexColorValue;
  if (cardColorValue != null &&
      (hexColorValue = convertColorValueToHex(cardColorValue)) != null) {
    final cardColor = Color(hexColorValue);
    return CardColor(
        frontSideBackground: cardColor, backSideBackground: cardColor);
  }
  return app_styles.cardBackgroundColors[_specifyCardGender(deckType, text)];
}

Gender _specifyCardGender(DeckType deckType, String text) {
  if (deckType == DeckType.basic) {
    return Gender.noGender;
  }
  var textGender = Gender.noGender;
  text = text.toLowerCase();
  if (deckType == DeckType.swiss) {
    textGender = _swissCardGender(text);
  } else {
    textGender = _germanCardGender(text);
  }
  return textGender;
}

Gender _swissCardGender(String text) {
  if (text.startsWith('de ') || text.startsWith('en ')) {
    return Gender.masculine;
  }
  if (text.startsWith('d ') || text.startsWith('e ')) {
    return Gender.feminine;
  }
  if (text.startsWith('s ') || text.startsWith('es ')) {
    return Gender.neuter;
  }
  return Gender.noGender;
}

Gender _germanCardGender(String text) {
  if (text.startsWith('der ')) {
    return Gender.masculine;
  }
  if (text.startsWith('die ') || text.startsWith('eine ')) {
    return Gender.feminine;
  }
  if (text.startsWith('das ')) {
    return Gender.neuter;
  }
  return Gender.noGender;
}
