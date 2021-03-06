import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/remote/auth.dart';
import 'package:delern_flutter/views/app_settings/app_settings.dart';
import 'package:delern_flutter/views/app_settings/cards_font_size.dart';
import 'package:delern_flutter/views/card_create_update/card_create_update.dart';
import 'package:delern_flutter/views/card_list/card_list.dart';
import 'package:delern_flutter/views/card_preview/card_preview.dart';
import 'package:delern_flutter/views/cards_interval_learning/cards_interval_learning.dart';
import 'package:delern_flutter/views/cards_view_learning/cards_view_learning.dart';
import 'package:delern_flutter/views/deck_sharing/deck_sharing.dart';
import 'package:delern_flutter/views/notifications/notification_settings.dart';
import 'package:delern_flutter/views/sign_in/sign_in.dart';
import 'package:flutter/material.dart';

// How to specify RouteSettings name parameter:
// - each sequence of sub-components must be an existing route:
//   e.g. if your route name is /cards/new, then "/" and "/cards" and
//   "/cards/new" must all be existing named routes;
// - when nesting route into subcomponents, think of how the user will navigate
//   away when opening the route from an external link:
//   e.g. if the user clicks https://delern.org/cards/edit?deckId=1234abcd, they
//   will get to the "New card" page, and pressing "Back" will take them to
//   "Deck 1234abcd" page ("/cards" named route), and pressing "Back" again will
//   take them to list of decks page ("/" named route).

final routes = <String, Widget Function(BuildContext)>{
  CardList.routeName: (_) => const CardList(),
  CardCreateUpdate.routeNameNew: (_) => const CardCreateUpdate(),
  CardCreateUpdate.routeNameEdit: (_) => const CardCreateUpdate(),
  CardPreview.routeName: (_) => const CardPreview(),
  CardsIntervalLearning.routeName: (_) => const CardsIntervalLearning(),
  CardsViewLearning.routeName: (_) => const CardsViewLearning(),
  NotificationSettings.routeName: (_) => const NotificationSettings(),
  AppSettings.routeName: (_) => const AppSettings(),
  CardsFontSize.routeName: (_) => const CardsFontSize(),
};

Future<void> openLearnDeckScreen(
  BuildContext context, {
  @required String deckKey,
}) =>
    Navigator.pushNamed(
      context,
      CardList.routeName,
      arguments: CardList.buildArguments(deckKey: deckKey),
    );

Future<void> openLearnCardIntervalScreen(
  BuildContext context, {
  @required String deckKey,
  Iterable<String> tags,
}) =>
    Navigator.pushNamed(
      context,
      CardsIntervalLearning.routeName,
      arguments: CardsIntervalLearning.buildArguments(
        deckKey: deckKey,
        tags: tags,
      ),
    );

Future<void> openLearnCardViewScreen(
  BuildContext context, {
  @required String deckKey,
  Iterable<String> tags,
}) =>
    Navigator.pushNamed(
      context,
      CardsViewLearning.routeName,
      arguments: CardsViewLearning.buildArguments(
        deckKey: deckKey,
        tags: tags,
      ),
    );

Future<void> openNewCardScreen(
  BuildContext context, {
  @required String deckKey,
  bool isDecksScreen = false,
}) {
  // After adding cards make sure that user is at learning cards screen
  if (isDecksScreen) {
    openLearnDeckScreen(context, deckKey: deckKey);
  }
  return Navigator.pushNamed(
    context,
    CardCreateUpdate.routeNameNew,
    arguments: CardCreateUpdate.buildArguments(deckKey: deckKey),
  );
}

Future<void> openEditCardScreen(
  BuildContext context, {
  @required String deckKey,
  @required String cardKey,
}) =>
    Navigator.pushNamed(
      context,
      CardCreateUpdate.routeNameEdit,
      arguments: CardCreateUpdate.buildArguments(
        deckKey: deckKey,
        cardKey: cardKey,
      ),
    );

Future<void> openShareDeckScreen(BuildContext context, DeckModel deck) =>
    Navigator.push(
      context,
      MaterialPageRoute(
          settings: const RouteSettings(name: DeckSharing.routeName),
          builder: (context) => DeckSharing(deck)),
    );

Future<void> openPreviewCardScreen(
  BuildContext context, {
  @required String deckKey,
  @required String cardKey,
}) =>
    Navigator.pushNamed(
      context,
      CardPreview.routeName,
      arguments: CardPreview.buildArguments(
        deckKey: deckKey,
        cardKey: cardKey,
      ),
    );

Future<void> openLinkAccountScreen(
  BuildContext context, {
  @required Auth auth,
}) =>
    Navigator.push(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: SignIn.linkAccountRouteName),
          builder: (_) => SignIn(
            SignInMode.linkToAccount,
            auth: auth,
          ),
        ));

Future<void> openNotificationSettingsScreen(BuildContext context) =>
    Navigator.pushNamed(
      context,
      NotificationSettings.routeName,
    );

Future<void> openAppSettingsScreen(BuildContext context) => Navigator.pushNamed(
      context,
      AppSettings.routeName,
    );

Future<void> openCardsFontSizeSettingsScreen(BuildContext context) =>
    Navigator.pushNamed(
      context,
      CardsFontSize.routeName,
    );

// Observer that notifies RouteAware routes about the changes
RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();
