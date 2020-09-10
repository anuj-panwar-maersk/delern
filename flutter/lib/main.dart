import 'package:delern_flutter/remote/app_config.dart';
import 'package:delern_flutter/views/decks_list/decks_list.dart';
import 'package:delern_flutter/views/helpers/auth_widget.dart';
import 'package:delern_flutter/views/helpers/device_info.dart';
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/routes.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:device_preview/device_preview.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_sentry/flutter_sentry.dart';

class App extends StatelessWidget {
  static final _analyticsNavigatorObserver =
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics());

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
        ],
        title: kReleaseMode ? 'Delern' : 'Delern DEBUG',
        builder: (context, child) =>
            // AuthWidget must be above Navigator to provide
            // CurrentUserWidget.of().
            DevicePreview.appBuilder(context, AuthWidget(child: child)),
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

void main() => FlutterSentry.wrap(
      () {
        FirebaseDatabase.instance.setPersistenceEnabled(true);
        FirebaseAnalytics().logAppOpen();
        AppConfig.instance;
        setDeviceOrientation();
        runApp(App());
      },
      dsn: 'https://e6b5021448e14a49803b2c734621deae@sentry.io/1867466',
    );
