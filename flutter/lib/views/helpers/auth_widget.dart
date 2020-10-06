import 'dart:async';

import 'package:delern_flutter/models/fcm_model.dart';
import 'package:delern_flutter/models/local_notification.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/remote/analytics/amplitude_analytics.dart';
import 'package:delern_flutter/remote/analytics/analytics.dart';
import 'package:delern_flutter/remote/analytics/firebase_analytics.dart';
import 'package:delern_flutter/remote/analytics/multi_analytics_logger.dart';
import 'package:delern_flutter/remote/app_config.dart';
import 'package:delern_flutter/remote/auth.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:delern_flutter/view_models/notifications_view_model.dart';
import 'package:delern_flutter/views/helpers/device_info.dart';
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/stream_with_value_builder.dart';
import 'package:delern_flutter/views/sign_in/sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';

/// A widget handling application-wide user authentication and anything
/// associated with it (FCM, Sign In etc). Renders either as a [SignIn], or
/// [CurrentUserWidget] wrapped around [child].
class AuthWidget extends StatefulWidget {
  final Widget child;
  final Auth auth;

  const AuthWidget({
    @required this.auth,
    @required this.child,
  }) : assert(child != null);

  @override
  State<StatefulWidget> createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  StreamSubscription<String> _fcmSubscription;
  StreamSubscription<User> _userChangedSubscription;

  @override
  void initState() {
    super.initState();

    _fcmSubscription = FirebaseMessaging().onTokenRefresh.listen((token) async {
      if (token == null) {
        return;
      }

      final fcm = (FCMModelBuilder()
            ..language = Localizations.localeOf(context).toString()
            ..name = (await DeviceInfo.getDeviceInfo()).userFriendlyName
            ..key = token)
          .build();

      final currentUser = widget.auth.currentUser.value;

      debugPrint('Registering ${currentUser.uid} for FCM as ${fcm.name} '
          'in ${fcm.language}');
      unawaited(currentUser.addFCM(fcm: fcm));
    });

    if (!widget.auth.authStateKnown &&
        AppConfig.instance.explicitSilentSignInEnabled) {
      debugPrint('Auth state unknown, trying to sign in silently...');
      widget.auth.signInSilently();
    }
  }

  @override
  void dispose() {
    _fcmSubscription?.cancel();
    _userChangedSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          Provider(
            lazy: false,
            create: setupAnalytics,
          ),
          ChangeNotifierProvider(
              create: (providerContext) {
                // TODO(ksheremet): Change notifications with
                // locale change
                final localizedNotifications =
                    AppConfig.instance.notificationMessages[
                            Localizations.localeOf(context).languageCode] ??
                        [];
                return LocalNotifications(
                  onNotificationPressed: (payload) {
                    providerContext
                        .read<Analytics>()
                        .logLocalNotificationOpen(payload: payload);
                  },
                  flutterLocalNotificationsPlugin:
                      FlutterLocalNotificationsPlugin(),
                  messages: localizedNotifications.isNotEmpty
                      ? localizedNotifications
                      : <LocalNotification>[
                          (LocalNotificationBuilder()
                                ..title = context.l.defaultNotification)
                              .build()
                        ],
                  notificationPurpose: context.l.notificationPurpose,
                  analytics: providerContext.read<Analytics>(),
                );
              },
              lazy: false),
        ],
        builder: (context, child) => DataStreamWithValueBuilder<User>(
          streamWithValue: widget.auth.currentUser,
          onData: (currentUser) async {
            if (currentUser == null) {
              return;
            }

            // We won't get the first update if the user is already signed in,
            // but it is only possible when the widget is re-created
            // for some reason.
            // When the app starts, the user is always signed out, and it's only
            // the signInSilently call that we do below that may change that,
            // without user interaction.

            error_reporting.uid = currentUser.uid;

            // Must be called after each login to obtain FirebaseMessaging
            // token.
            FirebaseMessaging().configure(
              // TODO(dotdoom): show a snack bar if message['notification'] map
              //                has 'title' and 'body' values.
              onMessage: (message) => null,
            );

            // Analytics comes in last, since it's less important.
            unawaited(context.read<Analytics>().setUserId(currentUser.uid));
            final loginProviders = currentUser.profile.value.providers.isEmpty
                ? 'anonymous'
                : currentUser.profile.value.providers.join(',');

            unawaited(context
                .read<Analytics>()
                .logLogin(loginMethod: loginProviders));

            if ((await currentUser.auth.latestSignInCreatedNewUser) == true) {
              unawaited(context.read<Analytics>().logSignUp(
                    signUpMethod: loginProviders,
                  ));
            }
          },
          builder: (context, currentUser) => CurrentUserWidget(
            currentUser,
            child: widget.child,
          ),
          nullValueBuilder: (context) => SignIn(
            SignInMode.initialSignIn,
            auth: widget.auth,
          ),
        ),
      );
}

Analytics setupAnalytics(BuildContext context) {
  final multiAnalyticsLogger =
      MultiAnalyticsLogger(analyticList: <AnalyticsLogger>[
    AmplitudeAnalytics(
      // TODO(ksheremet): Store keys somewehre else
      apiKey: kReleaseMode
          ? 'e98825b2d2182ee5c619c3408e27fb60'
          : '0c6ee8f335c9786288d821ed1ba63852',
    ),
    FirebaseAnalyticsWrapper(),
  ]);

  return Analytics(multiAnalyticsLogger);
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
