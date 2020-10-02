import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:flutter/material.dart';

class RenameDeckDialog extends StatefulWidget {
  final String name;

  const RenameDeckDialog({@required this.name});

  @override
  _RenameDeckDialogState createState() => _RenameDeckDialogState();
}

class _RenameDeckDialogState extends State<RenameDeckDialog> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    _textController.text = widget.name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final renameDeckButton = FlatButton(
      onPressed: _textController.text.isEmpty
          ? null
          : () {
              Navigator.of(context).pop(_textController.text);
            },
      child: Text(
        context.l.rename.toUpperCase(),
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
      onChanged: (text) => setState(() {}),
      style: app_styles.primaryText,
    );

    return AlertDialog(
      title: Text(
        context.l.newName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      content: SingleChildScrollView(
        child: deckNameTextField,
      ),
      actions: <Widget>[
        cancelButton,
        renameDeckButton,
      ],
    );
  }
}
