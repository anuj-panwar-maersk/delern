import 'dart:io';

import 'package:delern_flutter/remote/auth.dart';
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/sign_in/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Sign in screen',
    (tester) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
        ],
        home: Scaffold(
          body: SignIn(
            SignInMode.initialSignIn,
            auth: Auth.instance,
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
}
