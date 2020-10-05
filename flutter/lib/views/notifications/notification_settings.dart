import 'package:built_collection/built_collection.dart';
import 'package:delern_flutter/view_models/notifications_view_model.dart';
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NotificationSettings extends StatelessWidget {
  static const routeName = '/notification_settings';
  const NotificationSettings();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(context.l.notifications),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Consumer<LocalNotifications>(
                    builder: (context, notifications, widget) => Column(
                        children: notifications.userSchedule.entries
                            .map(
                              (e) => NotificationCard(
                                time: e.key,
                                days: e.value,
                                onDayPressed: (weekDay) => context
                                    .read<LocalNotifications>()
                                    .changedWeekDaysForTime(e.key, weekDay),
                                onDeleted: () => context
                                    .read<LocalNotifications>()
                                    .deleteReminderRule(e.key),
                                onTimeChanged: (newTime) => context
                                    .read<LocalNotifications>()
                                    .changedTime(e.key, newTime),
                              ),
                            )
                            .toList())),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
            // To turn off animation with previous screen
            heroTag: 'Add Reminder',
            icon: const Icon(Icons.add),
            onPressed: () async {
              var newTime = DateTime.now();
              do {
                newTime = await showDialog(
                  context: context,
                  builder: (context) => TimePickerDialog(
                    initialDateTime: newTime,
                    showErrorLabel: context
                        .watch<LocalNotifications>()
                        .isTimeAlreadyScheduled(
                            TimeOfDay.fromDateTime(newTime)),
                  ),
                );
              } while (newTime != null &&
                  context
                      .read<LocalNotifications>()
                      .isTimeAlreadyScheduled(TimeOfDay.fromDateTime(newTime)));
              // Null returned when user dismissed dialog
              if (newTime != null) {
                await context
                    .read<LocalNotifications>()
                    .addNewReminderRule(time: TimeOfDay.fromDateTime(newTime));
              }
            },
            label: Text(context.l.addReminder)),
      );
}

class TimePickerDialog extends StatefulWidget {
  final DateTime initialDateTime;
  final bool showErrorLabel;

  const TimePickerDialog(
      {@required this.initialDateTime, this.showErrorLabel = false});
  @override
  _TimePickerDialogState createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<TimePickerDialog> {
  DateTime _dateTime;

  @override
  void initState() {
    _dateTime = widget.initialDateTime;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                context.l.chooseTimeOfDayLabel,
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  use24hFormat: MediaQuery.of(context).alwaysUse24HourFormat,
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: widget.initialDateTime,
                  onDateTimeChanged: (newDateTime) => _dateTime = newDateTime,
                ),
              ),
              const SizedBox(height: 8),
              FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                color: Theme.of(context).accentColor,
                onPressed: () => Navigator.of(context).pop(_dateTime),
                child: Text(
                  context.l.ok.toUpperCase(),
                  style: const TextStyle(color: app_styles.kButtonTextColor),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Visibility(
                  visible: widget.showErrorLabel,
                  child: Text(
                    context.l.chosenTimeExistsError,
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        .copyWith(color: app_styles.kErrorLabelColor),
                  ),
                ),
              )
            ],
          ),
        ),
      );
}

class NotificationCard extends StatelessWidget {
  final TimeOfDay time;
  final BuiltList<int> days;
  final void Function(int weekDay) onDayPressed;
  final void Function(TimeOfDay time) onTimeChanged;
  final void Function() onDeleted;

  const NotificationCard({
    @required this.time,
    @required this.days,
    @required this.onDayPressed,
    @required this.onTimeChanged,
    @required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: app_styles.kIconColor,
                  onPressed: onDeleted,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () async {
                      var newTime = DateTime.now();
                      do {
                        newTime = await showDialog(
                          context: context,
                          builder: (context) => TimePickerDialog(
                            initialDateTime: newTime,
                            showErrorLabel: context
                                .watch<LocalNotifications>()
                                .isTimeAlreadyScheduled(
                                    TimeOfDay.fromDateTime(newTime)),
                          ),
                        );
                      } while (newTime != null &&
                          TimeOfDay.fromDateTime(newTime) != time &&
                          context
                              .read<LocalNotifications>()
                              .isTimeAlreadyScheduled(
                                  TimeOfDay.fromDateTime(newTime)));
                      // Null returned when user dismissed dialog
                      if (newTime != null &&
                          TimeOfDay.fromDateTime(newTime) != time) {
                        await context
                            .read<LocalNotifications>()
                            .addNewReminderRule(
                                time: TimeOfDay.fromDateTime(newTime));
                        onTimeChanged(TimeOfDay.fromDateTime(newTime));
                      }
                    },
                    child: Text(
                      time.format(context),
                      style: app_styles.secondaryText
                          .copyWith(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(children: <Widget>[
              for (var i = 1; i <= DateTime.daysPerWeek; i++)
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: ActionChip(
                    labelPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    label: Text(
                      DateFormat.E(Localizations.localeOf(context).languageCode)
                          .format(DateTime(2020, 6, i)),
                      style:
                          app_styles.primaryText.copyWith(color: Colors.white),
                    ),
                    backgroundColor: days.contains(i)
                        ? app_styles.kNotificationByDayEnabledColor
                        : app_styles.kNotificationByDayDisabledColor,
                    onPressed: () => onDayPressed(i),
                  ),
                ),
            ])
          ],
        ),
      ),
    );
  }
}
