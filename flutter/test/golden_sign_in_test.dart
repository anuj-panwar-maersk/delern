import 'dart:io';

import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/sign_in/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Sign in screen',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(
        localizationsDelegates: [
          AppLocalizationsDelegate(),
        ],
        home: Scaffold(body: SignIn(SignInMode.initialSignIn)),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(SignIn),
        matchesGoldenFile('goldens/sign_in.png'),
      );
    },
    skip: !Platform.environment.containsKey('FLUTTER_GOLDENS'),
  );
}
