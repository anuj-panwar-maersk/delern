import 'package:delern_flutter/remote/analytics/analytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticsWrapper extends AnalyticsLogger {
  @override
  Future<void> logEvent({String name, Map<String, dynamic> parameters}) =>
      FirebaseAnalytics().logEvent(name: name, parameters: parameters);

  @override
  Future<void> setCurrentScreen({String screenName}) =>
      FirebaseAnalytics().setCurrentScreen(screenName: screenName);

  @override
  Future<void> setUserId(String id) => FirebaseAnalytics().setUserId(id);
}
