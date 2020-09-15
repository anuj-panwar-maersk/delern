import 'package:delern_flutter/models/base/stream_with_value.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

@immutable
class DatabaseWriteException implements Exception {
  final Map<String, dynamic> updates;
  final dynamic sourceException;
  final StackTrace stackTrace;
  final bool online;

  const DatabaseWriteException({
    @required this.sourceException,
    @required this.stackTrace,
    @required this.online,
    @required this.updates,
  });

  // TODO(dotdoom): export updates as "extra" when sentry error reporting
  //                supports that.
  @override
  String toString() => 'DatabaseWriteException(${updates.keys} '
      '[online:$online], $sourceException)';
}

class Database {
  final StreamWithValue<bool> isOnline;

  Database()
      : isOnline = StreamWithLatestValue(
            FirebaseDatabase.instance
                .reference()
                .child('.info/connected')
                .onValue
                .mapPerEvent((event) => event.snapshot.value == true),
            initialValue: false)
          // Subscribe ourselves to online status immediately because we always
          // want to know the current value, and that requires at least 1
          // subscription for StreamWithLatestValue. The resulting subscription
          // can be discarded (for now) because Database lives for the lifetime
          // of the application.
          ..updates.listen((_) {});

  Future<void> write(Map<String, dynamic> updates) async {
    // Firebase update() does not return until it gets response from the server.
    final updateFuture = FirebaseDatabase.instance.reference().update(updates);

    if (isOnline.value != true) {
      unawaited(updateFuture.catchError(
          // https://github.com/dart-lang/linter/issues/1099
          // ignore: avoid_types_on_closure_parameters
          (dynamic error, StackTrace stackTrace) =>
              throw DatabaseWriteException(
                sourceException: error,
                stackTrace: stackTrace,
                updates: updates,
                online: false,
              )));
      return;
    }

    try {
      await updateFuture;
    } catch (error, stackTrace) {
      throw DatabaseWriteException(
        sourceException: error,
        stackTrace: stackTrace,
        updates: updates,
        online: true,
      );
    }
  }
}
