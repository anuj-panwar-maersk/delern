import 'dart:async';
import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/remote/analytics.dart';
import 'package:delern_flutter/remote/app_config.dart';
import 'package:delern_flutter/view_models/edit_deck_bloc.dart';
import 'package:delern_flutter/view_models/notifications_view_model.dart';
import 'package:delern_flutter/views/base/screen_bloc_view.dart';
import 'package:delern_flutter/views/card_list/card_list_menu.dart';
import 'package:delern_flutter/views/card_list/learning_section/learning_buttons_section.dart';
import 'package:delern_flutter/views/card_list/scroll_to_beginning_list_widget.dart';
import 'package:delern_flutter/views/helpers/arrow_to_fab_widget.dart';
import 'package:delern_flutter/views/helpers/auth_widget.dart';
import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:delern_flutter/views/helpers/edit_delete_dismissible_widget.dart';
import 'package:delern_flutter/views/helpers/empty_list_message_widget.dart';
import 'package:delern_flutter/views/helpers/list_accessor_widget.dart';
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/routes.dart';
import 'package:delern_flutter/views/helpers/search_bar_widget.dart';
import 'package:delern_flutter/views/helpers/stream_with_value_builder.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:delern_flutter/views/helpers/text_overflow_ellipsis_widget.dart';
import 'package:delern_flutter/views/helpers/user_messages.dart';
import 'package:delern_flutter/views/notifications/notification_schedule_dialog.dart';
import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';

const int _kUpButtonVisibleRow = 20;

class CardList extends StatefulWidget {
  static const routeName = '/cards';

  static Map<String, String> buildArguments({
    @required String deckKey,
  }) =>
      {
        'deckKey': deckKey,
      };

  const CardList() : super();

  @override
  _CardListState createState() => _CardListState();
}

// Example taken from documentation:
// ignore: prefer_mixin
class _CardListState extends State<CardList> with RouteAware {
  final TextEditingController _deckNameController = TextEditingController();
  DeckModel _currentDeckState;
  GlobalKey fabKey = GlobalKey();

  @override
  void didChangeDependencies() {
    // didChangeDependencies might be called many times. Unsubscribe in case
    // it was subscribed before
    routeObserver?.unsubscribe(this);
    // ignore: avoid_as
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // _scheduleNotifications calls showDialog, and we can't push a route while
    // popping a route.
    scheduleMicrotask(_scheduleNotifications);
  }

  Future<void> _scheduleNotifications() async {
    final user = CurrentUserWidget.of(context).user;

    if (!context.read<LocalNotifications>().isNotificationScheduled) {
      // Show screen to schedule notifications if cards are created
      final decks = user.decks.value;

      final totalCards = decks
          .map((d) => d.cards.value)
          .fold<int>(0, (previous, element) => previous + element.length);

      if (totalCards >= AppConfig.instance.totalCardsForNotificationSchedule) {
        final toSchedule = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => NotificationScheduleDialog(),
        );
        if (toSchedule == true) {
          await context
              .read<LocalNotifications>()
              .scheduleDefaultNotifications();
        }
        context.read<LocalNotifications>().showNotificationSuggestion();
        unawaited(logScheduleNotifications(
          totalCards: totalCards,
          isScheduled: toSchedule,
        ));
      }
    }
  }

  void _searchTextChanged(EditDeckBloc bloc, String input) {
    if (input == null) {
      bloc.filter = null;
      return;
    }
    input = input.toLowerCase();
    bloc.filter = (c) =>
        c.front.toLowerCase().contains(input) ||
        c.back.toLowerCase().contains(input);
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        // https://github.com/dasfoo/delern/issues/1386
        // ignore: avoid_as
        ModalRoute.of(context).settings.arguments as Map<String, String>;
    return ScreenBlocView<EditDeckBloc>(
      blocBuilder: (user) {
        final bloc = EditDeckBloc(
          deckKey: arguments['deckKey'],
          user: user,
        );
        _currentDeckState = bloc.deck;
        _deckNameController.text = _currentDeckState.name;
        bloc.doDeckChanged.listen((deck) {
          setState(() {
            _currentDeckState = deck;
          });
        });
        bloc.doEditCard.listen((card) {
          openEditCardScreen(
            context,
            deckKey: card.deckKey,
            cardKey: card.key,
          );
        });

        return bloc;
      },
      appBarBuilder: (bloc) => SearchBarWidget(
        title: bloc.deck.name,
        search: (input) => _searchTextChanged(bloc, input),
        actions: _buildActions(bloc),
      ),
      bodyBuilder: (bloc) => Column(
        children: <Widget>[
          _SymmetricHorizontalPadding(
              child: LearningButtonsSection(deck: _currentDeckState)),
          _SymmetricHorizontalPadding(
              child: _CardsInDeckCounterWidget(bloc: bloc)),
          const SizedBox(height: 4),
          const Divider(
            height: 0,
          ),
          Expanded(
            child: _SymmetricHorizontalPadding(
              child: _buildCardList(bloc),
            ),
          ),
        ],
      ),
      floatingActionButtonBuilder: _buildAddCard,
    );
  }

  List<Widget> _buildActions(EditDeckBloc bloc) => <Widget>[
        CardListPopupMenu(
          bloc: bloc,
          deck: _currentDeckState,
        )
      ];

  Widget _buildCardList(EditDeckBloc bloc) {
    final cardVerticalPadding =
        MediaQuery.of(context).size.height * app_styles.kItemListPaddingRatio;
    return ScrollToBeginningListWidget(
      builder: (controller) => ListAccessorWidget<CardModel>(
        list: bloc.list,
        itemBuilder: (context, item, index) {
          final card = _buildCardItem(item, cardVerticalPadding, bloc);
          if (index == 0) {
            return Padding(
              // Space between 1st element and border must be 2 times indent
              // between elements. Space between 2 elem = 2*cardVerticalPadding
              // 1st indent is at the end of 1st elem, 2nd indent is at
              // the beginning 2d element. 2 times more == 4*cardVerticalPadding
              // we have already 1 indent at the beginning. Therefore
              // we need 3 extra
              padding: EdgeInsets.only(top: 3 * cardVerticalPadding),
              child: card,
            );
          } else {
            return card;
          }
        },
        emptyMessageBuilder: () => ArrowToFloatingActionButtonWidget(
          fabKey: fabKey,
          child: EmptyListMessageWidget(context.l.emptyCardsList),
        ),
        controller: controller,
      ),
      minItemHeight: app_styles.kMinItemHeight + 2 * cardVerticalPadding,
      upButtonVisibleRow: _kUpButtonVisibleRow,
    );
  }

  Column _buildCardItem(
    CardModel item,
    double verticalPadding,
    EditDeckBloc bloc,
  ) =>
      Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: verticalPadding),
            child: CardItemWidget(
              card: item,
              deck: _currentDeckState,
              bloc: bloc,
            ),
          ),
        ],
      );

  Widget _buildAddCard(EditDeckBloc bloc) => Builder(
        builder: (context) => FloatingActionButton(
          tooltip: context.l.addCardTooltip,
          key: fabKey,
          onPressed: () {
            if (_currentDeckState.access != AccessType.read) {
              openNewCardScreen(context, deckKey: _currentDeckState.key);
            } else {
              UserMessages.showMessage(Scaffold.of(context),
                  context.l.noAddingWithReadAccessUserMessage);
            }
          },
          child: const Icon(Icons.add),
        ),
      );
}

