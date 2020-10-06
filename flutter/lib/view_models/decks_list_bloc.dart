import 'dart:async';

import 'package:delern_flutter/models/base/list_accessor.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/remote/analytics/analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

class DecksListBloc {
  final User user;
  final Analytics analytics;

  ListAccessor<DeckModel> get decksList => _filteredDecksList;
  FilteredListAccessor<DeckModel> _filteredDecksList;

  set decksListFilter(Filter<DeckModel> newValue) =>
      _filteredDecksList.filter = newValue;
  Filter<DeckModel> get decksListFilter => _filteredDecksList.filter;

  DecksListBloc({@required this.user, @required this.analytics})
      : assert(user != null) {
    _filteredDecksList = FilteredListAccessor<DeckModel>(user.decks);
  }

  // TODO(ksheremet): Use BLoC
  Future<DeckModel> createDeck(DeckModel deck) {
    analytics.logDeckCreate();
    return user.createDeck(deckTemplate: deck);
  }

  /// Close all streams and release associated timer resources.
  void dispose() {
    _filteredDecksList.close();
  }

  // TODO(ksheremet): Use BLoC
  Future<void> deleteDeck(DeckModel deck) => user.deleteDeck(deck: deck);
}
