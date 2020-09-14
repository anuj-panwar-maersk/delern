import 'package:delern_flutter/view_models/notifications.dart';
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NotificationSettings extends StatelessWidget {
  static const routeName = 'notificationSettings';
  const NotificationSettings();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(context.l.notifications),
        ),
        body: SingleChildScrollView(
          child: Column(
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
                                onDayPressed: (weekDay) {
                                  context
                                      .read<LocalNotifications>()
                                      .changedDayForWeekByTime(e.key, weekDay);
                                },
                                onDeleted: () {
                                  context
                                      .read<LocalNotifications>()
                                      .deleteNotificationRule(e.key);
                                },
                                onTimeChanged: (newTime) {
                                  context
                                      .read<LocalNotifications>()
                                      .changeTime(e.key, newTime);
                                },
                              ),
                            )
                            .toList())),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8),
                child: FloatingActionButton.extended(
                    // To turn off animation with previous screen
                    heroTag: 'Add Reminder',
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      context.read<LocalNotifications>().addNewReminderRule();
                    },
                    label: Text(context.l.addReminder)),
              ),
            ],
          ),
        ),
      );
}

class NotificationCard extends StatelessWidget {
  final TimeOfDay time;
  final List<int> days;
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
                      final newTime = await showTimePicker(
                          context: context, initialTime: TimeOfDay.now());
                      onTimeChanged(newTime);
                    },
                    child: Text(
                      '${time.hour}:${time.minute}',
                      style: app_styles.secondaryText
                          .copyWith(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(children: <Widget>[
              for (var i = 1; i < DateTime.daysPerWeek; i++)
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: ActionChip(
                    labelPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    label: Text(
                      DateFormat.E(Localizations.localeOf(context).languageCode)
                          .format(DateTime(
                              DateTime.now().year, DateTime.now().month, i)),
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
