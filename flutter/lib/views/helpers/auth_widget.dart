import 'dart:async';

import 'package:delern_flutter/models/fcm_model.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/remote/app_config.dart';
import 'package:delern_flutter/remote/auth.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:delern_flutter/views/helpers/device_info.dart';
import 'package:delern_flutter/views/helpers/progress_indicator_widget.dart';
import 'package:delern_flutter/views/sign_in/sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pedantic/pedantic.dart';

/// A widget handling application-wide user authentication and anything
/// associated with it (FCM, Sign In etc). Renders either as a [SignIn], or
/// [CurrentUserWidget] wrapped around [child].
class AuthWidget extends StatefulWidget {
  final Widget child;

  const AuthWidget({@required this.child}) : assert(child != null);

  @override
  State<StatefulWidget> createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  User _currentUser = Auth.instance.currentUser;

  StreamSubscription<String> _fcmSubscription;
  StreamSubscription<User> _userChangedSubscription;

  @override
  void initState() {
    super.initState();

    _fcmSubscription = FirebaseMessaging().onTokenRefresh.listen((token) async {
      if (token == null) {
        return;
      }

      unawaited(FirebaseMessaging().subscribeToTopic('PUSH_RC'));

      final fcm = (FCMModelBuilder()
            ..language = Localizations.localeOf(context).toString()
            ..name = (await DeviceInfo.getDeviceInfo()).userFriendlyName
            ..key = token)
          .build();

      debugPrint('Registering ${_currentUser.uid} for FCM as ${fcm.name} '
          'in ${fcm.language}');
      unawaited(_currentUser.addFCM(fcm: fcm));
    });

    _userChangedSubscription =
        Auth.instance.onUserChanged.listen((newUser) async {
      setState(() {
        _currentUser = newUser;
      });

      if (_currentUser != null) {
        error_reporting.uid = _currentUser.uid;

        unawaited(FirebaseAnalytics().setUserId(_currentUser.uid));
        final loginProviders = _currentUser.providers;
        unawaited(FirebaseAnalytics().logLogin(
            loginMethod: loginProviders.isEmpty
                ? 'anonymous'
                : loginProviders.join(',')));

        // Must be called after each login to obtain a FirebaseMessaging token.
        FirebaseMessaging().configure(
          onMessage: (message) {
            // TODO(dotdoom): show a snack bar if message['notification'] map
            //                has 'title' and 'body' values.

            final dynamic data = message['data'];
            if (data is Map<String, String>) {
              if (data['CONFIG_STATE'] == 'STALE') {
                AppConfig.instance.remoteConfigIsStale = true;
              }
            }

            return null;
          },
        );
      }
    });

    if (!Auth.instance.authStateKnown) {
      debugPrint('Auth state unknown, trying to sign in silently...');
      Auth.instance.signInSilently();
    }
  }

  @override
  void dispose() {
    _fcmSubscription?.cancel();
    _userChangedSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser != null) {
      return CurrentUserWidget(_currentUser, child: widget.child);
    }
    if (!Auth.instance.authStateKnown) {
      return const ProgressIndicatorWidget();
    }

    return const SignIn();
  }
}

class CurrentUserWidget extends InheritedWidget {
  final User user;

  static CurrentUserWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CurrentUserWidget>();

  const CurrentUserWidget(this.user, {Key key, Widget child})
      : assert(user != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(CurrentUserWidget oldWidget) =>
      user != oldWidget.user;
}
