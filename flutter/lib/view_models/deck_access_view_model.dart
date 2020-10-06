import 'dart:async';

import 'package:delern_flutter/models/base/list_accessor.dart';
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/remote/analytics/analytics.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

class DeckAccessesViewModel {
  final DeckModel deck;
  final User user;
  final Analytics analytics;

  ListAccessor<DeckAccessModel> get list => _list;
  final FilteredListAccessor<DeckAccessModel> _list;

  set filter(Filter<DeckAccessModel> newValue) => _list.filter = newValue;
  Filter<DeckAccessModel> get filter => _list.filter;

  DeckAccessesViewModel({
    @required this.user,
    @required this.deck,
    @required this.analytics,
  })  : assert(user != null),
        assert(deck != null),
        _list = FilteredListAccessor<DeckAccessModel>(deck.usersAccess);

  Future<void> shareDeck(DeckAccessModel access) {
    assert(deck.key == access.deckKey);

    unawaited(analytics.logShare(deckId: access.deckKey, method: 'email'));
    return user.shareDeck(
        deck: deck,
        access: access.access,
        shareWithUid: access.key,
        shareWithUserEmail: access.email);
  }

  Future<void> unshareDeck(String shareWithUid) {
    unawaited(analytics.logUnshare(deckId: deck.key, method: 'email'));
    return user.unshareDeck(deck: deck, shareWithUid: shareWithUid);
  }
}
