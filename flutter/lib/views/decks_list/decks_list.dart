import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:delern_flutter/main.dart';
import 'package:delern_flutter/models/base/stream_with_value.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/remote/analytics.dart';
import 'package:delern_flutter/remote/app_config.dart';
import 'package:delern_flutter/view_models/decks_list_bloc.dart';
import 'package:delern_flutter/view_models/notifications_view_model.dart';
import 'package:delern_flutter/views/decks_list/create_deck_widget.dart';
import 'package:delern_flutter/views/decks_list/deck_menu.dart';
import 'package:delern_flutter/views/decks_list/learning_method_widget.dart';
import 'package:delern_flutter/views/decks_list/navigation_drawer.dart';
import 'package:delern_flutter/views/helpers/arrow_to_fab_widget.dart';
import 'package:delern_flutter/views/helpers/auth_widget.dart';
import 'package:delern_flutter/views/helpers/edit_delete_dismissible_widget.dart';
import 'package:delern_flutter/views/helpers/empty_list_message_widget.dart';
import 'package:delern_flutter/views/helpers/list_accessor_widget.dart';
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/progress_indicator_widget.dart';
import 'package:delern_flutter/views/helpers/routes.dart';
import 'package:delern_flutter/views/helpers/save_updates_dialog.dart';
import 'package:delern_flutter/views/helpers/search_bar_widget.dart';
import 'package:delern_flutter/views/helpers/stream_with_value_builder.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:delern_flutter/views/helpers/tags_widget.dart';
import 'package:delern_flutter/views/helpers/user_messages.dart';
import 'package:delern_flutter/views/notifications/notification_schedule_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';

class DecksList extends StatefulWidget {
  const DecksList();

  @override
  _DecksListState createState() => _DecksListState();
}

// Example taken from documentation:
// ignore: prefer_mixin
class _DecksListState extends State<DecksList> with RouteAware {
  // TODO(ksheremet): use ScreenBlocView to handle this bloc.
  DecksListBloc _bloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didPopNext() {
    // When user returned from adding cards or editing cards, check whether
    // user has enough cards to schedule notifications.
    _scheduleNotifications();
  }

  @override
  void didChangeDependencies() {
    // ignore: avoid_as
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);

