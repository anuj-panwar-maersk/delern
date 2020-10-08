import 'dart:io';

import 'package:delern_flutter/remote/analytics/analytics.dart';
import 'package:delern_flutter/remote/auth.dart';
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/sign_in/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets(
    'Sign in screen golden test',
    (tester) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
        ],
        home: Scaffold(
          body: SignIn(
            SignInMode.initialSignIn,
            auth: MockAuth(),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(SignIn),
        matchesGoldenFile('goldens/sign_in.png'),
      );
    },
    skip: !Platform.environment.containsKey('FLUTTER_GOLDENS'),
  );

  testWidgets(
    'Sign in screen triggers Google',
    (tester) async {
      final auth = MockAuth();

      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
        ],
        home: Scaffold(
          body: Provider<Analytics>(
            create: (_) => MockAnalytics(),
            builder: (context, _) => SignIn(
              SignInMode.initialSignIn,
              auth: auth,
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign in with Google'));

      verify(auth.signIn(AuthProvider.google));
      verifyNoMoreInteractions(auth);
    },
  );

  testWidgets(
    'Sign in screen in link mode pops if Guest is selected',
    (tester) async {
      final auth = MockAuth();
      final observer = MockNavigatorObserver();

      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
        ],
        navigatorObservers: [observer],
        home: Scaffold(
          body: Provider<Analytics>(
            create: (_) => MockAnalytics(),
            builder: (context, _) => SignIn(
              SignInMode.linkToAccount,
              auth: auth,
            ),
          ),
        ),
      ));

      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE AS A GUEST'));

      expect(
        verify(observer.didPop(
          null,
          captureAny,
        )).captured[0].settings.name,
        '/',
      );
      verifyNoMoreInteractions(auth);
    },
    // TODO(ksheremet): fix layout and un-skip this test!
    skip: true,
  );
}

class MockAuth extends Mock implements Auth {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockAnalytics extends Mock implements Analytics {}
