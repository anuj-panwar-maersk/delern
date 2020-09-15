import 'package:delern_flutter/remote/auth.dart';
import 'package:delern_flutter/views/helpers/device_info.dart';
import 'package:delern_flutter/views/helpers/progress_indicator_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiver/strings.dart';

class Developer extends StatefulWidget {
  const Developer();

  @override
  State<StatefulWidget> createState() => _DeveloperState();
}

@immutable
class _CopyableListTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String value;

  const _CopyableListTile({
    @required this.leading,
    @required this.title,
    @required this.value,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        title: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black),
            children: [
              TextSpan(
                text: '$title: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: value == null ? 'null' : value == '' ? 'blank' : value,
                style: isBlank(value)
                    ? const TextStyle(fontStyle: FontStyle.italic)
                    : null,
              )
            ],
          ),
        ),
        leading: leading,
        subtitle: const Text('Tap to copy'),
        onTap: () async {
          if (isBlank(value)) {
            Scaffold.of(context).showSnackBar(const SnackBar(
              content: Text(
                'No value to copy!',
              ),
            ));
          } else {
            await Clipboard.setData(ClipboardData(text: value));
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('Copied "$value"'),
            ));
          }
        },
      );
}

class _DeveloperState extends State<Developer> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Developer screen'),
        ),
        body: FutureBuilder<DeviceInfo>(
          future: DeviceInfo.getDeviceInfo(),
          builder: (context, snapshot) => snapshot.hasData
              ? ListView(
                  children: [
                    _CopyableListTile(
                      leading: const Icon(Icons.folder),
                      title: 'Project ID',
                      value: Firebase.app().options.projectId,
                    ),
                    _CopyableListTile(
                      leading: const Icon(Icons.person),
                      title: 'User ID',
                      value: Auth.instance.currentUser.value?.uid,
                    ),
                    ...FirebaseAuth.instance.currentUser.providerData
                        .map(
                          (userInfo) => [
                            const Divider(),
                            Text('Sign In Provider: ${userInfo.providerId}'),
                            _CopyableListTile(
                              leading: const Icon(Icons.person),
                              title: 'uid',
                              value: userInfo.uid,
                            ),
                            _CopyableListTile(
                              leading: const Icon(Icons.person),
                              title: 'displayName',
                              value: userInfo.displayName,
                            ),
                            _CopyableListTile(
                              leading: const Icon(Icons.person),
                              title: 'email',
                              value: userInfo.email,
                            ),
                            _CopyableListTile(
                              leading: const Icon(Icons.person),
                              title: 'phoneNumber',
                              value: userInfo.phoneNumber,
                            ),
                            _CopyableListTile(
                              leading: Image.network(userInfo.photoURL),
                              title: 'photoURL',
                              value: userInfo.photoURL,
                            ),
                          ],
                        )
                        .expand((element) => element),
                    const Divider(),
                    _CopyableListTile(
                      leading: const Icon(Icons.smartphone),
                      title: 'Device Friendly Name',
                      value: snapshot.data.userFriendlyName,
                    ),
                    ...snapshot.data.info.entries.map(
                      (entry) => _CopyableListTile(
                        leading: const Icon(Icons.smartphone),
                        title: entry.key,
                        value: entry.value.toString(),
                      ),
                    ),
                  ],
                )
              : const ProgressIndicatorWidget(),
        ),
      );
}
