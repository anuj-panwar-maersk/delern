import 'dart:async';
import 'dart:typed_data';

import 'package:built_collection/built_collection.dart';
import 'package:delern_flutter/models/base/stream_with_value.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/remote/analytics/analytics.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:delern_flutter/view_models/base/screen_bloc.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';
import 'package:rxdart/rxdart.dart';

class CardCreateUpdateBloc extends ScreenBloc {
  final bool isAddOperation;
  bool _addReversedCard = false;
  CardModelBuilder _card;
  bool _isOperationEnabled = true;
  // This is an edge case. User updates the card and deletes an image,
  // after that discard the changes. If we delete
  // the image when user made this desicion, it can be deleted from Storage,
  // but has a reference in card images (realtime database)
  // that doens't exist anymore. Therefore we put images that user
  // intended to delete (when update) when user leaves the screen,
  // we detele them, to make sure that desicion is final.
  // TODO(ksheremet): Investigate whether to do GC in Cloud or do everything
  // on device.
  final List<String> _imagesToDelete = [];

  final AnalyticsLogger analytics;

  CardCreateUpdateBloc({
    @required User user,
    @required String deckKey,
    @required this.analytics,
    String cardKey,
  })  : assert(deckKey != null),
        isAddOperation = cardKey == null,
        super(user) {
    if (cardKey == null) {
      _card = CardModelBuilder()..deckKey = deckKey;
    } else {
      // TODO(dotdoom): wait until the values arrive.
      _card = user.decks
          .getItem(deckKey)
          .value
          .cards
          .getItem(cardKey)
          .value
          .toBuilder();
    }
    _doFrontSideTextController.add(_card.front);
    _doBackSideTextController.add(_card.back);
    _doFrontImageAddedController.add(_card.frontImagesUri.build());
    _doBackImageAddedController.add(_card.backImagesUri.build());
    _doShowFrontImagePlaceholderController.add(false);
    _doShowBackImagePlaceholderController.add(false);
    _doColorController.add(_card.color);
    _initListeners();
  }

  StreamWithValue<DeckModel> get deck => user.decks.getItem(_card.deckKey);

  final _onSaveCardController = StreamController<void>();
  Sink<void> get onSaveCard => _onSaveCardController.sink;

  final _onFrontSideTextController = StreamController<String>();
  Sink<String> get onFrontSideText => _onFrontSideTextController.sink;

  final _onBackSideTextController = StreamController<String>();
  Sink<String> get onBackSideText => _onBackSideTextController.sink;

  final _onColorController = StreamController<int>();
  Sink<int> get onColor => _onColorController.sink;

  final _doColorController = StreamController<int>();
  Stream<int> get doColor => _doColorController.stream;

  final _addReversedCardController = StreamController<bool>();
  Sink<bool> get onAddReversedCard => _addReversedCardController.sink;

  final _doFrontSideTextController = StreamController<String>();
  Stream<String> get doFrontSideTextController =>
      _doFrontSideTextController.stream;

  final _doBackSideTextController = StreamController<String>();
  Stream<String> get doBackSideTextController =>
      _doBackSideTextController.stream;

  final _doClearInputFieldsController = StreamController<void>();
  Stream<void> get doClearInputFields => _doClearInputFieldsController.stream;

  final _isOperationEnabledController = StreamController<bool>();
  Stream<bool> get isOperationEnabled => _isOperationEnabledController.stream;

  final _doShowConfirmationDialogController = StreamController<bool>();
  Stream<bool> get doShowConfirmationDialog =>
      _doShowConfirmationDialogController.stream;

  final _onDiscardChangesController = StreamController<void>();
  Sink<void> get onDiscardChanges => _onDiscardChangesController.sink;

  final _onFrontImageAddedController = StreamController<Uint8List>();
  Sink<Uint8List> get onFrontImageAdded => _onFrontImageAddedController.sink;

  final _onFrontImageDeletedController = StreamController<int>();
  Sink<int> get onFrontImageDeleted => _onFrontImageDeletedController.sink;

