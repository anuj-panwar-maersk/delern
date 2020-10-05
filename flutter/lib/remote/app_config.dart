import 'dart:async';
import 'dart:convert';

import 'package:delern_flutter/models/local_notification.dart';
import 'package:delern_flutter/models/serializers.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:pedantic/pedantic.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _fetchTimeout = Duration(seconds: 8);

class AppConfig {
  static final AppConfig _instance = AppConfig._();

  static AppConfig get instance => _instance;

  AppConfig._();

  /// Remote Config: whether enable or disable images uploading feature.
  bool get imageFeatureEnabled =>
      _remoteValueOrNull('images_feature_enabled')?.asBool() ?? false;

  /// Remote Config: whether enable or disable sharing decks with other users.
  bool get sharingFeatureEnabled =>
      _remoteValueOrNull('sharing_feature_enabled')?.asBool() ?? true;

  /// Remote Config: call silentSignIn() instead of relying on Firebase.
  bool get explicitSilentSignInEnabled =>
      _remoteValueOrNull('explicit_silent_sign_in_enabled')?.asBool() ?? false;

  int get totalCardsForNotificationSchedule =>
      _remoteValueOrNull('total_cards_for_notification_schedule')?.asInt() ?? 5;

  Map<String, List<LocalNotification>> get notificationMessages {
    final messagesString =
        _remoteValueOrNull('notification_messages')?.asString();

    if (messagesString == null) {
      return {};
    }
    final result = <String, List<LocalNotification>>{};
    try {
      (json.decode(messagesString) as Map<String, dynamic>) // ignore: avoid_as
          .forEach((lang, dynamic notificationList) {
        final notifications = (notificationList as List) // ignore: avoid_as
            ?.map((dynamic notification) => serializers.deserializeWith(
                LocalNotification.serializer, notification))
            ?.toList();
        result[lang] = notifications;
      });
    } catch (e, stackTrace) {
      unawaited(error_reporting.report(e, stackTrace: stackTrace));
      return {};
    }

    return result;
  }

  /// Returns [RemoteConfigValue] if the source is remote storage, otherwise
  /// `null` (if the value comes from defaults or is unitialized).
  RemoteConfigValue _remoteValueOrNull(String key) {
    final value = _remoteConfig?.getValue(key);
    return value?.source == ValueSource.valueRemote ? value : null;
  }

  RemoteConfig _remoteConfig;
  SharedPreferences _sharedPreferences;

  Future<void> initialize() async {
    try {
      _sharedPreferences = await SharedPreferences.getInstance();
    } finally {
      _remoteConfig = await RemoteConfig.instance;
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        debugMode: kDebugMode,
      ));

      await _remoteConfig
          .fetch(
            expiration:
                kDebugMode ? const Duration() : const Duration(hours: 5),
          )
          .timeout(_fetchTimeout);
      if (await _remoteConfig.activateFetched()) {
        debugPrint('Fetched Remote Config from the server and it has changed');
      }
    }
  }

  static const _notificationsKey = 'shared_pref_is_notifications_set';

  /// Shared Preference: whether notifications were set
  bool get isNotificationsSet =>
      _sharedPreferences?.getBool(_notificationsKey) ?? false;

  set isNotificationsSet(bool value) =>
      _sharedPreferences?.setBool(_notificationsKey, value);

  static const _notificationsScheduleKey = 'shared_pref_notification_schedule';

  String get notificationSchedule =>
      _sharedPreferences?.getString(_notificationsScheduleKey);

  set notificationSchedule(String schedule) =>
      _sharedPreferences?.setString(_notificationsScheduleKey, schedule);
}
