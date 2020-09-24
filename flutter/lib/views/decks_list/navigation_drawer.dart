import 'dart:async';

import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/remote/analytics.dart';
import 'package:delern_flutter/remote/auth.dart';
import 'package:delern_flutter/views/decks_list/developer_menu.dart';
import 'package:delern_flutter/views/helpers/auth_widget.dart';
import 'package:delern_flutter/views/helpers/email_launcher.dart';
import 'package:delern_flutter/views/helpers/legal.dart';
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/routes.dart';
import 'package:delern_flutter/views/helpers/send_invite.dart';
import 'package:delern_flutter/views/helpers/stream_with_value_builder.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:delern_flutter/views/helpers/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info/package_info.dart';
import 'package:pedantic/pedantic.dart';

@immutable
class NavigationDrawer extends StatefulWidget {
  const NavigationDrawer();

  @override
  _NavigationDrawerState createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  String versionCode;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((packageInfo) => setState(() {
          versionCode = packageInfo.version;
        }));
  }

  Widget _buildTextLink(String text, void Function() onTap) => GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            text,
            style: const TextStyle(color: app_styles.kHyperlinkColor),
          ),
        ),
      );

  List<Widget> _buildUserButtons(User user) {
    final list = <Widget>[
      ListTile(
        leading: const Icon(Icons.contact_mail),
        title: Text(context.l.navigationDrawerInviteFriends),
        onTap: () {
          sendInvite(context);
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.live_help),
        title: Text(context.l.navigationDrawerContactUs),
        onTap: () async {
          Navigator.pop(context);
          await launchEmail(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.mail),
        title: Text(context.l.notifications),
        onTap: () {
          Navigator.pop(context);
          openNotificationSettingsScreen(context);
        },
      ),
      const Divider(height: 1),
      AboutListTile(
        icon: const Icon(Icons.perm_device_information),
        applicationIcon: Image.asset('images/ic_launcher.png'),
        applicationVersion: versionCode,
        applicationLegalese: 'GNU General Public License v3.0',
        aboutBoxChildren: <Widget>[
          _buildTextLink(context.l.termsOfService, () {
            launchUrl(kTermsOfService, context);
          }),
          _buildTextLink(context.l.privacyPolicy, () {
            launchUrl(kPrivacyPolicy, context);
          }),
        ],
        child: Text(context.l.navigationDrawerAbout),
      ),
    ];

    final signInOutWidget = ListTile(
      leading: const Icon(Icons.perm_identity),
      title: Text(user.isAnonymous
          ? context.l.navigationDrawerSignIn
          : context.l.navigationDrawerSignOut),
      onTap: () {
        if (user.isAnonymous) {
          unawaited(_promoteAnonymous(context, user));
        } else {
          unawaited(user.auth.signOut());
          Navigator.pop(context);
        }
      },
    );

    if (user.isAnonymous) {
      list..insert(0, signInOutWidget)..insert(1, const Divider(height: 1));
    } else {
      list..add(const Divider(height: 1))..add(signInOutWidget);
    }

    assert(() {
      list.addAll(buildDeveloperMenu(context));
      return true;
    }());

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final user = CurrentUserWidget.of(context).user;

    return Drawer(
      child: ListView(
          // Remove any padding from the ListView.
          // https://flutter.io/docs/cookbook/design/drawer
          padding: EdgeInsets.zero,
          children: <Widget>[
            DataStreamWithValueBuilder<UserProfile>(
              streamWithValue: user.profile,
              builder: (context, profile) => UserAccountsDrawerHeader(
                accountName: Text(profile.displayName ?? context.l.anonymous),
                accountEmail: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (profile.email != null) Text(profile.email),
                        ...profile.providers.map(_buildProviderImage),
                      ],
                    )),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: profile.photoUrl == null
                      ? const AssetImage('images/anonymous.jpg')
                          // https://github.com/dart-lang/sdk/issues/43410
                          // ignore: avoid_as
                          as ImageProvider<dynamic>
                      : NetworkImage(profile.photoUrl),
                ),
              ),
            ),
            ...?_buildUserButtons(user),
          ]),
    );
  }

  Widget _buildProviderImage(AuthProvider provider) {
    Color backgroundColor;
    String providerImageAsset;
    switch (provider) {
      // TODO(dotdoom): add more providers here #944.
      case AuthProvider.google:
        backgroundColor = Colors.white;
        providerImageAsset = 'images/google_sign_in.png';
        break;

      case AuthProvider.facebook:
        backgroundColor = app_styles.kFacebookBlueColor;
        providerImageAsset = 'images/facebook_sign_in.webp';
        break;
      case AuthProvider.apple:
        backgroundColor = Colors.black;
        providerImageAsset = 'images/apple_sign_in.webp';
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(2)),
          ),
          child: Image.asset(providerImageAsset, height: 34),
        );
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(2)),
      ),
      padding: const EdgeInsets.all(8),
      child: Image.asset(providerImageAsset, height: 18),
    );
  }

  Future<void> _promoteAnonymous(
    BuildContext context,
    User user,
  ) async {
    unawaited(logPromoteAnonymous());
    return openLinkAccountScreen(context, auth: user.auth);
  }
}
