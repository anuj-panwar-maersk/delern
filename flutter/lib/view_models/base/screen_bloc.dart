import 'dart:async';

import 'package:delern_flutter/l10n/app_localizations.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/views/helpers/user_messages.dart';
import 'package:meta/meta.dart';

abstract class ScreenBloc {
  final User user;
  AppLocalizations _locale;

  // Not using @required named parameters because they are easily missed due to
  // dartanalyzer bug: https://github.com/dart-lang/sdk/issues/30117.
  ScreenBloc(this.user) : assert(user != null) {
    _onLocaleController.stream.listen((locale) {
      _locale = locale;
    });
    _onCloseScreenController.stream.listen((_) async {
      if (await userClosesScreen()) {
        notifyPop();
      }
    });
  }

  /// Contains internationalized messages. It used to show user messages
  AppLocalizations get locale => _locale;

  /// A stream that emit an event when screen must be closed
  Stream<void> get doPop => _doPopController.stream;
  final _doPopController = StreamController<void>();

  /// A stream that emits an error message when an error occurs.
  Stream<String> get doShowError => _doShowErrorController.stream;
  final _doShowErrorController = StreamController<String>();

  /// A stream that emits a message to show to user.
  Stream<String> get doShowMessage => _doShowMessageController.stream;
  final _doShowMessageController = StreamController<String>();

  /// Sink to write when locale is changed
  Sink<AppLocalizations> get onLocale => _onLocaleController.sink;
  final _onLocaleController = StreamController<AppLocalizations>();

  /// Sink to write an event when user decides to leave a screen
  Sink<void> get onCloseScreen => _onCloseScreenController.sink;
  final _onCloseScreenController = StreamController<void>();

  /// Call to inform the user that an error has occured. Report the error via
  /// error_reporting separately, if needed.
  @protected
  void notifyErrorOccurred(dynamic e) {
    if (!_doShowErrorController.isClosed) {
      _doShowErrorController
          .add(UserMessages.formUserFriendlyErrorMessage(locale, e));
    }
  }

  /// Call to show message to user
  @protected
  void showMessage(String message) {
    if (!_doShowMessageController.isClosed) {
      _doShowMessageController.add(message);
    }
  }

  /// Method that checks whether it is ok to close the screen.
  /// On default method always allows to close a screen. To add more
  /// functionality it should be overwritten in a subclass.
  @protected
  Future<bool> userClosesScreen() async => true;

  /// Internal method that called by BLoC when screen must be closed
  @protected
  void notifyPop() {
    if (!_doPopController.isClosed) {
      _doPopController.add(null);
    }
  }

  /// Method releases resources
  @mustCallSuper
  void dispose() {
    _doPopController.close();
    _doShowErrorController.close();
    _onLocaleController.close();
    _onCloseScreenController.close();
    _doShowMessageController.close();
  }
}
