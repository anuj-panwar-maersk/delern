import 'dart:async';

import 'package:delern_flutter/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

@immutable
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ru', 'de'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(
      locale.countryCode.isEmpty ? locale.languageCode : locale.toString());

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsExtension on BuildContext {
  /// https://flutter.io/tutorials/internationalization/
  AppLocalizations get l =>
      Localizations.of<AppLocalizations>(this, AppLocalizations);
}
