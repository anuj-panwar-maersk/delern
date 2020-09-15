import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static const _remoteConfigIsStaleKey = 'remote_config_is_stale';

  /// Shared Preference: whether remote config is stale and needs to be fetched
  /// soon.
  // TODO(dotdoom): remove this as it is merely an example and is unused.
  bool get remoteConfigIsStale =>
      _sharedPreferences?.getBool(_remoteConfigIsStaleKey) ?? false;

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

      await _remoteConfig.fetch(
        expiration: kDebugMode ? const Duration() : const Duration(hours: 5),
      );
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
