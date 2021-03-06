import 'package:delern_flutter/models/local_notification.dart';
import 'package:delern_flutter/remote/analytics/analytics.dart';
import 'package:delern_flutter/view_models/notifications_view_model.dart';
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:delern_flutter/views/notifications/notification_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets(
    'Add and delete notifications',
    (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<LocalNotifications>(
          create: (context) => LocalNotifications(
            flutterLocalNotificationsPlugin:
                MockFlutterLocalNotificationsPlugin(),
            messages: [
              (LocalNotificationBuilder()..title = 'Test notification').build()
            ],
            notificationPurpose: 'Test',
            onNotificationPressed: (payload) {
              debugPrint(
                  'Notification pressed with payload:${payload.toString()}');
            },
            analytics: MockAnalytics(),
          ),
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizationsDelegate(),
            ],
            home: NotificationSettings(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await addNotificationSchedule(tester);
      await disableNotificationsForMonday(tester);
      await deleteNotifications(tester);
    },
  );
}

Future<void> addNotificationSchedule(WidgetTester tester) async {
  await expectLater(find.text('Add Reminder'), findsOneWidget);
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
  expect(find.text('Mon'), findsOneWidget);
  expect(find.text('Tue'), findsOneWidget);
  expect(find.text('Wed'), findsOneWidget);
  expect(find.text('Thu'), findsOneWidget);
  expect(find.text('Fri'), findsOneWidget);
  expect(find.text('Sat'), findsOneWidget);
  expect(find.text('Sun'), findsOneWidget);
}

Future<void> disableNotificationsForMonday(WidgetTester tester) async {
  final mondayActionChip =
      tester.widget<ActionChip>(find.widgetWithText(ActionChip, 'Mon'));
  expect(mondayActionChip.backgroundColor,
      app_styles.kNotificationByDayEnabledColor);

  await tester.tap(find.widgetWithText(ActionChip, 'Mon'));
  await tester.pumpAndSettle();
  final mondayActionChipDisabled =
      tester.widget<ActionChip>(find.widgetWithText(ActionChip, 'Mon'));
  expect(mondayActionChipDisabled.backgroundColor,
      app_styles.kNotificationByDayDisabledColor);
}

Future<void> deleteNotifications(WidgetTester tester) async {
  await tester.tap(find.widgetWithIcon(IconButton, Icons.delete_outline));
  await tester.pumpAndSettle();
  expect(find.text('Mon'), findsNothing);
}

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockAnalytics extends Mock implements AnalyticsLogger {}
