import 'package:built_collection/built_collection.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/remote/analytics/analytics.dart';
import 'package:delern_flutter/views/card_list/learning_section/learning_method_widget.dart';
import 'package:delern_flutter/views/helpers/auth_widget.dart';
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/progress_indicator_widget.dart';
import 'package:delern_flutter/views/helpers/routes.dart';
import 'package:delern_flutter/views/helpers/stream_with_value_builder.dart';
import 'package:delern_flutter/views/helpers/tags_widget.dart';
import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';

@immutable
class LearningButtonsSection extends StatelessWidget {
  final DeckModel deck;
  final ValueNotifier<BuiltSet<String>> _tagSelection;

  LearningButtonsSection({@required this.deck})
      : _tagSelection = ValueNotifier<BuiltSet<String>>(
          deck.latestTagSelection?.isEmpty == false
              ? deck.latestTagSelection
              : BuiltSet<String>(),
        );

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          buildStreamBuilderWithValue<BuiltSet<String>>(
            streamWithValue: deck.tags,
            builder: (_, snapshot) => snapshot.hasData
                ? TagsWidget(
                    tags: snapshot.data,
                    selection: _tagSelection,
                  )
                : const ProgressIndicatorWidget(),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.23,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Tooltip(
                      message: context.l.intervalLearningTooltip,
                      child: LearningMethodWidget(
                        name: context.l.intervalLearning,
                        tooltip: context.l.intervalLearningTooltip,
                        image:
                            Image.asset('images/interval_learning_image.webp'),
                        onTap: () {
                          final updatedDeck = deck.rebuild((builder) {
                            builder.latestTagSelection
                                .replace(_tagSelection.value);
                          });
                          if (updatedDeck != deck) {
                            CurrentUserWidget.of(context)
                                .user
                                .updateDeck(deck: updatedDeck);
                          }
                          unawaited(
                              Provider.of<Analytics>(context, listen: false)
                                  .logIntervalLearningEvent());
                          unawaited(
                              Provider.of<Analytics>(context, listen: false)
                                  .logStartLearning(deck.key));
                          openLearnCardIntervalScreen(
                            context,
                            deckKey: deck.key,
                            tags: _tagSelection.value,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Tooltip(
                      message: context.l.viewLearningTooltip,
                      child: LearningMethodWidget(
                        name: context.l.viewLearning,
                        tooltip: context.l.viewLearningTooltip,
                        image:
                            Image.asset('images/viewing_learning_image.webp'),
                        onTap: () {
                          // Use Provider.of instead of context because
                          // it interfere with localization context (context.l)
                          unawaited(
                              Provider.of<Analytics>(context, listen: false)
                                  .logViewLearningEvent());
                          unawaited(
                              Provider.of<Analytics>(context, listen: false)
                                  .logStartLearning(deck.key));
                          openLearnCardViewScreen(
                            context,
                            deckKey: deck.key,
                            tags: _tagSelection.value,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}
