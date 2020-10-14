import 'package:amplitude_flutter/amplitude.dart';
import 'package:delern_flutter/remote/analytics/analytics.dart';
import 'package:flutter/material.dart';

// https://developers.amplitude.com/docs/flutter-setup
class AmplitudeAnalytics implements AnalyticsProvider {
  final String apiKey;

  bool _initialized = false;

  AmplitudeAnalytics({@required this.apiKey});

  Future<Amplitude> _getInstance() async {
    final instance = Amplitude.getInstance();
    if (!_initialized) {
      await instance.init(apiKey);
      await instance.trackingSessionEvents(true);
      _initialized = true;
    }
    return instance;
  }

  @override
  Future<void> logEvent({String name, Map<String, dynamic> parameters}) async {
    final instance = await _getInstance();
    return instance.logEvent(name, eventProperties: parameters);
  }

  @override
  Future<void> setUserId(String id) async {
    final instance = await _getInstance();
    return instance.setUserId(id);
  }

  @override
  Future<void> setCurrentScreen({String screenName}) async {
    final instance = await _getInstance();
    return instance.logEvent('screen_view', eventProperties: <String, dynamic>{
      'screen_name': screenName,
    });
  }
}
