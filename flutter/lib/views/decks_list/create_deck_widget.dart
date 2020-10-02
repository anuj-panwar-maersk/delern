import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/view_models/decks_list_bloc.dart';
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/routes.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:delern_flutter/views/helpers/user_messages.dart';
import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';

class CreateDeckWidget extends StatelessWidget {
  final DecksListBloc bloc;

  const CreateDeckWidget({
    @required this.bloc,
    Key key,
  })  : assert(bloc != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => FloatingActionButton(
        tooltip: context.l.createDeckTooltip,
        onPressed: () async {
          var newDeck = await showDialog<DeckModel>(
            context: context,
            // User must tap a button to dismiss dialog
            barrierDismissible: false,
            builder: (_) => _CreateDeckDialog(),
          );
          if (newDeck != null) {
            try {
              newDeck = await bloc.createDeck(newDeck);
            } catch (e, stackTrace) {
              UserMessages.showAndReportError(
                () => Scaffold.of(context),
                e,
                stackTrace: stackTrace,
              );
              return;
            }
            unawaited(openNewCardScreen(context,
                deckKey: newDeck.key, isDecksScreen: true));
          }
        },
        child: const Icon(Icons.add),
      );
}

class _CreateDeckDialog extends StatefulWidget {
  @override
  _CreateDeckDialogState createState() => _CreateDeckDialogState();
}

class _CreateDeckDialogState extends State<_CreateDeckDialog> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final addDeckButton = FlatButton(
      onPressed: _textController.text.isEmpty
          ? null
          : () {
              Navigator.of(context).pop(
                  (DeckModelBuilder()..name = _textController.text).build());
            },
      child: Text(
        context.l.add.toUpperCase(),
        style: TextStyle(
            color: _textController.text.isEmpty
                ? Theme.of(context).disabledColor
                : Theme.of(context).primaryColor),
      ),
    );

    final cancelButton = FlatButton(
        onPressed: () => Navigator.of(context).pop(null),
        child: Text(
          MaterialLocalizations.of(context).cancelButtonLabel.toUpperCase(),
          style: TextStyle(color: Theme.of(context).primaryColor),
        ));

    final deckNameTextField = TextField(
      autofocus: true,
      controller: _textController,
      // TODO(ksheremet): Call setState to update addDeckButton. Consider
      // more elegant way
      onChanged: (text) => setState(() {}),
      style: app_styles.primaryText,
    );

    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return AlertDialog(
        title: Text(
          context.l.deck,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: deckNameTextField,
        ),
        actions: <Widget>[
          cancelButton,
          addDeckButton,
        ],
      );
    } else {
      return _HorizontalDialog(
        child: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Row(
                children: <Widget>[
                  Flexible(child: deckNameTextField),
                  Column(
                    children: <Widget>[
                      addDeckButton,
                      cancelButton,
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}

class _HorizontalDialog extends StatelessWidget {
  const _HorizontalDialog({
    Key key,
    this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // The duration of the animation to show when the system keyboard intrudes
    // into the space that the dialog is placed in.
    const insetAnimationDuration = Duration(milliseconds: 100);

    // The curve to use for the animation shown when the system
    // keyboard intrudes
    // into the space that the dialog is placed in.
    const insetAnimationCurve = Curves.decelerate;

    const dialogShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)));

    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets,
      duration: insetAnimationDuration,
      curve: insetAnimationCurve,
      child: Center(
        child: Material(
          elevation: 24,
          color: Theme.of(context).dialogBackgroundColor,
          type: MaterialType.card,
          shape: dialogShape,
          child: child,
        ),
      ),
    );
  }
}
