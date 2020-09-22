import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/view_models/edit_deck_bloc.dart';
import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:flutter/material.dart';

const double _kBorderPadding = 8;
const double _kMinDeckTypeWidgetWidth = 90;
const _kItemListPadding = SizedBox(width: _kBorderPadding * 2);

class DeckSettingsWidget extends StatefulWidget {
  final DeckModel deck;
  final EditDeckBloc bloc;

  const DeckSettingsWidget({@required this.deck, @required this.bloc})
      : assert(bloc != null);

  @override
  State<StatefulWidget> createState() => _DeckSettingsWidgetState();
}

class _DeckSettingsWidgetState extends State<DeckSettingsWidget> {
  DeckType _currentDeckType;

  @override
  void initState() {
    _currentDeckType = widget.deck.type;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final locale = context.l;
    if (widget.bloc?.locale != locale) {
      widget.bloc.onLocale.add(locale);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(_kBorderPadding),
        child: SingleChildScrollView(
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      context.l.deckType,
                      style: app_styles.primaryText,
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: _kBorderPadding),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _buildBasicDeckType(),
                        _kItemListPadding,
                        _buildGermanDeckType(),
                        _kItemListPadding,
                        _buildSwissDeckType(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildGermanDeckType() {
    final ruleList = [
      // TODO(dotdoom): Refactor: move logic to card_background_specifier
      _buildRule(
          'der',
          app_styles
              .cardBackgroundColors[Gender.masculine].frontSideBackground),
      _buildRule('die, eine',
          app_styles.cardBackgroundColors[Gender.feminine].frontSideBackground),
      _buildRule('das',
          app_styles.cardBackgroundColors[Gender.neuter].frontSideBackground),
      _buildRule(context.l.other,
          app_styles.cardBackgroundColors[Gender.noGender].frontSideBackground),
    ];
    return _buildDeckType(DeckType.german, ruleList);
  }

  Widget _buildSwissDeckType() {
    final ruleList = [
      _buildRule(
          'de, en',
          app_styles
              .cardBackgroundColors[Gender.masculine].frontSideBackground),
      _buildRule('d, e',
          app_styles.cardBackgroundColors[Gender.feminine].frontSideBackground),
      _buildRule('s, es',
          app_styles.cardBackgroundColors[Gender.neuter].frontSideBackground),
      _buildRule(context.l.other,
          app_styles.cardBackgroundColors[Gender.noGender].frontSideBackground),
    ];
    return _buildDeckType(DeckType.swiss, ruleList);
  }

  Widget _buildBasicDeckType() {
    final ruleList = [
      _buildRule('',
          app_styles.cardBackgroundColors[Gender.noGender].frontSideBackground),
      _buildRule('',
          app_styles.cardBackgroundColors[Gender.noGender].frontSideBackground),
      _buildRule('',
          app_styles.cardBackgroundColors[Gender.noGender].frontSideBackground),
      _buildRule('',
          app_styles.cardBackgroundColors[Gender.noGender].frontSideBackground),
    ];
    return _buildDeckType(DeckType.basic, ruleList);
  }

  Widget _buildDeckType(DeckType deckType, List<Widget> ruleList) => Material(
        color: _currentDeckType == deckType
            ? app_styles.kCurrentDeckTypeColor
            : app_styles.kGeneralDeckTypeColor,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        child: InkWell(
          splashColor: Theme.of(context).splashColor,
          onTap: () {
            setState(() {
              _currentDeckType = deckType;
              widget.bloc.onDeckType.add(deckType);
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(_kBorderPadding),
            child: Column(
              children: <Widget>[
                Text(_getDeckTypeName(deckType)),
                IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: ruleList,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  String _getDeckTypeName(DeckType deckType) {
    switch (deckType) {
      case DeckType.basic:
        return context.l.basicDeckType;
      case DeckType.german:
        return context.l.germanDeckType;
      case DeckType.swiss:
        return context.l.swissDeckType;
    }
    return context.l.unknownDeckType;
  }

  Widget _buildRule(String text, Color color) => ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: _kMinDeckTypeWidgetWidth,
          minHeight: app_styles.kMinSecondaryTextSize + _kBorderPadding,
        ),
        child: Container(
          color: color,
          padding: const EdgeInsets.all(_kBorderPadding),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: app_styles.kMinSecondaryTextSize,
            ),
          ),
        ),
      );
}