  final _onBackImageAddedController = StreamController<Uint8List>();
  Sink<Uint8List> get onBackImageAdded => _onBackImageAddedController.sink;

  final _onBackImageDeletedController = StreamController<int>();
  Sink<int> get onBackImageDeleted => _onBackImageDeletedController.sink;

  // TODO(ksheremet): Use StreamWithValue
  final _doFrontImageAddedController = BehaviorSubject<BuiltList<String>>();
  Stream<BuiltList<String>> get doFrontImageAdded =>
      _doFrontImageAddedController.stream;

  // TODO(ksheremet): Use StreamWithValue
  final _doShowFrontImagePlaceholderController = BehaviorSubject<bool>();
  Stream<bool> get doShowFrontImagePlaceholder =>
      _doShowFrontImagePlaceholderController.stream;

  // TODO(ksheremet): Use StreamWithValue
  final _doBackImageAddedController = BehaviorSubject<BuiltList<String>>();
  Stream<BuiltList<String>> get doBackImageAdded =>
      _doBackImageAddedController.stream;

  // TODO(ksheremet): Use StreamWithValue
  final _doShowBackImagePlaceholderController = BehaviorSubject<bool>();
  Stream<bool> get doShowBackImagePlaceholder =>
      _doShowBackImagePlaceholderController.stream;

  final _onClearImagesController = StreamController<void>();
  Sink<void> get onClearImages => _onClearImagesController.sink;

  void _initListeners() {
    _onSaveCardController.stream.listen((_) => _processSavingCard());
    _onFrontSideTextController.stream.listen((frontText) {
      _card.front = frontText;
      _checkOperationAvailability();
    });
    _onBackSideTextController.stream.listen((backText) {
      _card.back = backText;
      _checkOperationAvailability();
    });
    _addReversedCardController.stream.listen((addReversed) {
      _addReversedCard = addReversed;
      _checkOperationAvailability();
    });
    _onDiscardChangesController.stream.listen((_) {
      if (isAddOperation) {
        // ListBuilder doesn't have 'foreach' or similar to iterate elements.
        // Therefore we delete every image using 'map' and return empty String.
        // Anonymous functions has to return String
        _card.frontImagesUri.map((url) {
          user.deleteImage(url);
          return '';
        });
        _card.backImagesUri.map((url) {
          user.deleteImage(url);
          return '';
        });
      }
      notifyPop();
    });
    _onFrontImageAddedController.stream.listen((data) async {
      _doShowFrontImagePlaceholderController.add(true);
      try {
        final url = await user.uploadImage(data, _card.deckKey);
        _card.frontImagesUri.add(url);
        _doShowFrontImagePlaceholderController.add(false);
        _doFrontImageAddedController.add(_card.frontImagesUri.build());
        _checkOperationAvailability();
      } catch (e, stackTrace) {
        _doShowFrontImagePlaceholderController.add(false);
        unawaited(error_reporting.report(e, stackTrace: stackTrace));
        notifyErrorOccurred(e);
      }
    });

    _onBackImageAddedController.stream.listen((data) async {
      try {
        _doShowBackImagePlaceholderController.add(true);
        final url = await user.uploadImage(data, _card.deckKey);
        _card.backImagesUri.add(url);
        _doShowBackImagePlaceholderController.add(false);
        _doBackImageAddedController.add(_card.backImagesUri.build());
        _checkOperationAvailability();
      } catch (e, stackTrace) {
        _doShowBackImagePlaceholderController.add(false);
        unawaited(error_reporting.report(e, stackTrace: stackTrace));
        notifyErrorOccurred(e);
      }
    });
    _onFrontImageDeletedController.stream.listen((index) async {
      try {
        if (isAddOperation) {
          await user.deleteImage(_card.frontImagesUri[index]);
        } else {
          _imagesToDelete.add(_card.frontImagesUri[index]);
        }
        _card.frontImagesUri.removeAt(index);
        _doFrontImageAddedController.add(_card.frontImagesUri.build());
        _checkOperationAvailability();
      } catch (e, stackTrace) {
        unawaited(error_reporting.report(e, stackTrace: stackTrace));
        notifyErrorOccurred(e);
      }
    });
    _onBackImageDeletedController.stream.listen((index) async {
      try {
        if (isAddOperation) {
          await user.deleteImage(_card.backImagesUri[index]);
        } else {
          _imagesToDelete.add(_card.backImagesUri[index]);
        }
        _card.backImagesUri.removeAt(index);
        _doBackImageAddedController.add(_card.backImagesUri.build());
        _checkOperationAvailability();
      } catch (e, stackTrace) {
        unawaited(error_reporting.report(e, stackTrace: stackTrace));
        notifyErrorOccurred(e);
      }
    });
    _onClearImagesController.stream.listen((_) {
      _card.frontImagesUri.clear();
      _card.backImagesUri.clear();
      _doFrontImageAddedController.add(_card.frontImagesUri.build());
      _doBackImageAddedController.add(_card.backImagesUri.build());
      _checkOperationAvailability();
    });
    _onColorController.stream.listen((colorValue) {
      // If user pressed 2nd time on the same color, color is desabled
      // to default.
      if (_card.color == colorValue) {
        _card.color = null;
      } else {
        _card.color = colorValue;
      }
      _doColorController.add(_card.color);
      _checkOperationAvailability();
    });
  }

