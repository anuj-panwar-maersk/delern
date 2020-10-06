import 'dart:async';

import 'package:delern_flutter/models/notification_payload.dart';
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

abstract class AnalyticsLogger {
  Future<void> logEvent({
    @required String name,
    Map<String, dynamic> parameters,
  });

  Future<void> setUserId(String id);

  Future<void> setCurrentScreen({@required String screenName});
}

class Analytics implements AnalyticsLogger {
  final AnalyticsLogger _analyticsLogger;

  Analytics(AnalyticsLogger analyticsLogger)
      : _analyticsLogger = analyticsLogger;

  Future<void> logDeckCreate() =>
      _analyticsLogger.logEvent(name: 'deck_create');

  Future<void> logDeckEditMenu(String deckId) => _analyticsLogger.logEvent(
        name: 'deck_edit_menu',
        parameters: <String, String>{
          'item_id': deckId,
        },
      );

  Future<void> logDeckEditSwipe(String deckId) => _analyticsLogger.logEvent(
        name: 'deck_edit_swipe',
        parameters: <String, String>{
          'item_id': deckId,
        },
      );

  Future<void> logDeckDeleteSwipe(String deckId) => _analyticsLogger.logEvent(
        name: 'deck_delete_swipe',
        parameters: <String, String>{
          'item_id': deckId,
        },
      );

  Future<void> logDeckDelete(String deckId) => _analyticsLogger.logEvent(
        name: 'deck_delete',
        parameters: <String, String>{
          'item_id': deckId,
        },
      );

  Future<void> logStartLearning(String deckId) => _analyticsLogger.logEvent(
        name: 'deck_learning_start',
        parameters: <String, String>{
          'item_id': deckId,
        },
      );

  Future<void> logShare({String deckId, String method}) =>
      _analyticsLogger.logEvent(
        name: 'share',
        parameters: <String, dynamic>{
          'content_type': deckMimeType,
          'item_id': deckId,
          'method': method,
        },
      );

// TODO(ksheremet): Check whether content type and method are recorded in
// Analytics
  Future<void> logUnshare({String deckId, String method}) =>
      _analyticsLogger.logEvent(
        name: 'unshare',
        parameters: <String, String>{
          'content_type': deckMimeType,
          'item_id': deckId,
          'method': method,
        },
      );

  Future<void> logCardCreate(String deckId) => _analyticsLogger.logEvent(
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
      _analyticsLogger.logEvent(
        name: 'card_response',
        parameters: <String, dynamic>{
          'item_id': deckId,
          'knows': knows ? 1 : 0,
          'previous_level': previousLevel,
        },
      );

  Future<void> logPromoteAnonymous() =>
      _analyticsLogger.logEvent(name: 'promote_anonymous');

  Future<void> logPromoteAnonymousFail() =>
      _analyticsLogger.logEvent(name: 'promote_anonymous_fail');

  /// [provider] must be a valid event identifier (e.g. no dots).
  Future<void> logLoginEvent(String provider) =>
      _analyticsLogger.logEvent(name: 'login_$provider');

  Future<void> logOnboardingStartEvent() =>
      _analyticsLogger.logEvent(name: 'onboarding_start');

  Future<void> logOnboardingDoneEvent() =>
      _analyticsLogger.logEvent(name: 'onboarding_done');

  Future<void> logOnboardingSkipEvent() =>
      _analyticsLogger.logEvent(name: 'onboarding_skip');

  Future<void> logAddImageToCard({@required bool isFrontSide}) =>
      _analyticsLogger.logEvent(
          name: 'card_create_with_image',
          parameters: <String, dynamic>{'front': isFrontSide ? 1 : 0});

  Future<void> logLocalNotificationOpen(
          {@required NotificationPayload payload}) =>
      _analyticsLogger.logEvent(
          name: 'local_notification_open',
          parameters: <String, dynamic>{
            'title': payload.title,
            'body': payload.body ?? '',
            'hour': payload.time.hour,
            'minute': payload.time.minute,
            'day': payload.day,
            'route': payload.route ?? '',
          });

  Future<void> logIosNotificationPermissions({@required bool isGranted}) =>
      _analyticsLogger
          .logEvent(name: 'ios_notification', parameters: <String, dynamic>{
        'granted': isGranted ? 1 : 0,
      });

  Future<void> logScheduleNotifications(
          {@required bool isScheduled, @required int totalCards}) =>
      _analyticsLogger
          .logEvent(name: 'notification_popup', parameters: <String, dynamic>{
        'cards': totalCards,
        'scheduled': isScheduled ? 1 : 0,
      });

  Future<void> logLogin({String loginMethod}) => _analyticsLogger.logEvent(
        name: 'login',
        parameters: <String, dynamic>{
          'method': loginMethod,
        },
      );

  Future<void> logSignUp({
    @required String signUpMethod,
  }) =>
      _analyticsLogger.logEvent(
        name: 'sign_up',
        parameters: <String, dynamic>{
          'method': signUpMethod,
        },
      );

  Future<void> logIntervalLearningEvent() =>
      _analyticsLogger.logEvent(name: 'learning_interval');

  Future<void> logViewLearningEvent() =>
      _analyticsLogger.logEvent(name: 'learning_view');

  @override
  Future<void> logEvent({String name, Map<String, dynamic> parameters}) =>
      _analyticsLogger.logEvent(name: name, parameters: parameters);

  @override
  Future<void> setCurrentScreen({String screenName}) =>
      _analyticsLogger.setCurrentScreen(screenName: screenName);

  @override
  Future<void> setUserId(String id) => _analyticsLogger.setUserId(id);
}
