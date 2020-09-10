import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/views/card_create_update/card_create_update.dart';
import 'package:delern_flutter/views/card_preview/card_preview.dart';
import 'package:delern_flutter/views/cards_interval_learning/cards_interval_learning.dart';
import 'package:delern_flutter/views/cards_view_learning/cards_view_learning.dart';
import 'package:delern_flutter/views/deck_sharing/deck_sharing.dart';
import 'package:delern_flutter/views/edit_deck/edit_deck.dart';
import 'package:delern_flutter/views/sign_in/sign_in.dart';
import 'package:delern_flutter/views/support_dev/support_development.dart';
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
  EditDeck.routeName: (_) => const EditDeck(),
  CardCreateUpdate.routeNameNew: (_) => const CardCreateUpdate(),
  CardCreateUpdate.routeNameEdit: (_) => const CardCreateUpdate(),
  CardPreview.routeName: (_) => const CardPreview(),
  CardsIntervalLearning.routeName: (_) => const CardsIntervalLearning(),
  CardsViewLearning.routeName: (_) => const CardsViewLearning(),
};

Future<void> openEditDeckScreen(
  BuildContext context, {
  @required String deckKey,
}) =>
    Navigator.pushNamed(
      context,
      EditDeck.routeName,
      arguments: EditDeck.buildArguments(deckKey: deckKey),
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
}) =>
    Navigator.pushNamed(
      context,
      CardCreateUpdate.routeNameNew,
      arguments: CardCreateUpdate.buildArguments(deckKey: deckKey),
    );

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

Future<void> openSignInScreen(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(
      settings: const RouteSettings(name: SignIn.routeName),
      builder: (_) => const SignIn(),
    ));
