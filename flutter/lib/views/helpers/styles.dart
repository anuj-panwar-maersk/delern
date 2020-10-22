import 'package:delern_flutter/remote/app_config.dart';
import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:delern_flutter/views/helpers/device_info.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

const double maxFontSize = 50;
const double minFontSize = 15;

const kPrimarySwatch = Colors.green;
const kLightPrimaryColor = Color(0xFFC8E6C9);
const kAccentColor = Colors.redAccent;
const kScaffoldBackgroundColor = Colors.white;
final kIconColor = Colors.grey[600];
const kSecondaryTextDeckItemColor = Color(0xff757575);
const kEditDismissibleColor = Color(0xFF2196F3);
const kDeleteDismissibleColor = Color(0xFFFF5252);
const kHyperlinkColor = Color(0xFF2196F3);
const kDeckItemColor = Colors.white;
const kCurrentDeckTypeColor = Colors.grey;
final kGeneralDeckTypeColor = Colors.grey[200];
final kBottomSheetColor = Colors.blueGrey[50];
const kNotificationByDayDisabledColor = Colors.grey;
final kNotificationByDayEnabledColor = Colors.orange;
final kFontSizeSliderColor = Colors.orange;

const kRedCardColor = Color(0xFFF28B82);
const kOrangeCardColor = Color(0xFFFBBC04);
const kYellowCardColor = Color(0xFFFFF475);
const kGreenCardColor = Color(0xFFCCFF90);
const kBlueCardColor = Color(0xFFA7FFEB);
const kPaleBlueCardColor = Color(0xFFCBF0F8);
const kDarkBlueCardColor = Color(0xFFAECBFA);
const kLilacCardColor = Color(0xFFD7AEFB);
const kCardPickeBorderColor = Color(0xFFF2787A);

// "Facebook brand blue" color per instructions at
// https://developers.facebook.com/docs/facebook-login/for-devices
const kFacebookBlueColor = Color(0xFF4267B2);
const kSignInSectionSeparationColor = Color(0xFFC1C0C0);
const kGoogleSignInButtonColor = Color(0xFF4285F4);
const kSignInTextColor = Color(0xFF1A1A1A);
const kErrorLabelColor = Colors.red;
const kButtonTextColor = Colors.white;

const double kMinItemHeight = 48;
const double kMinIconHeight = 24;
const double kMinPrimaryTextSize = 19;
const double kMinSecondaryTextSize = 16;
const double kIconDeckPadding = 15;
const double kItemElevation = 4;
const double kItemListHeightRatio = 0.1;
const double kItemListPaddingRatio = kItemListHeightRatio * 0.08;
const double kCardElevation = 6;
const double kImageMenuButtonSize = 36;
const double kBottomSheetBorderRadius = 24;
const double kBottomSheetElevation = 20;

class CardColor extends Equatable {
  final Color frontSideBackground;
  final Color backSideBackground;
  Color get defaultBackground => frontSideBackground;
  const CardColor({
    @required this.frontSideBackground,
    @required this.backSideBackground,
  })  : assert(frontSideBackground != null),
        assert(backSideBackground != null);

  @override
  List<Object> get props => [frontSideBackground, backSideBackground];
}

TextStyle specifyCardFontStyle() {
  final _isPhone = isPhone();
  TextStyle textStyle;

  if (AppConfig.instance.cardsFontSize == null) {
    textStyle = _isPhone
        ? primaryText
        : primaryText.copyWith(
            fontSize: MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                    .size
                    .longestSide *
                0.035);
  } else {
    textStyle =
        primaryText.copyWith(fontSize: AppConfig.instance.cardsFontSize);
  }
  return textStyle;
}

// In numbered list we need to add list indent to size numbers
// properly
// https://github.com/flutter/flutter_markdown/issues/255
double specifyMarkdownListIndent() {
  final fontSize = specifyCardFontStyle().fontSize;
  return fontSize * 1.1;
}

final Map<Gender, CardColor> cardBackgroundColors = {
  Gender.noGender: const CardColor(
      frontSideBackground: Color(0xFFF5F5F5), backSideBackground: Colors.white),
  Gender.masculine: CardColor(
      frontSideBackground: Colors.blueAccent[100],
      backSideBackground: Colors.blue[200]),
  Gender.feminine: CardColor(
      frontSideBackground: Colors.pinkAccent[100],
      backSideBackground: Colors.pink[200]),
  Gender.neuter: CardColor(
      frontSideBackground: Colors.amberAccent[100],
      backSideBackground: Colors.amber[200]),
};

final Color signInBackgroundColor = Colors.grey[50];

final TextStyle primaryText = TextStyle(
  fontSize: 19,
  fontWeight: FontWeight.w400,
  color: Colors.grey[900],
);

const TextStyle secondaryText = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: Color(0xff757575),
);

final TextStyle navigationDrawerGroupText = TextStyle(
  fontWeight: FontWeight.w600,
  color: Colors.grey[600],
);

const TextStyle searchBarText = TextStyle(
  color: Colors.white,
  fontSize: 19,
);

const Color menuItemBackgroundColor = Colors.redAccent;

const TextStyle menuItemText = TextStyle(
  color: Colors.white,
);

const TextStyle editCardPrimaryText = TextStyle(
  fontSize: 19,
  fontWeight: FontWeight.w400,
  color: Colors.black,
);

const TextStyle editCardSecondaryText = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: Colors.black,
);

final TextStyle editDeckText = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w400,
  color: Colors.grey[900],
);

const TextStyle signInTextButton = TextStyle(
  fontSize: 18,
  fontFamily: 'Roboto Medium',
  color: Colors.white,
  fontWeight: FontWeight.bold,
);
