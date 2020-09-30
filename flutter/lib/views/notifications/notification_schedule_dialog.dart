import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationScheduleDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return CupertinoAlertDialog(
        content: const DialogContent(),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l.later),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l.yes),
          ),
        ],
      );
    } else {
      return AlertDialog(
        content: const DialogContent(),
        actions: [
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l.later.toUpperCase()),
          ),
          FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l.yes.toUpperCase()),
          ),
        ],
      );
    }
  }
}

@immutable
class DialogContent extends StatelessWidget {
  const DialogContent();

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            context.l.learnCardsNotificationSuggestion,
            style: Theme.of(context)
                .textTheme
                .subtitle1
                .copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            context.l.notificationInSettingsSchedule,
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
}
