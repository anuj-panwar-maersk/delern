import 'dart:async';

import 'package:delern_flutter/l10n/app_localizations.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserMessages {
  static void showAndReportError(
    ScaffoldState Function() scaffoldFinder,
    dynamic e, {
    String userFriendlyPrefix,
    StackTrace stackTrace,
  }) {
    error_reporting.report(
      e,
      stackTrace: stackTrace,
      description: userFriendlyPrefix == null
          ? null
          : 'via showAndReportError: $userFriendlyPrefix',
    );

    // Call a finder only *after* reporting the error, in case it crashes
    // (often because Scaffold.of cannot find Scaffold ancestor widget).
    final scaffoldState = scaffoldFinder();

    var message = formUserFriendlyErrorMessage(scaffoldState.context.l, e);
    if (userFriendlyPrefix != null) {
      message = '$userFriendlyPrefix ($message)';
    }
    showMessage(scaffoldState, message);
  }

  // TODO(ksheremet): Add user message for Snackbar and error message for
  // reporting.
  // In navigation drawer 'Contact us' show user message to user and report
  // error.
  static void showMessage(ScaffoldState scaffoldState, String message) {
    scaffoldState.showSnackBar(SnackBar(
      content: Text(message, maxLines: 5, overflow: TextOverflow.ellipsis),
      duration: const Duration(seconds: 7),
    ));
  }

  static String formUserFriendlyErrorMessage(
    AppLocalizations locale,
    dynamic e,
  ) {
    String exceptionSpecificMessage;
    if (e is PlatformException) {
      exceptionSpecificMessage = e.message;
    } else if (e is DatabaseError) {
      exceptionSpecificMessage = e.message;
    } else if (e is Exception) {
      final exceptionString = e.toString();
      // Taken from exceptions.dart.
      // Default Exception.toString() will start with this prefix, with the
      // original message (from Exception() constructor) following. We can cut
      // out the prefix to save space.
      const exceptionPrefix = 'Exception: ';
      if (exceptionString.startsWith(exceptionPrefix)) {
        exceptionSpecificMessage =
            exceptionString.substring(exceptionPrefix.length);
      }
    }
    exceptionSpecificMessage ??= e.toString();
    return locale.errorUserMessage + exceptionSpecificMessage;
  }

  static Future<void> showSimpleInfoDialog(
          BuildContext context, String message) =>
      showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(message),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(MaterialLocalizations.of(context)
                        .okButtonLabel
                        .toUpperCase()),
                  ),
                ],
              ));
}
