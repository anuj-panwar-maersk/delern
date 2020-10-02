import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/view_models/edit_deck_bloc.dart';
import 'package:delern_flutter/views/card_list/deck_settings_widget.dart';
import 'package:delern_flutter/views/card_list/rename_deck_dialog.dart';
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:flutter/material.dart';

enum _CardListMenu { rename, deckType }

class CardListPopupMenu extends StatelessWidget {
  final EditDeckBloc bloc;
  final DeckModel deck;

  const CardListPopupMenu({@required this.bloc, @required this.deck});

  @override
  Widget build(BuildContext context) => PopupMenuButton<_CardListMenu>(
        onSelected: (result) async {
          switch (result) {
            case _CardListMenu.deckType:
              await showDialog<void>(
                context: context,
                builder: (context) =>
                    Dialog(child: DeckSettingsWidget(deck: deck, bloc: bloc)),
              );
              break;
            case _CardListMenu.rename:
              final newName = await showDialog<String>(
                  context: context,
                  builder: (context) => RenameDeckDialog(name: deck.name));
              if (newName != null) {
                bloc.onDeckName.add(newName);
              }
              break;
          }
        },
        itemBuilder: (context) => _CardListMenu.values
            .map((e) => PopupMenuItem<_CardListMenu>(
                  value: _CardListMenu.values[e.index],
                  child:
                      Text(_buildMenu(context)[_CardListMenu.values[e.index]]),
                ))
            .toList(),
      );

  Map<_CardListMenu, String> _buildMenu(BuildContext context) => {
        _CardListMenu.rename: context.l.renameDeck,
        _CardListMenu.deckType: context.l.deckType,
      };
}
