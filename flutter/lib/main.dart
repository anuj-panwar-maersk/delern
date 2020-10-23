import 'dart:async';

import 'package:amplitude_flutter/amplitude.dart';
import 'package:delern_flutter/models/local_notification.dart';
import 'package:delern_flutter/remote/analytics/amplitude_analytics.dart';
import 'package:delern_flutter/remote/analytics/analytics.dart';
import 'package:delern_flutter/remote/analytics/firebase_analytics.dart';
import 'package:delern_flutter/remote/analytics/multi_analytics_logger.dart';
import 'package:delern_flutter/remote/app_config.dart';
import 'package:delern_flutter/remote/auth.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:delern_flutter/view_models/notifications_view_model.dart';
import 'package:delern_flutter/views/decks_list/decks_list.dart';
import 'package:delern_flutter/views/helpers/auth_widget.dart';
import 'package:delern_flutter/views/helpers/device_info.dart';
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/routes.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:device_preview/device_preview.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_sentry/flutter_sentry.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';

const _operationTimeOut = Duration(seconds: 10);

@immutable
class App extends StatelessWidget {
  static final _analyticsNavigatorObserver =
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics());

  final Auth auth;
  final AnalyticsLogger analyticsLogger;

  const App({
    @required this.auth,
    @required this.analyticsLogger,
  });

  @override
  Widget build(BuildContext context) {
    const isDevicePreviewEnabled =
        // ignore: do_not_use_environment
        bool.fromEnvironment('device_preview', defaultValue: false);
    return DevicePreview(
      // device_preview is disabled by default. To run app with device_preview
      // use flutter run --dart-define=device_preview=true
      enabled: isDevicePreviewEnabled,
      builder: (context) => MaterialApp(
        locale:
            isDevicePreviewEnabled ? DevicePreview.of(context).locale : null,
        // Produce collections of localized values
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          // This list limits what locales Global Localizations delegates
          // above will support. The first element of this list is
          // a fallback locale.
          Locale('en', 'US'),
          Locale('ru', 'RU'),
          Locale('de', 'DE'),
        ],
        navigatorObservers: [
          _analyticsNavigatorObserver,
          FlutterSentryNavigatorObserver(),
          routeObserver,
        ],
        title: kReleaseMode ? 'Delern' : 'Delern DEBUG',
        builder: (context, child) =>
            // AuthWidget must be above Navigator to provide
            // CurrentUserWidget.of().
            DevicePreview.appBuilder(
                context,
                MultiProvider(
                  providers: [
                    Provider(
                      lazy: false,
                      create: (_) => analyticsLogger,
                    ),
                    ChangeNotifierProvider(
                      create: (providerContext) {
                        // TODO(ksheremet): Change notifications with
                        // locale change
                        final localizedNotifications = AppConfig
                                    .instance.notificationMessages[
                                Localizations.localeOf(context).languageCode] ??
                            [];
                        return LocalNotifications(
                          onNotificationPressed: (payload) {
                            providerContext
                                .read<AnalyticsLogger>()
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
                          analytics: providerContext.read<AnalyticsLogger>(),
                        );
                      },
                      lazy: false,
                    ),
                  ],
                  child: AuthWidget(
                    auth: auth,
                    child: child,
                  ),
                )),
        theme: ThemeData(
          scaffoldBackgroundColor: app_styles.kScaffoldBackgroundColor,
          primarySwatch: app_styles.kPrimarySwatch,
          accentColor: app_styles.kAccentColor,
        ),
        routes: routes,
        home: const DecksList(),
      ),
    );
  }
}

Future<AnalyticsLogger> _setupAnalytics(Duration timeout) async {
  final amplitudeInstance = Amplitude.getInstance();
  final analyticList = <AnalyticsProvider>[
    FirebaseAnalyticsProvider(),
  ];
  try {
    // TODO(ksheremet): Store keys somewehre else
    await amplitudeInstance
        .init(
          kReleaseMode
              ? 'e98825b2d2182ee5c619c3408e27fb60'
              : '0c6ee8f335c9786288d821ed1ba63852',
        )
        .timeout(timeout);
    analyticList.add(AmplitudeAnalyticsProvider(
      instance: amplitudeInstance,
    ));
  } catch (e, stackTrace) {
    unawaited(error_reporting.report(e, stackTrace: stackTrace));
  }
  return AnalyticsLogger(MultiAnalyticsProvider(analyticList: analyticList));
}

Future<void> main() async => FlutterSentry.wrap(
      () async {
        await Firebase.initializeApp();
        unawaited(FirebaseDatabase.instance.setPersistenceEnabled(true));
        try {
          await AppConfig.instance.initialize().timeout(_operationTimeOut);
        } on TimeoutException catch (e, stackTrace) {
          unawaited(error_reporting.report(e, stackTrace: stackTrace));
        }
        setDeviceOrientation();
        final analyticsLogger = await _setupAnalytics(_operationTimeOut);
        unawaited(analyticsLogger.logAppOpen());
        runApp(App(
          auth: Auth(),
          analyticsLogger: analyticsLogger,
        ));
      },
      dsn: 'https://e6b5021448e14a49803b2c734621deae@sentry.io/1867466',
    );
