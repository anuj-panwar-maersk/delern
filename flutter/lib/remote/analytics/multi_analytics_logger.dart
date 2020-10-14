import 'package:delern_flutter/remote/analytics/analytics.dart';
import 'package:flutter/foundation.dart';

class MultiAnalyticsLogger extends AnalyticsProvider {
  final List<AnalyticsProvider> analyticList;

  MultiAnalyticsLogger({@required this.analyticList});

  @override
  Future<void> logEvent({String name, Map<String, dynamic> parameters}) async {
    analyticList.forEach((analytic) async {
      await analytic.logEvent(name: name, parameters: parameters);
    });
  }

  @override
  Future<void> setCurrentScreen({String screenName}) async {
    analyticList.forEach((analytic) async {
      await analytic.setCurrentScreen(screenName: screenName);
    });
  }

  @override
  Future<void> setUserId(String id) async {
    analyticList.forEach((analytic) async {
      await analytic.setUserId(id);
    });
  }
}
