import 'dart:async';

import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/remote/analytics.dart';
import 'package:delern_flutter/remote/auth.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:delern_flutter/views/decks_list/developer_menu.dart';
import 'package:delern_flutter/views/helpers/auth_widget.dart';
import 'package:delern_flutter/views/helpers/email_launcher.dart';
import 'package:delern_flutter/views/helpers/legal.dart';
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/routes.dart';
import 'package:delern_flutter/views/helpers/send_invite.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:delern_flutter/views/helpers/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info/package_info.dart';
import 'package:pedantic/pedantic.dart';

class NavigationDrawer extends StatefulWidget {
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
          unawaited(_promoteAnonymous(context));
        } else {
          unawaited(Auth.instance.signOut());
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

    ImageProvider<dynamic> backgroundImage;
    if (user.photoUrl == null) {
      backgroundImage = const AssetImage('images/anonymous.jpg');
    } else {
      backgroundImage = NetworkImage(user.photoUrl);
    }

    final accountName = user.displayName ?? context.l.anonymous;

    return Drawer(
      child: ListView(
          // Remove any padding from the ListView.
          // https://flutter.io/docs/cookbook/design/drawer
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(accountName),
              accountEmail: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (user.email != null) Text(user.email),
                      ...user.providers.map(_buildProviderImage),
                    ],
                  )),
              currentAccountPicture: CircleAvatar(
                backgroundImage: backgroundImage,
              ),
            ),
            ...?_buildUserButtons(user),
          ]),
    );
  }

  Widget _buildProviderImage(String provider) {
    Color backgroundColor;
    String providerImageAsset;
    switch (provider) {
      // TODO(dotdoom): add more providers here #944.
      case GoogleAuthProvider.providerId:
        backgroundColor = Colors.white;
        providerImageAsset = 'images/google_sign_in.png';
        break;
      case FacebookAuthProvider.providerId:
        backgroundColor = app_styles.kFacebookBlueColor;
        providerImageAsset = 'images/facebook_sign_in.webp';
        break;
      default:
        unawaited(error_reporting.report('Unknown provider: $provider'));
        return Text(provider);
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

  Future<void> _promoteAnonymous(BuildContext context) async {
    unawaited(logPromoteAnonymous());
    return openSignInScreen(context);
  }
}