    final user = CurrentUserWidget.of(context).user;
    if (_bloc?.user != user) {
      _bloc?.dispose();
      _bloc = DecksListBloc(user: user);
    }
    super.didChangeDependencies();
  }

  Future<void> _scheduleNotifications() async {
    final user = CurrentUserWidget.of(context).user;

    if (!context.read<LocalNotifications>().isNotificationScheduled) {
      // Show screen to schedule notifications if cards are created
      final decks = await user.decks.valueWithUpdates.first;

      final totalCards = await Stream<BuiltList<CardModel>>.fromFutures(
              decks.map((d) => d.cards.valueWithUpdates.first))
          .fold<int>(0, (previous, element) => previous + element.length);

      if (totalCards > AppConfig.instance.totalCardsForNotificationSchedule) {
        final toSchedule = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => NotificationScheduleDialog(),
        );
        if (toSchedule) {
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

  @override
  void dispose() {
    _bloc?.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  void setFilter(String input) {
    if (input == null) {
      _bloc.decksListFilter = null;
      return;
    }
    input = input.toLowerCase();
    _bloc.decksListFilter = (d) =>
        // Case insensitive filter
        d.name.toLowerCase().contains(input);
  }

  final _fabKey = GlobalKey();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        appBar: SearchBarWidget(
          title: context.l.listOFDecksScreenTitle,
          search: setFilter,
          leading: buildStreamBuilderWithValue<bool>(
              streamWithValue: _bloc.user.database.isOnline,
              builder: (context, snapshot) {
                final online = snapshot.data == true;
                return IconButton(
                  tooltip: online
                      ? context.l.profileTooltip
                      : context.l.offlineProfileTooltip,
                  icon: AnimatedCrossFade(
                    duration: const Duration(milliseconds: 500),
                    firstChild: const Icon(Icons.person),
                    secondChild: const Icon(Icons.offline_bolt,
                        color: Colors.amberAccent),
                    crossFadeState: online
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                  ),
                  onPressed: () => _scaffoldKey.currentState.openDrawer(),
                );
              }),
        ),
        drawer: const NavigationDrawer(),
        body: Column(
          children: <Widget>[
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final changesMade = (await Future.wait(_bloc.user.decks.value
                          .map((deck) => _bloc.user.syncScheduledCards(deck))))
                      .contains(true);
                  if (_scaffoldKey.currentState != null) {
                    UserMessages.showMessage(
                      _scaffoldKey.currentState,
                      changesMade
                          ? context.l.decksRefreshed
                          : context.l.noUpdates,
                    );
                  }
                },
                child: ListAccessorWidget<DeckModel>(
                  list: _bloc.decksList,
                  itemBuilder: (context, item, index) {
                    final itemHeight = max(
                        MediaQuery.of(context).size.height *
                            app_styles.kItemListHeightRatio,
                        app_styles.kMinItemHeight);
                    return Column(
                      children: <Widget>[
                        if (index == 0)
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: MediaQuery.of(context).size.height *
                                    app_styles.kItemListPaddingRatio *
                                    2),
                          ),
                        DeckListItemWidget(
                          deck: item,
                          bloc: _bloc,
                          minHeight: itemHeight,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: MediaQuery.of(context).size.height *
                                  app_styles.kItemListPaddingRatio),
                        ),
                        if (index == (_bloc.decksList.value.length - 1))
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: MediaQuery.of(context).size.height *
                                    app_styles.kItemListPaddingRatio),
                          ),
                      ],
                    );
                  },
                  emptyMessageBuilder: () => ArrowToFloatingActionButtonWidget(
                      fabKey: _fabKey,
                      child: EmptyListMessageWidget(context.l.emptyDecksList)),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: CreateDeckWidget(key: _fabKey, bloc: _bloc),
      );
}

class DeckListItemWidget extends StatelessWidget {
  final DeckModel deck;
  final DecksListBloc bloc;
  final double minHeight;