  Future<void> _createOrUpdateCard() {
    final card = _card.build();

    if (isAddOperation) {
      analytics.logCardCreate(card.deckKey);
      if (card.color != null) {
        analytics.logCardColorPicked(card.color.toRadixString(16));
      }
      return user.createCard(card: card, addReversed: _addReversedCard);
    } else {
      return user.updateCard(card: card);
    }
  }

  Future<void> _disableUI(Future<void> Function() f) async {
    _isOperationEnabled = false;
    _checkOperationAvailability();
    try {
      await f();
    } finally {
      _isOperationEnabled = true;
      _checkOperationAvailability();
    }
  }

  Future<void> _processSavingCard() async {
    try {
      await _disableUI(_createOrUpdateCard);
      if (!isAddOperation) {
        // Delete all images that user intended to delete
        _imagesToDelete.forEach(user.deleteImage);
        notifyPop();
        return;
      }
      if (_addReversedCard) {
        showMessage(locale.cardAndReversedAddedUserMessage);
      } else {
        showMessage(locale.cardAddedUserMessage);
      }
      _doClearInputFieldsController.add(null);
    } catch (e, stackTrace) {
      unawaited(error_reporting.report(e, stackTrace: stackTrace));
      notifyErrorOccurred(e);
    }
  }

  bool _isCardValid() => _addReversedCard
      ? (_card.front.trim().isNotEmpty || _card.frontImagesUri.isNotEmpty) &&
          (_card.back.trim().isNotEmpty || _card.backImagesUri.isNotEmpty)
      : _card.front.trim().isNotEmpty || _card.frontImagesUri.isNotEmpty;

  void _checkOperationAvailability() {
    _isOperationEnabledController.add(_isOperationEnabled && _isCardValid());
  }

  @override
  Future<bool> userClosesScreen() async {
    _doShowConfirmationDialogController.add(true);
    return Future.value(false);
  }

  @override
  void dispose() {
    _onSaveCardController.close();
    _doClearInputFieldsController.close();
    _onFrontSideTextController.close();
    _onBackSideTextController.close();
    _isOperationEnabledController.close();
    _addReversedCardController.close();
    _doShowConfirmationDialogController.close();
    _onDiscardChangesController.close();
    _onFrontImageAddedController.close();
    _onBackImageAddedController.close();
    _doFrontImageAddedController.close();
    _doBackImageAddedController.close();
    _onFrontImageDeletedController.close();
    _onBackImageDeletedController.close();
    _onClearImagesController.close();
    _doShowFrontImagePlaceholderController.close();
    _doShowBackImagePlaceholderController.close();
    _onColorController.close();
    _doColorController.close();
    super.dispose();
  }
}
