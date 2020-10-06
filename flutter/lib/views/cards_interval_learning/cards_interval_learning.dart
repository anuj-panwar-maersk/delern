import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:delern_flutter/models/base/clock.dart';
import 'package:delern_flutter/models/base/stream_with_value.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/scheduled_card_model.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/remote/analytics/analytics.dart';
import 'package:delern_flutter/views/cards_interval_learning/card_actions_menu_widget.dart';
import 'package:delern_flutter/views/cards_interval_learning/card_answer_buttons_widget.dart';
import 'package:delern_flutter/views/helpers/auth_widget.dart';
import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:delern_flutter/views/helpers/flip_card_widget.dart';
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/progress_indicator_widget.dart';
import 'package:delern_flutter/views/helpers/save_updates_dialog.dart';
import 'package:delern_flutter/views/helpers/stream_with_value_builder.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:delern_flutter/views/helpers/text_overflow_ellipsis_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';

const _kCardPaddingRatio = 0.07;

class CardsIntervalLearning extends StatefulWidget {
  static const routeName = '/learn-interval';

  const CardsIntervalLearning();

  static Map<String, dynamic> buildArguments({
    @required String deckKey,
    Iterable<String> tags,
  }) =>
      <String, dynamic>{
        'deckKey': deckKey,
        'tags': tags,
      };

  @override
  State<StatefulWidget> createState() => CardsIntervalLearningState();
}

class CardsIntervalLearningState extends State<CardsIntervalLearning> {
  /// Whether the card on the display is scheduled for the time in future.
  /// Implies that the user has been asked to learn cards beyond current date,
  /// and replied positively.
  bool _learnBeyondHorizon = false;

  User _user;
  StreamWithValue<DeckModel> _deck;

  StreamWithValue<ScheduledCardModel> _nextScheduledCard;
  final _currentCard = ValueNotifier<CardModel>(null);
  Sink<String> _answers;
  final _answersCount = ValueNotifier<int>(0);

  final _showReplyButtons = ValueNotifier<bool>(false);

  Completer<bool> _cardAnswerTrace;

  @override
  void didChangeDependencies() {
    final user = CurrentUserWidget.of(context).user;
    if (_user != user) {
      _user = user;
      _answers?.close();

      final arguments =
          // https://github.com/dasfoo/delern/issues/1386
          // ignore: avoid_as
          ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
      // https://github.com/dasfoo/delern/issues/1386
      // ignore: avoid_as
      _deck = _user.decks.getItem(arguments['deckKey'] as String);

      // Start sync in background (to add new cards).
      _user.syncScheduledCards(_deck.value);

      _nextScheduledCard =
          StreamWithLatestValue(_deck.value.startLearningSession(
        answers: (_answers = StreamController<String>()).stream,
        tags: BuiltSet<String>.of(
          // https://github.com/dasfoo/delern/issues/1386
          // ignore: avoid_as
          (arguments['tags'] as Iterable<String>) ?? [],
        ),
      ));
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _answers.close();
    if (_cardAnswerTrace?.isCompleted == false) {
      // User has looked at a card but left the screen before answering.
      _cardAnswerTrace.complete(null);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DataStreamWithValueBuilder<DeckModel>(
      streamWithValue: _deck,
      builder: (context, deck) => Scaffold(
          appBar: AppBar(
            title: TextOverflowEllipsisWidget(
              textDetails: deck.name,
            ),
            actions: <Widget>[
              ValueListenableBuilder<CardModel>(
                valueListenable: _currentCard,
                builder: (context, card, _) => card == null
                    ? const ProgressIndicatorWidget()
                    : CardActionsMenuWidget(
                        user: _user,
                        deck: deck,
                        card: card,
                      ),
              ),
            ],
          ),
          body: DataStreamWithValueBuilder<ScheduledCardModel>(
              streamWithValue: _nextScheduledCard,
              onData: (scheduledCard) async {
                if (await _promptBeyondHorizon(scheduledCard)) {
                  _cardAnswerTrace =
                      startTrace('interval_learning_card_answer');
                }
              },
              builder: (context, scheduledCard) => Column(
                    children: <Widget>[
                      Expanded(
                          child: Padding(
                        padding: MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? EdgeInsets.all(MediaQuery.of(context).size.width *
                                _kCardPaddingRatio)
                            : EdgeInsets.only(
                                top: 10,
                                left: MediaQuery.of(context).size.width *
                                    _kCardPaddingRatio,
                                right: MediaQuery.of(context).size.width *
                                    _kCardPaddingRatio),
                        child: DataStreamWithValueBuilder<CardModel>(
                            streamWithValue:
                                deck.cards.getItem(scheduledCard.key),
                            onData: (newValue) {
                              if (newValue == null) {
                                _user.cleanupOrphanedScheduledCard(
                                    scheduledCard);
                                _cardAnswerTrace.complete(null);
                                _answers.add(scheduledCard.key);
                              }
                              _currentCard.value = newValue;
                            },
                            builder: (context, card) => FlipCardWidget(
                                  front: card.frontWithoutTags,
                                  frontImages: card.frontImagesUri,
                                  back: card.back,
                                  backImages: card.backImagesUri,
                                  tags: card.tags,
                                  colors:
                                      specifyCardColors(deck.type, card.back),
                                  hasBeenFlipped: _showReplyButtons,
                                  key: ValueKey(card.key),
                                )),
                      )),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _showReplyButtons,
                          builder: (context, showReplyButtons, child) =>
                              Visibility(
                            visible: showReplyButtons,
                            maintainSize: true,
                            // Required when maintainSize is set.
                            maintainAnimation: true,
                            maintainState: true,
                            child: child,
                          ),
                          child: CardAnswerButtonsWidget(
                            onAnswer: (knows) {
                              _cardAnswerTrace.complete(knows);
                              // Update database in background for fast user
                              // experience.
                              _user.learnCard(
                                unansweredScheduledCard: scheduledCard,
                                knows: knows,
                              );
                              _answers.add(scheduledCard.key);
                              ++_answersCount.value;

                              if (_answersCount.value == 1) {
                                unawaited(context
                                    .read<Analytics>()
                                    .logStartLearning(deck.key));
                              }
                              unawaited(
                                  context.read<Analytics>().logCardResponse(
                                        deckId: deck.key,
                                        knows: knows,
                                        previousLevel: scheduledCard.level,
                                      ));
                            },
                          ),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          // Use SafeArea to indent the child by the amount
                          // necessary to avoid The Notch on the iPhone X,
                          // or other similar creative physical features of
                          // the display.
                          SafeArea(
                            minimum: const EdgeInsets.only(left: 8, bottom: 8),
                            child: ValueListenableBuilder<int>(
                              valueListenable: _answersCount,
                              builder: (context, answersCount, _) => Text(
                                context.l.answeredCards(answersCount),
                                style: app_styles.secondaryText,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ))));

  Future<bool> _promptBeyondHorizon(ScheduledCardModel scheduledCard) async {
    if (!_learnBeyondHorizon && scheduledCard.repeatAt.isAfter(clock.now())) {
      if (_answersCount.value == 0) {
        _learnBeyondHorizon = await showSaveUpdatesDialog(
                context: context,
                changesQuestion: context.l.continueLearningQuestion(
                    DateFormat.yMMMd().add_jm().format(scheduledCard.repeatAt)),
                noAnswer: context.l.no,
                yesAnswer: context.l.yes) ==
            true;
      }
      if (!_learnBeyondHorizon) {
        Navigator.of(context).pop();
        return false;
      }
    }
    return true;
  }
}