  const DeckListItemWidget({
    @required this.deck,
    @required this.bloc,
    @required this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    final emptyExpanded = Expanded(
      child: Container(
        color: Colors.transparent,
      ),
    );

    final iconSize = max(minHeight * 0.5, app_styles.kMinIconHeight);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        emptyExpanded,
        Expanded(
          flex: 8,
          child: EditDeleteDismissible(
            key: Key(deck.key),
            iconSize: iconSize,
            onDelete: _confirmAndDeleteDeck,
            onEdit: (context) {
              unawaited(logDeckEditSwipe(deck.key));
              unawaited(openEditDeckScreen(context, deckKey: deck.key));
            },
            child: Material(
              color: app_styles.kDeckItemColor,
              elevation: app_styles.kItemElevation,
              child: InkWell(
                onTap: () => _showLearningDialog(context),
                child: Row(
                  children: <Widget>[
                    _buildLeading(iconSize),
                    Expanded(child: _buildContent(context)),
                    _buildTrailing(iconSize),
                  ],
                ),
              ),
            ),
          ),
        ),
        emptyExpanded,
      ],
    );
  }

  Future<void> _showLearningDialog(BuildContext context) async {
    if (deck.cards.value.isEmpty) {
      // If deck is empty, open a screen with adding cards
      return openNewCardScreen(context, deckKey: deck.key);
    }

    final tagSelection = ValueNotifier<BuiltSet<String>>(
      deck.latestTagSelection?.isEmpty == false
          ? deck.latestTagSelection
          : BuiltSet<String>(),
    );
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      context.l.learning(deck.name),
                      // TODO(ksheremet): fix this to use non-deprecated value.
                      // ignore: deprecated_member_use
                      style: Theme.of(context).textTheme.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  buildStreamBuilderWithValue<BuiltSet<String>>(
                    streamWithValue: deck.tags,
                    builder: (_, snapshot) => snapshot.hasData
                        ? TagsWidget(
                            tags: snapshot.data,
                            selection: tagSelection,
                          )
                        : const ProgressIndicatorWidget(),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        LearningMethodWidget(
                          name: context.l.intervalLearning,
                          tooltip: context.l.intervalLearningTooltip,
                          icon: Icons.autorenew,
                          onTap: () {
                            final updatedDeck = deck.rebuild((builder) {
                              builder.latestTagSelection
                                  .replace(tagSelection.value);
                            });
                            if (updatedDeck != deck) {
                              bloc.user.updateDeck(deck: updatedDeck);
                            }

                            // Close dialog
                            Navigator.pop(context);
                            openLearnCardIntervalScreen(
                              context,
                              deckKey: deck.key,
                              tags: tagSelection.value,
                            );
                          },
                        ),
                        LearningMethodWidget(
                          name: context.l.viewLearning,
                          tooltip: context.l.viewLearningTooltip,
                          icon: Icons.remove_red_eye,
                          onTap: () {
                            // Close dialog
                            Navigator.pop(context);
                            openLearnCardViewScreen(
                              context,
                              deckKey: deck.key,
                              tags: tagSelection.value,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ));
  }

  Widget _buildContent(BuildContext context) {
    final primaryFontSize =
        max(minHeight * 0.25, app_styles.kMinPrimaryTextSize);
    final primaryTextStyle =
        app_styles.primaryText.copyWith(fontSize: primaryFontSize);
    final secondaryTextStyle = app_styles.secondaryText.copyWith(
        fontSize: primaryFontSize / 1.5,
        color: app_styles.kSecondaryTextDeckItemColor);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          deck.name,
          style: primaryTextStyle,
        ),
        buildStreamBuilderWithValue<int>(
          streamWithValue: deck.numberOfCardsDue,
          builder: (context, snapshot) => Text(
            context.l.cardsToLearnLabel(
              snapshot.data?.toString() ?? 'N/A',
              // TODO(ksheremet): Add StreamBuilder to get updates about all
              // cards
              deck.cards.value?.length?.toString() ?? 'N/A',
            ),
            style: secondaryTextStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildLeading(double size) => IconButton(
        padding: const EdgeInsets.all(app_styles.kIconDeckPadding),
        onPressed: null,
        icon: Icon(
          Icons.folder,
          color: app_styles.kIconColor,
        ),
        iconSize: size,
      );

  Widget _buildTrailing(double size) => DeckMenu(
        deck: deck,
        buttonSize: size,
        onDeleteDeck: _confirmAndDeleteDeck,
      );

  Future<bool> _confirmAndDeleteDeck(BuildContext context) async {
    // Retrieve values from context immediately, while it is still available. If
    // this widget is disposed and deleted from widget tree, looking up its
    // ancestors throws an exception.
    final locale = context.l;
    final scaffold = Scaffold.of(context),
        deckDeletedUserMessage = locale.deckDeletedUserMessage;

    // Confirm in foreground, stopping any animation.
    if (!await showSaveUpdatesDialog(
        context: context,
        changesQuestion: deck.access == AccessType.owner
            ? locale.deleteDeckOwnerAccessQuestion
            : locale.deleteDeckWriteReadAccessQuestion,
        yesAnswer: locale.delete,
        noAnswer: MaterialLocalizations.of(context).cancelButtonLabel)) {
      return false;
    }

    unawaited(logDeckDelete(deck.key));

    // Don't wait for deck deletion to finish caller animation; if item is
    // removed from the list faster than Dismissible finishes animating, it
    // throws an exception.
    unawaited(() async {
      try {
        await bloc.deleteDeck(deck);
        UserMessages.showMessage(scaffold, deckDeletedUserMessage);
      } catch (e, stackTrace) {
        UserMessages.showAndReportError(
          () => scaffold,
          e,
          stackTrace: stackTrace,
        );
      }
    }());

    return true;
  }
}
