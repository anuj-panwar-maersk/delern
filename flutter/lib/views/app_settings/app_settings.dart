import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/routes.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:flutter/material.dart';

class AppSettings extends StatelessWidget {
  static String routeName = '/app_settings';

  const AppSettings();

  @override
  Widget build(BuildContext context) {
    final settingsList = _buildSettingsOptions(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.l.settings)),
      body: ListView.separated(
        itemCount: settingsList.length,
        itemBuilder: (context, i) => settingsList[i],
        separatorBuilder: (context, i) => const Divider(),
      ),
    );
  }

  List<Widget> _buildSettingsOptions(BuildContext context) => [
        ListTile(
          leading: const Icon(Icons.font_download_rounded),
          title: Text(
            context.l.cardsFontSize,
            style: app_styles.primaryText,
          ),
          onTap: () => openCardsFontSizeSettingsScreen(context),
        ),
      ];
}
