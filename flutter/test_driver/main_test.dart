import 'package:delern_flutter/l10n/app_localizations.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';
import 'package:test/test.dart';

import 'commands.dart';

// This is not production code, and also, debugPrint() is not available outside
// Flutter framework.
// ignore_for_file: avoid_print

void main() {
  const timeoutDuration = Duration(seconds: 15);

  group('main test', () {
    FlutterDriver driver;
    AppLocalizations localizations;

    Future<void> tapDialogButton(String text) =>
        driver.tap(find.text(text.toUpperCase()));

    Future<void> expectCard(String front, String back) async {
      // TODO(ksheremet): getText doesn't work with TextSpan which is used
      // in Markdown text https://github.com/flutter/flutter/issues/62489.
      //await driver.getText(find.text('front1'))

      final card =
          await driver.getWidgetDiagnostics(find.byType('FlipCardWidget'));

      final properties = List<Map<String, dynamic>>.from(
        // ignore: avoid_as
        card['properties'] as Iterable<dynamic>,
      );

      expect(
        properties.firstWhere((p) => p['name'] == 'front')['value'],
        front,
      );
      expect(
        properties.firstWhere((p) => p['name'] == 'back')['value'],
        back,
      );
    }

    Future<void> fillInAndAddCard(String front, String back) async {
      // Wait until the message about card added disappears.
      await driver.waitForAbsent(find.text(localizations.cardAddedUserMessage),
          timeout: timeoutDuration);

      final frontInput = find.byValueKey('frontCardInput');
      await driver.waitFor(frontInput, timeout: timeoutDuration);
      await driver.enterText(front);

      await driver.tap(find.byValueKey('backCardInput'),
          timeout: timeoutDuration);
      await driver.enterText(back);

      for (var saveAttempt = 0;; ++saveAttempt) {
        await driver.tap(find.byTooltip(localizations.addCardTooltip),
            timeout: timeoutDuration);

        try {
          await driver.waitFor(find.text(localizations.cardAddedUserMessage),
              timeout: timeoutDuration);
          break;
        } catch (e) {
          print('Save attempt $saveAttempt: $e');
          if (saveAttempt < 3) {
            print('Retrying...');
          } else {
            rethrow;
          }
        }
      }
    }

    Future<void> answerCard({
      @required String expectFront,
      @required String expectBack,
      @required bool knows,
    }) async {
      await expectCard(expectFront, expectBack);
      await driver.tap(find.byType('Card'));
      await driver.tap(find.byTooltip(knows
          ? localizations.knowCardTooltip
          : localizations.doNotKnowCardTooltip));
    }

    setUpAll(() async {
      driver = await FlutterDriver.connect();
      localizations = const AppLocalizations();
      await driver.waitUntilFirstFrameRasterized();
    });

    tearDownAll(() async {
      unawaited(driver?.close());
    });

    test('Sign in anonymously', () async {
      final button = find.text(localizations.continueAnonymously.toUpperCase());
      await driver.waitFor(button);
      await driver.tap(button);
    });

    test('Create a deck', () async {
      final fab = find.byType('FloatingActionButton');
      await driver.waitFor(fab, timeout: timeoutDuration);
      await driver.tap(fab);

      final add = find.text(localizations.add.toUpperCase());
      await driver.waitFor(add);
      await driver.enterText('My Test Deck');
      await driver.waitFor(find.text('My Test Deck'));
      // When text was entered business logic needs some time to enable
      // "Add" button. Otherwise disabled button will be clicked and test fails.
      await Future<void>.delayed(const Duration(seconds: 1));
      await driver.tap(add, timeout: timeoutDuration);
    });

    test('Add 2 cards to the deck', () async {
      await fillInAndAddCard('front1 #all-cards #card12', 'back1');
      await fillInAndAddCard('front2 #all-cards #card12 #card23', 'back2');

      // Make some changes without saving them.
      await driver.enterText('something');

      // Tapping back should trigger a confirmation dialog for saving changes.
      await driver.tap(find.pageBack());
      await driver.waitFor(find.text(localizations.continueEditingQuestion));
      // Tapping Back "physical" button while the dialog is shown should be
      // ignored, but we can't test it because Flutter Driver does not have that
      // functionality (probably due to Back button not present on iOS devices).
      // Dismiss the confirmation dialog.
      await tapDialogButton(localizations.discard);
    });

    test('Add 2 more cards, 1 of them without #all-cards tag', () async {
      // Swipe right.
      await driver.scroll(
        find.text('My Test Deck'),
        (await driver.getWindow()).width / 2,
        0,
        const Duration(milliseconds: 500),
      );
      await driver.tap(find.byType('FloatingActionButton'));
      await fillInAndAddCard('front3 #all-cards #card23', 'back3');
      await fillInAndAddCard('front4', 'back4');
      // Back to the list of cards.
      await driver.tap(find.pageBack());
      // Back to the list of decks.
      await driver.tap(find.pageBack());
    });

    test('Learn 3 cards (interval learning)', () async {
      await driver.tap(find.text('My Test Deck'));
      await driver.tap(find.text('#all-cards'));
      await driver.tap(find.byTooltip(localizations.intervalLearningTooltip));

      await answerCard(
        expectFront: 'front1',
        expectBack: 'back1',
        knows: true,
      );
      await answerCard(
        expectFront: 'front2',
        expectBack: 'back2',
        knows: false,
      );
      await answerCard(
        expectFront: 'front3',
        expectBack: 'back3',
        knows: false,
      );
      // At this point the learning screen should automatically close because
      // there are no more cards to learn.
    });

    test('Delete 2 cards', () async {
      // Swipe right.
      await driver.scroll(
        find.text('My Test Deck'),
        (await driver.getWindow()).width / 2,
        0,
        const Duration(milliseconds: 500),
      );
      await driver.tap(find.text('front3'));
      await driver.tap(find.byTooltip(localizations.deleteCardTooltip));
      await tapDialogButton(localizations.delete);
      await driver.tap(find.pageBack());

      print('Deleting 2nd card');
      await driver.tap(find.text('My Test Deck'));
      await driver.tap(find.byTooltip(localizations.intervalLearningTooltip));
      // Since we replied "does no know" to front2, it should be the first in
      // the queue. But before that, dismiss the "learn beyond horizon" dialog.
      await tapDialogButton(localizations.yes);
      // Menu does not have text, use tooltip to find it.
      await driver.tap(find.byTooltip(localizations.menuTooltip));
      await driver.tap(find.text(localizations.delete));
      // And once again in the confirmation dialog.
      await tapDialogButton(localizations.delete);
      // Since we earlier confirmed learning beyond horizon, the learning screen
      // will not close automatically.
      await driver.tap(find.pageBack());
    });

    test('Learn one card (view learning)', () async {
      await driver.tap(find.text('My Test Deck'));
      // #all-cards tag selection must be preserved.
      await driver.tap(find.byTooltip(localizations.viewLearningTooltip));
      await driver.waitFor(find.text('(1/1) My Test Deck'));

      // Due to reshuffling when postponing cards, front1 may have been deleted.
      // TODO(dotdoom): deflake this test.
      await expectCard('front1', 'back1');

      await driver.tap(find.byType('Card'));
      await driver.tap(find.byTooltip(localizations.shuffleTooltip));
      await driver.waitFor(find.text('(1/1) My Test Deck'));
      await driver.tap(find.byType('Card'));

      await expectCard('front1', 'back1');
      await driver.tap(find.pageBack());
    });

    test('Refresh decks', () async {
      // Pull down.
      await driver.scroll(
        find.byType('ListView'),
        0,
        (await driver.getWindow()).height / 2,
        const Duration(milliseconds: 500),
      );
      await driver.waitFor(find.text(localizations.noUpdates));
    });

    test('Learn last card', () async {
      await driver.tap(find.text('My Test Deck'));
      // Remove the tag selection, which should reveal the 4th card.
      await driver.tap(find.text('#all-cards'));
      await driver.tap(find.byTooltip(localizations.intervalLearningTooltip));
      await answerCard(
        expectFront: 'front4',
        expectBack: 'back4',
        knows: false,
      );
      // At this point the learning screen should automatically close because
      // there are no more cards to learn.
    });

    test('Delete deck', () async {
      // Swipe right.
      await driver.scroll(
        find.text('My Test Deck'),
        -(await driver.getWindow()).width / 2,
        0,
        const Duration(milliseconds: 500),
      );
      await tapDialogButton(localizations.delete);
      await driver.waitFor(find.text(localizations.deckDeletedUserMessage));
      await driver.waitFor(find.text(localizations.emptyDecksList));
    });
  });
}
