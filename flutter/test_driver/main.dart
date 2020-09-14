import 'dart:convert';

import 'package:delern_flutter/main.dart' as app;
import 'package:delern_flutter/remote/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_driver/driver_extension.dart';

import 'commands.dart';

Future<void> main() async {
  // This line enables the extension
  enableFlutterDriverExtension(handler: (command) async {
    if (command == kGetWindow) {
      final window = WidgetsFlutterBinding.ensureInitialized().window;
      final size = window.physicalSize / window.devicePixelRatio;
      return json.encode(Window(
        width: size.width,
        height: size.height,
      ));
    }

    return null;
  });
  // Sign out before running tests to clear cached data.
  await Firebase.initializeApp();
  await Auth.instance.signOut();
  // Call the `main()` of your app or call `runApp` with whatever widget
  // you are interested in testing.
  await app.main();
}
