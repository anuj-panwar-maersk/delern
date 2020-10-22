import 'dart:ui';

import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:delern_flutter/views/helpers/number_converter.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:delern_flutter/views/helpers/styles.dart';
import 'package:test/test.dart';

void main() {
  group('Swiss German', () {
    const swissDeckType = DeckType.swiss;

    test('feminine', () {
      expect(specifyCardColors(swissDeckType, 'd Muetter'),
          app_styles.cardBackgroundColors[Gender.feminine]);

      expect(specifyCardColors(swissDeckType, 'e Mappe'),
          app_styles.cardBackgroundColors[Gender.feminine]);
    });

    test('masculine', () {
      expect(specifyCardColors(swissDeckType, 'de Vater'),
          app_styles.cardBackgroundColors[Gender.masculine]);

      expect(specifyCardColors(swissDeckType, 'en Vater'),
          app_styles.cardBackgroundColors[Gender.masculine]);
    });

    test('neuter', () {
      expect(specifyCardColors(swissDeckType, 's Madchen'),
          app_styles.cardBackgroundColors[Gender.neuter]);

      expect(specifyCardColors(swissDeckType, 'es Madchen'),
          app_styles.cardBackgroundColors[Gender.neuter]);
    });

    test('noGender', () {
      expect(specifyCardColors(swissDeckType, 'laufen'),
          app_styles.cardBackgroundColors[Gender.noGender]);
    });
  });

  group('High German', () {
    const germanDeckType = DeckType.german;

    test('feminine', () {
      expect(specifyCardColors(germanDeckType, 'die Mutter'),
          app_styles.cardBackgroundColors[Gender.feminine]);

      expect(specifyCardColors(germanDeckType, 'eine Lampe'),
          app_styles.cardBackgroundColors[Gender.feminine]);
    });

    test('masculine', () {
      expect(specifyCardColors(germanDeckType, 'der Vater'),
          app_styles.cardBackgroundColors[Gender.masculine]);
    });

    test('neuter', () {
      expect(specifyCardColors(germanDeckType, 'das Madchen'),
          app_styles.cardBackgroundColors[Gender.neuter]);
    });

    test('noGender', () {
      expect(specifyCardColors(germanDeckType, 'laufen'),
          app_styles.cardBackgroundColors[Gender.noGender]);
    });
  });

  group('Basic', () {
    const basicDeckType = DeckType.basic;

    test('noColor', () {
      expect(specifyCardColors(basicDeckType, 'die Mutter'),
          app_styles.cardBackgroundColors[Gender.noGender]);
    });
  });

  group('User selected Color', () {
    const basicDeckType = DeckType.german;

    test('Red card color', () {
      expect(
          specifyCardColors(basicDeckType, 'die Mutter',
              cardColorValue: kRedCardColor.value),
          app_styles.CardColor(
              frontSideBackground:
                  Color(convertColorValueToHex(kRedCardColor.value)),
              backSideBackground:
                  Color(convertColorValueToHex(kRedCardColor.value))));
    });
  });
}
