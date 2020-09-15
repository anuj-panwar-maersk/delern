import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_sentry/flutter_sentry.dart';
import 'package:sentry/sentry.dart';

set uid(String uid) => FlutterSentry.instance.userContext = User(id: uid);

Future<void> report(
  dynamic error, {
  String description,
  StackTrace stackTrace,
}) async {
  if (stackTrace == null && error is Error) {
    stackTrace = error.stackTrace;
  }
  stackTrace ??= StackTrace.current;

  debugPrint('Sending error report: $error\n$description\n$stackTrace');
  debugPrint('---');

  // TODO(dotdoom): add description when it will be possible.
  return FlutterSentry.instance.captureException(
    exception: error,
    stackTrace: stackTrace,
  );
}
