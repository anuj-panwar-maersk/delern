import 'package:built_collection/built_collection.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/remote/analytics/analytics.dart';
import 'package:delern_flutter/view_models/card_create_update_bloc.dart';
import 'package:delern_flutter/views/base/screen_bloc_view.dart';
import 'package:delern_flutter/views/card_create_update/card_side_input_widget.dart';
import 'package:delern_flutter/views/card_create_update/color_picker_widget.dart';
import 'package:delern_flutter/views/helpers/display_image_widget.dart';
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/number_converter.dart';
import 'package:delern_flutter/views/helpers/progress_indicator_widget.dart';
import 'package:delern_flutter/views/helpers/save_updates_dialog.dart';
import 'package:delern_flutter/views/helpers/stream_with_value_builder.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:delern_flutter/views/helpers/text_overflow_ellipsis_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CardCreateUpdate extends StatefulWidget {
  static const routeNameNew = '/cards/new';
  static const routeNameEdit = '/cards/edit';

  static Map<String, String> buildArguments({
    @required String deckKey,
    String cardKey,
  }) =>
      {
        'deckKey': deckKey,
        'cardKey': cardKey,
      };

  const CardCreateUpdate() : super();

  @override
  State<StatefulWidget> createState() => _CardCreateUpdateState();
}

class _CardCreateUpdateState extends State<CardCreateUpdate> {
  bool _addReversedCard = false;
  bool _isChanged = false;
  final TextEditingController _frontTextController = TextEditingController();
  final TextEditingController _backTextController = TextEditingController();
  final FocusNode _frontSideFocus = FocusNode();
  Color _cardColor;

  @override
  void dispose() {
    _frontSideFocus.dispose();
    _frontTextController.dispose();
    _backTextController.dispose();
    super.dispose();
  }

  Future<void> showCardSaveUpdateDialog({
    @required Sink<void> onDiscardChanges,
    @required bool defaultDiscard,
  }) async {
    if (_isChanged) {
      final locale = context.l;
      final continueEditing = await showSaveUpdatesDialog(
        context: context,
        changesQuestion: locale.continueEditingQuestion,
        yesAnswer: locale.yes,
        noAnswer: locale.discard,
        defaultIsYes: !defaultDiscard,
      );
      if (continueEditing) {
        return false;
      }
    }
    onDiscardChanges.add(null);
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context).settings.arguments
        as Map<String, String>; // ignore: avoid_as

