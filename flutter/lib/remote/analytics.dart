import 'dart:async';

import 'package:delern_flutter/models/notification_payload.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:meta/meta.dart';

const deckMimeType = 'application/flashcards-deck';

Future<void> trace<T>(String name, Future<T> operation) async {
  final trace = FirebasePerformance.instance.newTrace(name);
  await trace.start();
  try {
    final result = await operation;
    await trace.putAttribute('result', result.toString());
  } catch (e) {
    await trace.putAttribute('error', e.runtimeType.toString());
    rethrow;
  } finally {
    await trace.stop();
  }
}

Completer<T> startTrace<T>(String name) {
  final completer = Completer<T>();
  trace(name, completer.future);
  return completer;
}

Future<void> logDeckCreate() =>
    FirebaseAnalytics().logEvent(name: 'deck_create');

Future<void> logDeckEditMenu(String deckId) => FirebaseAnalytics().logEvent(
      name: 'deck_edit_menu',
      parameters: <String, String>{
        'item_id': deckId,
      },
    );

Future<void> logDeckEditSwipe(String deckId) => FirebaseAnalytics().logEvent(
      name: 'deck_edit_swipe',
      parameters: <String, String>{
        'item_id': deckId,
      },
    );

Future<void> logDeckDeleteSwipe(String deckId) => FirebaseAnalytics().logEvent(
      name: 'deck_delete_swipe',
      parameters: <String, String>{
        'item_id': deckId,
      },
    );

Future<void> logDeckDelete(String deckId) => FirebaseAnalytics().logEvent(
      name: 'deck_delete',
      parameters: <String, String>{
        'item_id': deckId,
      },
    );

Future<void> logStartLearning(String deckId) => FirebaseAnalytics().logEvent(
      name: 'deck_learning_start',
      parameters: <String, String>{
        'item_id': deckId,
      },
    );

Future<void> logShare({String deckId, String method}) =>
    FirebaseAnalytics().logShare(
      contentType: deckMimeType,
      itemId: deckId,
      method: method,
    );

// TODO(ksheremet): Check whether content type and method are recorded in
// Analytics
Future<void> logUnshare({String deckId, String method}) =>
    FirebaseAnalytics().logEvent(
      name: 'unshare',
      parameters: <String, String>{
        'content_type': deckMimeType,
        'item_id': deckId,
        'method': method,
      },
    );

Future<void> logCardCreate(String deckId) => FirebaseAnalytics().logEvent(
      name: 'card_create',
      parameters: <String, String>{
        'item_id': deckId,
      },
    );

Future<void> logCardResponse({
  @required String deckId,
  @required bool knows,
  @required int previousLevel,
}) =>
    FirebaseAnalytics().logEvent(
      name: 'card_response',
      parameters: <String, dynamic>{
        'item_id': deckId,
        'knows': knows ? 1 : 0,
        'previous_level': previousLevel,
      },
    );

Future<void> logPromoteAnonymous() =>
    FirebaseAnalytics().logEvent(name: 'promote_anonymous');

Future<void> logPromoteAnonymousFail() =>
    FirebaseAnalytics().logEvent(name: 'promote_anonymous_fail');

/// [provider] must be a valid event identifier (e.g. no dots).
Future<void> logLoginEvent(String provider) =>
    FirebaseAnalytics().logEvent(name: 'login_$provider');

Future<void> logOnboardingStartEvent() =>
    FirebaseAnalytics().logEvent(name: 'onboarding_start');

Future<void> logOnboardingDoneEvent() =>
    FirebaseAnalytics().logEvent(name: 'onboarding_done');

Future<void> logOnboardingSkipEvent() =>
    FirebaseAnalytics().logEvent(name: 'onboarding_skip');

Future<void> logAddImageToCard({@required bool isFrontSide}) =>
    FirebaseAnalytics().logEvent(
        name: 'card_create_with_image',
        parameters: <String, dynamic>{'front': isFrontSide ? 1 : 0});

Future<void> logLocalNotificationOpen(
        {@required NotificationPayload payload}) =>
    FirebaseAnalytics().logEvent(
        name: 'local_notification_open',
        parameters: <String, dynamic>{
          'title': payload.title,
          'subtitle': payload.subtitle,
          'time': payload.time,
          'day': payload.day,
          'route': payload.route,
        });
