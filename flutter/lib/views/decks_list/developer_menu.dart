import 'package:delern_flutter/views/helpers/device_info.dart';
import 'package:delern_flutter/views/helpers/progress_indicator_widget.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:delern_flutter/views/helpers/user_messages.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sentry/flutter_sentry.dart';

bool _debugAllowDevMenu = true;

Future<String> _getDebugInformation() async {
  final projectID = (Firebase.app().options).projectId,
      user = fb_auth.FirebaseAuth.instance.currentUser,
      keyValueInfo = [
        ...?user.providerData.map((info) => '\t${info.toString()}'),
        ...?(await DeviceInfo.getDeviceInfo())
            .info
            .entries
            .map((entry) => '${entry.key}: ${entry.value}'),
      ];
  return '''
Firebase project ID: $projectID
Firebase user ID: ${user.uid}

${keyValueInfo.join('\n')}
      ''';
}

List<Widget> buildDeveloperMenu(BuildContext context) {
  if (!_debugAllowDevMenu) {
    return [];
  }

  // This code will run only in debug mode. Since dev menu items are not visible
  // to the end user, we do not need to localize them.
  return [
    const Divider(height: 1),
    ListTile(
      title: Text(
        'Developer menu',
        style: app_styles.navigationDrawerGroupText,
      ),
      subtitle: const Text('Available only in debug mode'),
    ),
    ListTile(
      leading: const Icon(Icons.cancel),
      title: const Text('Simulate a crash'),
      onTap: () {
        UserMessages.showMessage(Scaffold.of(context), 'Crashing...');

        FlutterSentry.nativeCrash();
        UserMessages.showMessage(Scaffold.of(context), 'Failed to crash!');
      },
    ),
    ListTile(
      leading: const Icon(Icons.image),
      title: const Text('Remove Debug artifacts'),
      subtitle: const Text('Restart the app to restore'),
      onTap: () {
        // Get the root state to make sure WidgetsApp (a subwidget of
        // MaterialApp) is restarted. Very hacky, but this code will not even
        // exist in production version of the app.
        context.findRootAncestorStateOfType<State>()
            // ignore: invalid_use_of_protected_member
            .setState(() {
          _debugAllowDevMenu = false;
          WidgetsApp.debugAllowBannerOverride = false;
        });
      },
    ),
    AboutListTile(
      icon: const Icon(Icons.info),
      aboutBoxChildren: <Widget>[
        FutureBuilder<String>(
          future: _getDebugInformation(),
          builder: (context, snapshot) => snapshot.hasData
              ? SelectableText(snapshot.data)
              : const ProgressIndicatorWidget(),
        ),
      ],
      child: const Text('About Debug version'),
    ),
  ];
}
