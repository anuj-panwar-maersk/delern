import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/routes.dart';
import 'package:delern_flutter/views/helpers/save_updates_dialog.dart';
import 'package:delern_flutter/views/helpers/user_messages.dart';
import 'package:flutter/material.dart';

class CardActionsMenuWidget extends StatefulWidget {
  final User user;
  final DeckModel deck;
  final CardModel card;

  const CardActionsMenuWidget({
    @required this.user,
    @required this.deck,
    @required this.card,
    Key key,
  })  : assert(user != null),
        assert(deck != null),
        assert(card != null),
        super(key: key);

  @override
  _CardActionsMenuWidgetState createState() => _CardActionsMenuWidgetState();
}

class _CardActionsMenuWidgetState extends State<CardActionsMenuWidget> {
  @override
  Widget build(BuildContext context) => PopupMenuButton<_CardMenuItemType>(
        tooltip: context.l.menuTooltip,
        onSelected: (itemType) => _onCardMenuItemSelected(
          context: context,
          menuItem: itemType,
        ),
        itemBuilder: (context) => [
          for (final entry in _buildMenu(context).entries)
            PopupMenuItem<_CardMenuItemType>(
              value: entry.key,
              child: Text(entry.value),
            ),
        ],
      );

  void _onCardMenuItemSelected({
    @required BuildContext context,
    @required _CardMenuItemType menuItem,
  }) {
    switch (menuItem) {
      case _CardMenuItemType.edit:
        if (widget.deck.access != AccessType.read) {
          openEditCardScreen(
            context,
            deckKey: widget.deck.key,
            cardKey: widget.card.key,
          );
        } else {
          UserMessages.showMessage(Scaffold.of(context),
              context.l.noEditingWithReadAccessUserMessage);
        }
        break;
      case _CardMenuItemType.delete:
        if (widget.deck.access != AccessType.read) {
          _deleteCard(context: context);
        } else {
          UserMessages.showMessage(Scaffold.of(context),
              context.l.noDeletingWithReadAccessUserMessage);
        }
        break;
    }
  }

  Future<void> _deleteCard({
    @required BuildContext context,
  }) async {
    final saveChanges = await showSaveUpdatesDialog(
        context: context,
        changesQuestion: context.l.deleteCardQuestion,
        yesAnswer: context.l.delete,
        noAnswer: MaterialLocalizations.of(context).cancelButtonLabel);
    if (saveChanges) {
      try {
        await widget.user.deleteCard(card: widget.card);
        if (mounted) {
          UserMessages.showMessage(
              Scaffold.of(context), context.l.cardDeletedUserMessage);
        }
      } catch (e, stackTrace) {
        UserMessages.showAndReportError(
          () => Scaffold.of(context),
          e,
          stackTrace: stackTrace,
        );
      }
    }
  }
}

enum _CardMenuItemType { edit, delete }

Map<_CardMenuItemType, String> _buildMenu(BuildContext context) => {
      _CardMenuItemType.edit: context.l.edit,
      _CardMenuItemType.delete: context.l.delete,
    };
