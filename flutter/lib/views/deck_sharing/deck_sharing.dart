import 'dart:async';
import 'dart:io';

import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/remote/analytics/analytics.dart';
import 'package:delern_flutter/remote/app_config.dart';
import 'package:delern_flutter/remote/user_lookup.dart';
import 'package:delern_flutter/view_models/deck_access_view_model.dart';
import 'package:delern_flutter/views/deck_sharing/deck_access_dropdown.dart';
import 'package:delern_flutter/views/helpers/auth_widget.dart';
import 'package:delern_flutter/views/helpers/empty_list_message_widget.dart';
import 'package:delern_flutter/views/helpers/list_accessor_widget.dart';
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/progress_indicator_widget.dart';
import 'package:delern_flutter/views/helpers/save_updates_dialog.dart';
import 'package:delern_flutter/views/helpers/send_invite.dart';
import 'package:delern_flutter/views/helpers/slow_operation_widget.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:delern_flutter/views/helpers/user_messages.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeckSharing extends StatefulWidget {
  static const routeName = '/share-deck';

  final DeckModel _deck;

  const DeckSharing(this._deck);

  @override
  State<StatefulWidget> createState() => _DeckSharingState();
}

class _DeckSharingState extends State<DeckSharing> {
  final TextEditingController _textController = TextEditingController();
  AccessType _accessValue = AccessType.write;
  DeckAccessesViewModel _deckAccessesViewModel;

  @override
  void didChangeDependencies() {
    final user = CurrentUserWidget.of(context).user;
    if (_deckAccessesViewModel?.user != user) {
      _deckAccessesViewModel = DeckAccessesViewModel(
        user: user,
        deck: widget._deck,
        analytics: context.read<Analytics>(),
      );
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget._deck.name),
          actions: <Widget>[
            Builder(
              builder: (context) => SlowOperationWidget(
                (cb) => IconButton(
                    tooltip: context.l.shareDeckTooltip,
                    icon: const Icon(Icons.send),
                    onPressed: _isEmailCorrect()
                        ? cb(() => _shareDeck(_accessValue, context))
                        : null),
              ),
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: Row(
                children: <Widget>[
                  Text(
                    context.l.peopleLabel,
                    style: app_styles.secondaryText,
                  ),
                ],
              ),
            ),
            _sharingEmail(),
            Expanded(child: DeckUsersWidget(_deckAccessesViewModel)),
          ],
        ),
      );

  Widget _sharingEmail() => ListTile(
        title: TextField(
          keyboardType: TextInputType.emailAddress,
          controller: _textController,
          onChanged: (text) {
            setState(() {});
          },
          style: app_styles.primaryText,
          decoration: InputDecoration(
            hintText: context.l.emailAddressHint,
          ),
        ),
        trailing: DeckAccessDropdownWidget(
          value: _accessValue,
          filter: (access) => access != AccessType.owner && access != null,
          valueChanged: (access) => setState(() {
            _accessValue = access;
          }),
        ),
      );

  bool _isEmailCorrect() => _textController.text.contains('@');

  Future<void> _shareDeck(AccessType deckAccess, BuildContext context) async {
    if (!AppConfig.instance.sharingFeatureEnabled) {
      await UserMessages.showSimpleInfoDialog(
          context, context.l.featureNotAvailableUserMessage);
      return;
    }
    try {
      final uid = await userLookup(_textController.text.toString());
      if (uid == null) {
        if (await _inviteUser()) {
          _clearInputFields();
        }
        // Do not clear the field if user didn't send an invite.
        // Maybe user made a typo in email address and needs to correct it.
      } else {
        await _deckAccessesViewModel.shareDeck((DeckAccessModelBuilder()
              ..deckKey = widget._deck.key
              ..key = uid
              ..access = deckAccess
              ..email = _textController.text.toString())
            .build());
        // Clear input field after sharing the deck
        _clearInputFields();
      }
    } on SocketException catch (_) {
      UserMessages.showMessage(
          Scaffold.of(context), context.l.offlineUserMessage);
    } on HttpException catch (e, stackTrace) {
      UserMessages.showAndReportError(
        () => Scaffold.of(context),
        e,
        stackTrace: stackTrace,
        userFriendlyPrefix: context.l.serverUnavailableUserMessage,
      );
    } catch (e, stackTrace) {
      UserMessages.showAndReportError(
        () => Scaffold.of(context),
        e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<bool> _inviteUser() async {
    final locale = context.l;
    final inviteUser = await showSaveUpdatesDialog(
        context: context,
        changesQuestion: locale.appNotInstalledSharingDeck,
        yesAnswer: locale.send,
        noAnswer: MaterialLocalizations.of(context).cancelButtonLabel);
    if (inviteUser) {
      await sendInvite(context);
      return true;
    }
    return false;
  }

  void _clearInputFields() {
    _textController.clear();
  }
}

class DeckUsersWidget extends StatefulWidget {
  final DeckAccessesViewModel viewModel;

  const DeckUsersWidget(this.viewModel);

  @override
  State<StatefulWidget> createState() => _DeckUsersState();
}

class _DeckUsersState extends State<DeckUsersWidget> {
  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: Row(
              children: <Widget>[
                Text(
                  context.l.whoHasAccessLabel,
                  style: app_styles.secondaryText,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListAccessorWidget<DeckAccessModel>(
              list: widget.viewModel.list,
              itemBuilder: (context, item, index) => _buildUserAccessInfo(item),
              emptyMessageBuilder: () =>
                  EmptyListMessageWidget(context.l.emptyUserSharingList),
            ),
          )
        ],
      );

  Widget _buildUserAccessInfo(DeckAccessModel accessViewModel) {
    bool Function(AccessType) filter;
    if (accessViewModel.access == AccessType.owner) {
      filter = (access) => access == AccessType.owner;
    } else {
      filter = (access) => access != AccessType.owner;
    }

    final displayName = accessViewModel.displayName ?? accessViewModel.email;

    return ListTile(
      leading: (accessViewModel.photoUrl == null)
          ? null
          : CircleAvatar(
              backgroundImage: NetworkImage(accessViewModel.photoUrl),
            ),
      title: displayName == null
          ? const ProgressIndicatorWidget()
          : Text(
              displayName,
              style: app_styles.primaryText,
            ),
      trailing: DeckAccessDropdownWidget(
        value: accessViewModel.access,
        filter: filter,
        valueChanged: (access) => setState(() {
          if (access == null) {
            widget.viewModel.unshareDeck(accessViewModel.key);
          } else {
            widget.viewModel.shareDeck((DeckAccessModelBuilder()
                  ..deckKey = widget.viewModel.deck.key
                  ..key = accessViewModel.key
                  ..email = accessViewModel.email
                  ..access = access)
                .build());
          }
        }),
      ),
    );
  }
}
