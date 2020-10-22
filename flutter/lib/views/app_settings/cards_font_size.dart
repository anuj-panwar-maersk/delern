import 'package:built_collection/built_collection.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/remote/analytics/analytics.dart';
import 'package:delern_flutter/remote/app_config.dart';
import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:delern_flutter/views/helpers/flip_card_widget.dart';
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/styles.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';

class CardsFontSize extends StatefulWidget {
  static String routeName = '/app_settings/cards_font_size';

  const CardsFontSize();

  @override
  _CardsFontSizeState createState() => _CardsFontSizeState();
}

class _CardsFontSizeState extends State<CardsFontSize> {
  double fontSize;

  @override
  void initState() {
    fontSize = specifyCardFontStyle().fontSize;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          unawaited(
              context.read<AnalyticsLogger>().logFontSizeChanged(fontSize));
          return true;
        },
        child: Scaffold(
          appBar: AppBar(title: Text(context.l.cardsFontSize)),
          body: Column(
            children: [
              Expanded(
                flex: 1,
                child: Slider.adaptive(
                  min: app_styles.minFontSize,
                  max: app_styles.maxFontSize,
                  value: fontSize,
                  activeColor: app_styles.kFontSizeSliderColor,
                  onChanged: (newValue) {
                    setState(() {
                      fontSize = newValue;
                      AppConfig.instance.cardsFontSize = fontSize;
                    });
                  },
                ),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: FlipCardWidget(
                    front: 'AaBbCcDcEeFf',
                    back: 'AaBbCcDcEeFf',
                    frontImages: null,
                    backImages: null,
                    key: ValueKey(CardsFontSize.routeName),
                    tags: BuiltSet(),
                    // TODO(ksheremet): Pick background color randomly
                    colors: specifyCardColors(DeckType.basic, 'AaBbCcDc'),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      );
}
