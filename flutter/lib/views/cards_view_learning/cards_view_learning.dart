import 'package:built_collection/built_collection.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/view_models/cards_view_learning_bloc.dart';
import 'package:delern_flutter/views/base/screen_bloc_view.dart';
import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:delern_flutter/views/helpers/flip_card_widget.dart';
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/progress_indicator_widget.dart';
import 'package:delern_flutter/views/helpers/stream_with_value_builder.dart';
import 'package:delern_flutter/views/helpers/text_overflow_ellipsis_widget.dart';
import 'package:flutter/material.dart';

const _kCardPageRatio = 0.9;
const double _kCardPadding = 8;

class CardsViewLearning extends StatefulWidget {
  static const routeName = '/learn-view';

  const CardsViewLearning();

  static Map<String, dynamic> buildArguments({
    @required String deckKey,
    Iterable<String> tags,
  }) =>
      <String, dynamic>{
        'deckKey': deckKey,
        'tags': tags,
      };

  @override
  _CardsViewLearningState createState() => _CardsViewLearningState();
}

class _CardsViewLearningState extends State<CardsViewLearning>
    with TickerProviderStateMixin {
  final PageController _controller = PageController(viewportFraction: 0.7);
  int _currentCard = 0;

  @override
  void initState() {
    _controller.addListener(() {
      if (_controller.page.floor() != _currentCard) {
        setState(() {
          _currentCard = _controller.page.floor();
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => ScreenBlocView<CardsViewLearningBloc>(
        blocBuilder: (user) {
          final arguments =
              // https://github.com/dasfoo/delern/issues/1386
              // ignore: avoid_as
              ModalRoute.of(context).settings.arguments as Map<String, dynamic>;

          return CardsViewLearningBloc(
            // https://github.com/dasfoo/delern/issues/1386
            // ignore: avoid_as
            deck: user.decks.getItem(arguments['deckKey'] as String),
            user: user,
            tags: BuiltSet<String>.of(
              // https://github.com/dasfoo/delern/issues/1386
              // ignore: avoid_as
              (arguments['tags'] as Iterable<String>) ?? [],
            ),
          );
        },
        // TODO(ksheremet): Refactor: listening the same stream;
        //  when setState called, the whole tree will be rebuild. The aim is
        // to rebuild widgets which are needed to be rebuild
        appBarBuilder: (bloc) => AppBar(
          title: buildStreamBuilderWithValue<BuiltList<CardModel>>(
              streamWithValue: bloc.doSetCardsList,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return TextOverflowEllipsisWidget(
                    textDetails:
                        '(${_currentCard + 1}/${snapshot.data.length}) '
                        '${bloc.deck.value.name}',
                  );
                }
                return TextOverflowEllipsisWidget(
                  textDetails: bloc.deck.value.name,
                );
              }),
          actions: <Widget>[
            buildStreamBuilderWithValue<BuiltList<CardModel>>(
                streamWithValue: bloc.doSetCardsList,
                builder: (context, snapshot) => IconButton(
                      icon: const Icon(Icons.shuffle),
                      tooltip: context.l.shuffleTooltip,
                      onPressed: snapshot.hasData
                          ? (() {
                              bloc.onShuffleCards.add(null);
                            })
                          : null,
                    )),
          ],
        ),
        bodyBuilder: (bloc) =>
            buildStreamBuilderWithValue<BuiltList<CardModel>>(
          streamWithValue: bloc.doSetCardsList,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const ProgressIndicatorWidget();
            } else {
              return PageView.builder(
                  controller: _controller,
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) => AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          // Workaround for:
                          // https://github.com/flutter/flutter/issues/35198.
                          var page = index.toDouble();
                          if (_controller.position.minScrollExtent != null &&
                              _controller.position.maxScrollExtent != null) {
                            page = _controller.page;
                          }

                          final value = (1 - ((page - index).abs() * 0.3))
                              .clamp(0.0, 1.0);
                          final transformValue =
                              Curves.easeOut.transform(value.toDouble());
                          return Center(
                              child: SizedBox(
                                  width: transformValue *
                                      MediaQuery.of(context).size.width *
                                      _kCardPageRatio,
                                  child: child));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(_kCardPadding),
                          child: FlipCardWidget(
                            front: snapshot.data[index].frontWithoutTags,
                            frontImages: snapshot.data[index].frontImagesUri,
                            back: snapshot.data[index].back,
                            backImages: snapshot.data[index].backImagesUri,
                            tags: snapshot.data[index].tags,
                            colors: specifyCardColors(
                              bloc.deck.value.type,
                              snapshot.data[index].back,
                              cardColorValue: snapshot.data[index].color,
                            ),
                            key: ValueKey(snapshot.data[index].key),
                          ),
                        ),
                      ));
            }
          },
        ),
      );
}
