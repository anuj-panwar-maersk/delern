import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationScheduleDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return CupertinoAlertDialog(
        title: Text(context.l.learnCardsNotificationSuggestion),
        content: Text(context.l.notificationInSettingsSchedule),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l.later.toUpperCase()),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l.yes.toUpperCase()),
          ),
        ],
      );
    } else {
      return AlertDialog(
        title: Text(context.l.learnCardsNotificationSuggestion),
        content: Text(context.l.notificationInSettingsSchedule),
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