    return ScreenBlocView<CardCreateUpdateBloc>(
      blocBuilder: (user) {
        final bloc = CardCreateUpdateBloc(
          deckKey: arguments['deckKey'],
          cardKey: arguments['cardKey'],
          user: user,
          analytics: context.read<AnalyticsLogger>(),
        );
        bloc.doFrontSideTextController
            .listen((text) => _frontTextController.text = text);
        bloc.doBackSideTextController
            .listen((text) => _backTextController.text = text);
        bloc.doClearInputFields.listen((_) => _clearInputFields(bloc));
        bloc.doShowConfirmationDialog
            .listen((userClosesScreen) => showCardSaveUpdateDialog(
                  onDiscardChanges: bloc.onDiscardChanges,
                  defaultDiscard: userClosesScreen,
                ));
        bloc.doColor.listen((colorValue) {
          setState(() {
            final hexValue = convertColorValueToHex(colorValue);
            _cardColor = hexValue == null ? null : Color(hexValue);
          });
        });
        return bloc;
      },
      appBarBuilder: _buildAppBar,
      bodyBuilder: _buildUserInput,
      resizeToAvoidBottomInset: true,
    );
  }

  AppBar _buildAppBar(CardCreateUpdateBloc bloc) {
    void saveCard() => bloc.onSaveCard.add(null);
    return AppBar(
      title: buildStreamBuilderWithValue<DeckModel>(
        streamWithValue: bloc.deck,
        builder: (_, snapshot) => snapshot.hasData
            ? TextOverflowEllipsisWidget(
                textDetails: snapshot.data.name,
              )
            : const ProgressIndicatorWidget(),
      ),
      actions: <Widget>[
        StreamBuilder<bool>(
          initialData: false,
          stream: bloc.isOperationEnabled,
          builder: (context, snapshot) => bloc.isAddOperation
              ? IconButton(
                  tooltip: context.l.addCardTooltip,
                  icon: const Icon(Icons.check),
                  onPressed: snapshot.data ? saveCard : null,
                )
              : FlatButton(
                  onPressed: _isChanged && snapshot.data ? saveCard : null,
                  child: Text(
                    context.l.save.toUpperCase(),
                    style: _isChanged && snapshot.data
                        ? const TextStyle(color: Colors.white)
                        : null,
                  ),
                ),
        )
      ],
    );
  }

  Widget _buildUserInput(CardCreateUpdateBloc bloc) {
    final widgetsList = <Widget>[
      // TODO(ksheremet): limit lines in TextField
      CardSideInputWidget(
        key: const Key('frontCardInput'),
        controller: _frontTextController,
        onTextChanged: (text) {
          setState(() {
            bloc.onFrontSideText.add(text);
            _isChanged = true;
          });
        },
        onImageSelected: (file) {
          bloc.onFrontImageAdded.add(file);
          _isChanged = true;
          context.read<AnalyticsLogger>().logAddImageToCard(isFrontSide: true);
        },
        imageList: DisplayImageListWidget(
          addImageStream: bloc.doFrontImageAdded,
          deleteImageSink: bloc.onFrontImageDeleted,
          showImagePlaceholderStream: bloc.doShowFrontImagePlaceholder,
          onDeleted: () {
            _isChanged = true;
          },
        ),
        hint: context.l.frontSideHint,
        autofocus: true,
        focusNode: _frontSideFocus,
        color: _cardColor,
      ),
      CardSideInputWidget(
        key: const Key('backCardInput'),
        controller: _backTextController,
        onTextChanged: (text) {
          setState(() {
            bloc.onBackSideText.add(text);
            _isChanged = true;
          });
        },
        onImageSelected: (file) {
          bloc.onBackImageAdded.add(file);
          _isChanged = true;
          context.read<AnalyticsLogger>().logAddImageToCard(isFrontSide: false);
        },
        imageList: DisplayImageListWidget(
          addImageStream: bloc.doBackImageAdded,
          deleteImageSink: bloc.onBackImageDeleted,
          onDeleted: () {
            _isChanged = true;
          },
          showImagePlaceholderStream: bloc.doShowBackImagePlaceholder,
        ),
        hint: context.l.backSideHint,
        color: _cardColor,
      ),
      CardColorPicker(
        selectedColor: _cardColor,
        onColorSelected: bloc.onColor,
      ),
    ];

    // Add reversed card widget if it is adding cards
    if (bloc.isAddOperation) {
      // https://github.com/flutter/flutter/issues/254 suggests using
      // CheckboxListTile to have a clickable checkbox label.
      widgetsList.add(CheckboxListTile(
        title: Text(
          context.l.reversedCardLabel,
          style: app_styles.primaryText,
        ),
        value: _addReversedCard,
        onChanged: (newValue) {
          bloc.onAddReversedCard.add(newValue);
          setState(() {
            _addReversedCard = newValue;
          });
        },
        // Position checkbox before the text.
        controlAffinity: ListTileControlAffinity.leading,
      ));
    }

    return ListView(
      padding: const EdgeInsets.only(left: 8, right: 8),
      children: widgetsList,
    );
  }

  void _clearInputFields(CardCreateUpdateBloc bloc) {
    setState(() {
      _isChanged = false;
      _frontTextController.clear();
      _backTextController.clear();
      bloc.onClearImages.add(null);
      bloc.onFrontSideText.add('');
      bloc.onBackSideText.add('');
      FocusScope.of(context).requestFocus(_frontSideFocus);
    });
  }
}

class DisplayImageListWidget extends StatelessWidget {
  final Stream<BuiltList<String>> _addImageStream;
  final Stream<bool> _showImagePlaceholderStream;
  final Sink<int> _deleteImageSink;
  final void Function() _onDeleted;

  const DisplayImageListWidget({
    @required Stream<BuiltList<String>> addImageStream,
    @required Sink<int> deleteImageSink,
    @required void Function() onDeleted,
    @required Stream<bool> showImagePlaceholderStream,
  })  : _addImageStream = addImageStream,
        _deleteImageSink = deleteImageSink,
        _onDeleted = onDeleted,
        _showImagePlaceholderStream = showImagePlaceholderStream;

  @override
  Widget build(BuildContext context) => StreamBuilder<bool>(
      stream: _showImagePlaceholderStream,
      builder: (context, placeholderSnapshot) =>
          StreamBuilder<BuiltList<String>>(
            stream: _addImageStream,
            builder: (context, snapshot) {
              final children = <Widget>[];

              if (snapshot.hasData &&
                  snapshot.data != null &&
                  snapshot.data.isNotEmpty) {
                children
                    .addAll(_buildImagesList(snapshot.data, _deleteImageSink));
              }
              if (placeholderSnapshot.hasData && placeholderSnapshot.data) {
                children.add(const Padding(
                  padding: EdgeInsets.all(16),
                  child: ImageProgressIndicatorPlaceholderWidget(),
                ));
              }
              return Column(
                children: children,
              );
            },
          ));

  List<Widget> _buildImagesList(BuiltList<String> images, Sink<int> onDelete) {
    final widgetsList = <Widget>[];
    for (var i = 0; i < images.length; i++) {
      final imageUrl = images[i];
      widgetsList.add(
        Padding(
            padding: const EdgeInsets.all(16),
            child: Stack(children: <Widget>[
              buildDisplayImageWidget(imageUrl),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8),
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          onDelete.add(i);
                          _onDeleted();
                        }),
                  ),
                ),
              ),
            ])),
      );
    }
    return widgetsList;
  }
}