const double _kCardBorderPadding = 16;
const double _kFrontBackTextPadding = 5;

class CardItemWidget extends StatelessWidget {
  final CardModel card;
  final DeckModel deck;
  final EditDeckBloc bloc;

  const CardItemWidget({
    @required this.card,
    @required this.deck,
    @required this.bloc,
  })  : assert(card != null),
        assert(deck != null),
        assert(bloc != null);

  @override
  Widget build(BuildContext context) {
    final minHeight = max(
        MediaQuery.of(context).size.height * app_styles.kItemListHeightRatio,
        app_styles.kMinItemHeight);
    final iconSize = max(minHeight * 0.5, app_styles.kMinIconHeight);
    return Row(
      children: <Widget>[
        Expanded(
          child: EditDeleteDismissible(
            key: Key(card.key),
            iconSize: iconSize,
            onEdit: (_) => bloc.onEditCardIntention.add(card),
            child: Material(
              elevation: app_styles.kItemElevation,
              borderRadius: BorderRadius.circular(4),
              child: InkWell(
                splashColor: Theme.of(context).splashColor,
                onTap: () => openPreviewCardScreen(
                  context,
                  deckKey: deck.key,
                  cardKey: card.key,
                ),
                child: Container(
                  padding: const EdgeInsets.all(_kCardBorderPadding),
                  decoration: BoxDecoration(
                    color: specifyCardColors(deck.type, card.back)
                        .defaultBackground,
                    borderRadius: BorderRadius.circular(4),
                  ),

                  // Use row to expand content to all available space
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CardSideWidget(
                              imageUrl: card.frontImagesUri.isNotEmpty
                                  ? card.frontImagesUri[0]
                                  : null,
                              text: card.frontWithoutTags,
                            ),
                            const Divider(),
                            const SizedBox(height: _kFrontBackTextPadding),
                            CardSideWidget(
                              imageUrl: card.backImagesUri.isNotEmpty
                                  ? card.backImagesUri[0]
                                  : null,
                              text: card.back,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

@immutable
class CardSideWidget extends StatelessWidget {
  final String imageUrl;
  final String text;

  const CardSideWidget({@required this.imageUrl, @required this.text});

  @override
  Widget build(BuildContext context) {
    final minHeight = max(
        MediaQuery.of(context).size.height * app_styles.kItemListHeightRatio,
        app_styles.kMinItemHeight);
    final primaryFontSize =
        max(minHeight * 0.25, app_styles.kMinPrimaryTextSize);
    final primaryTextStyle =
        app_styles.editCardPrimaryText.copyWith(fontSize: primaryFontSize);
    return Row(
      children: [
        if (imageUrl != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CachedNetworkImage(
                height: MediaQuery.of(context).size.height * 0.08,
                imageUrl: imageUrl),
          ),
        TextOverflowEllipsisWidget(
          textDetails: text ?? '',
          textStyle: primaryTextStyle,
        ),
      ],
    );
  }
}

@immutable
class _SymmetricHorizontalPadding extends StatelessWidget {
  final Widget child;

  const _SymmetricHorizontalPadding({@required this.child});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.025),
        child: child,
      );
}

class _CardsInDeckCounterWidget extends StatelessWidget {
  final EditDeckBloc bloc;

  const _CardsInDeckCounterWidget({@required this.bloc});

  @override
  Widget build(BuildContext context) =>
      buildStreamBuilderWithValue<BuiltList<CardModel>>(
          streamWithValue: bloc.list,
          builder: (context, snapshot) => Row(
                children: <Widget>[
                  Text(
                    context.l.numberOfCards(snapshot.data.length),
                    style: app_styles.secondaryText.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ));
}
