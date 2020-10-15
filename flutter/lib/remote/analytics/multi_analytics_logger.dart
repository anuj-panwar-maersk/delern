import 'package:delern_flutter/remote/analytics/analytics.dart';
import 'package:flutter/foundation.dart';

class MultiAnalyticsProvider implements AnalyticsProvider {
  final List<AnalyticsProvider> _analyticList;

  MultiAnalyticsProvider({@required List<AnalyticsProvider> analyticList})
      : _analyticList = analyticList;

  @override
  Future<void> logEvent({String name, Map<String, dynamic> parameters}) async {
    await Future.forEach(
        _analyticList,
        // https://github.com/dart-lang/linter/issues/1099
        // ignore: avoid_types_on_closure_parameters
        (AnalyticsProvider analytic) =>
            analytic.logEvent(name: name, parameters: parameters));
  }

  @override
  Future<void> setCurrentScreen({String screenName}) async {
    await Future.forEach(
        _analyticList,
        // https://github.com/dart-lang/linter/issues/1099
        // ignore: avoid_types_on_closure_parameters
        (AnalyticsProvider analytic) =>
            analytic.setCurrentScreen(screenName: screenName));
  }

  @override
  Future<void> setUserId(String id) async {
    await Future.forEach(
        _analyticList,
        // https://github.com/dart-lang/linter/issues/1099
        // ignore: avoid_types_on_closure_parameters
        (AnalyticsProvider analytic) => analytic.setUserId(id));
  }
}
