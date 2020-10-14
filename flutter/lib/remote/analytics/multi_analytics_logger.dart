import 'package:delern_flutter/remote/analytics/analytics.dart';
import 'package:flutter/foundation.dart';

class MultiAnalyticsLogger extends AnalyticsProvider {
  final List<AnalyticsProvider> _analyticList;

  MultiAnalyticsLogger({@required List<AnalyticsProvider> analyticList})
      : _analyticList = analyticList;

  @override
  Future<void> logEvent({String name, Map<String, dynamic> parameters}) async {
    // https://github.com/dart-lang/linter/issues/1099
    // ignore: avoid_types_on_closure_parameters
    await Future.forEach(_analyticList, (AnalyticsProvider analytic) async {
      await analytic.logEvent(name: name, parameters: parameters);
    });
  }

  @override
  Future<void> setCurrentScreen({String screenName}) async {
    // https://github.com/dart-lang/linter/issues/1099
    // ignore: avoid_types_on_closure_parameters
    await Future.forEach(_analyticList, (AnalyticsProvider analytic) async {
      await analytic.setCurrentScreen(screenName: screenName);
    });
  }

  @override
  Future<void> setUserId(String id) async {
    // https://github.com/dart-lang/linter/issues/1099
    // ignore: avoid_types_on_closure_parameters
    await Future.forEach(_analyticList, (AnalyticsProvider analytic) async {
      await analytic.setUserId(id);
    });
  }
}
