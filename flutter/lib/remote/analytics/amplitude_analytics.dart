import 'package:amplitude_flutter/amplitude.dart';
import 'package:delern_flutter/remote/analytics/analytics.dart';
import 'package:flutter/material.dart';

// https://developers.amplitude.com/docs/flutter-setup
class AmplitudeAnalyticsProvider implements AnalyticsProvider {
  final Amplitude _instance;

  AmplitudeAnalyticsProvider({@required Amplitude instance})
      : _instance = instance;

  @override
  Future<void> logEvent({String name, Map<String, dynamic> parameters}) =>
      _instance.logEvent(name, eventProperties: parameters);

  @override
  Future<void> setUserId(String id) => _instance.setUserId(id);

  @override
  Future<void> setCurrentScreen({String screenName}) =>
      _instance.logEvent('screen_view', eventProperties: <String, dynamic>{
        'screen_name': screenName,
      });
}
