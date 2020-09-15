import 'dart:async';
import 'dart:typed_data';

import 'package:built_collection/built_collection.dart';
import 'package:delern_flutter/models/base/list_accessor.dart';
import 'package:delern_flutter/models/base/stream_with_value.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/card_reply_model.dart';
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/fcm_model.dart';
import 'package:delern_flutter/models/scheduled_card_model.dart';
import 'package:delern_flutter/remote/auth.dart';
import 'package:delern_flutter/remote/database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';
import 'package:quiver/strings.dart';
import 'package:uuid/uuid.dart';

class UserProfile {
  final String photoUrl;
  final String displayName;

  /// User email, can be null.
  final String email;

  /// All providers (aka "linked accounts") for the current user. Empty for
  /// anonymously signed in.
  final Set<AuthProvider> providers;

  UserProfile({
    @required String photoUrl,
    @required String displayName,
    @required String email,
    @required this.providers,
  })  : photoUrl = isBlank(photoUrl) ? null : photoUrl,
        displayName = isBlank(displayName) ? null : displayName,
        email = isBlank(email) ? null : email;
}

/// An abstraction layer on top of FirebaseUser, plus data writing methods.
class User {
  final DataListAccessor<DeckModel> decks;

  /// Whether the user has been created during the last sign in. This flag stays
  /// until the user is changed or the app is restarted.
  final bool isNewUser;

  final DateTime createdAt;
  final String uid;
  final StreamWithValue<UserProfile> profile;

  User({
    @required this.uid,
    @required this.profile,
    @required this.createdAt,
    @required this.isNewUser,
  }) : decks = DeckModelListAccessor(uid);

  void dispose() => decks.close();

  bool get isAnonymous => profile.value.providers.isEmpty;

  Future<DeckModel> createDeck({
    @required DeckModel deckTemplate,
  }) async {
    final deck = deckTemplate.rebuild((b) => b..key = _newKey());
    final deckPath = 'decks/$uid/${deck.key}';
    final deckAccessPath = 'deck_access/${deck.key}/$uid';
    await Database().write(<String, dynamic>{
      '$deckPath/name': deck.name,
      '$deckPath/markdown': deck.markdown,
      '$deckPath/deckType': deck.type.toString().toUpperCase(),
      '$deckPath/accepted': deck.accepted,
      '$deckPath/lastSyncAt': deck.lastSyncAt.millisecondsSinceEpoch,
      '$deckPath/category': deck.category,
      '$deckPath/latestTagSelection': deck.latestTagSelection,
      '$deckPath/access': deck.access.toString(),
      '$deckAccessPath/access': deck.access.toString(),
      '$deckAccessPath/email': profile.value.email,
      '$deckAccessPath/displayName': profile.value.displayName,
      '$deckAccessPath/photoUrl': profile.value.photoUrl,
    });

    return deck;
  }

  Future<void> updateDeck({@required DeckModel deck}) {
    final deckPath = 'decks/$uid/${deck.key}';
    return Database().write(<String, dynamic>{
      '$deckPath/name': deck.name,
      '$deckPath/markdown': deck.markdown,
      '$deckPath/deckType': deck.type.toString().toUpperCase(),
      '$deckPath/accepted': deck.accepted,
      '$deckPath/lastSyncAt': deck.lastSyncAt.millisecondsSinceEpoch,
      '$deckPath/category': deck.category,
      '$deckPath/latestTagSelection': deck.latestTagSelection?.toList(),
    });
  }

  Future<void> deleteDeck({@required DeckModel deck}) async {
    // We want to enforce that the values in this map are all "null", because we
    // are only removing data.
    // ignore: prefer_void_to_null
    final updates = <String, Null>{
      'decks/$uid/${deck.key}': null,
      'learning/$uid/${deck.key}': null,
      'views/$uid/${deck.key}': null,
      if (deck.access == AccessType.owner) ...{
        'cards/${deck.key}': null,
        'deck_access/${deck.key}': null,
      },
    };

    if (deck.access == AccessType.owner) {
      // TODO(ksheremet): There's a possible problem here, which is,
      // deck.usersAccess is not yet loaded. We should have a mechanism
      // (perhaps, a Future?) that can wait until the data has arrived.
      final accessList = deck.usersAccess;
      accessList.value
          .forEach((a) => updates['decks/${a.key}/${deck.key}'] = null);
    }

    final frontImageUriList =
        deck.cards.value.expand((card) => card.frontImagesUri).toList();
    final backImageUriList =
        deck.cards.value.expand((card) => card.backImagesUri).toList();
    final allImagesUri = frontImageUriList..addAll(backImageUriList);
    await Database().write(updates);
    for (final imageUri in allImagesUri) {
      unawaited(deleteImage(imageUri));
    }
  }

  Future<void> createCard({
    @required CardModel card,
    bool addReversed = false,
  }) {
    final updates = <String, dynamic>{};

    void addCard({bool reverse = false}) {
      final cardKey = _newKey();
      final cardPath = 'cards/${card.deckKey}/$cardKey';
      final scheduledCardPath = 'learning/$uid/${card.deckKey}/$cardKey';
      // Put reversed card into a random position behind to avoid it showing
      // right next to the forward card.
      final repeatAt = ScheduledCardModel.computeRepeatAtBase(
        newCard: true,
        shuffle: reverse,
      );
      updates.addAll(<String, dynamic>{
        '$cardPath/front': reverse ? card.back : card.front,
        '$cardPath/back': reverse ? card.front : card.back,
        // Important note: we ask server to fill in the timestamp, but we do not
        // update it in our object immediately. Something trivial like
        // 'await get(...).first' would work most of the time. But when offline,
        // Firebase "lies" to the application, replacing ServerValue.TIMESTAMP
        // with phone's time, although later it saves to the server correctly.
        // For this reason, we should never *update* createdAt because we risk
        // changing it (see the note above), in which case Firebase Database
        // will reject the update.
        '$cardPath/createdAt': ServerValue.timestamp,
        '$cardPath/frontImagesUri': reverse
            ? card.backImagesUri.toList()
            : card.frontImagesUri.toList(),
        '$cardPath/backImagesUri': reverse
            ? card.frontImagesUri.toList()
            : card.backImagesUri.toList(),
        '$scheduledCardPath/level': 0,
        '$scheduledCardPath/repeatAt': repeatAt.millisecondsSinceEpoch,
      });
    }

    addCard();
    if (addReversed) {
      addCard(reverse: true);
    }

    return Database().write(updates);
  }

  Future<void> updateCard({@required CardModel card}) {
    final cardPath = 'cards/${card.deckKey}/${card.key}';
    return Database().write(<String, dynamic>{
      '$cardPath/front': card.front,
      '$cardPath/back': card.back,
      '$cardPath/frontImagesUri': card.frontImagesUri.toList(),
      '$cardPath/backImagesUri': card.backImagesUri.toList(),
    });
  }

  Future<void> deleteCard({@required CardModel card}) async {
    final imageUriList = card.frontImagesUri.toList()
      ..addAll(card.backImagesUri);
    // We want to make sure all values are set to `null`.
    // ignore: prefer_void_to_null
    await Database().write(<String, Null>{
      'cards/${card.deckKey}/${card.key}': null,
      'learning/$uid/${card.deckKey}/${card.key}': null,
    });
    for (final imageUri in imageUriList) {
      unawaited(deleteImage(imageUri));
    }
  }

  Future<void> learnCard({
    @required ScheduledCardModel unansweredScheduledCard,
    @required bool knows,
  }) {
    final cardReply =
        CardReplyModel.fromScheduledCard(unansweredScheduledCard, reply: knows);
    final scheduledCard = unansweredScheduledCard.answer(knows: knows);
    final scheduledCardPath =
        'learning/$uid/${scheduledCard.deckKey}/${scheduledCard.key}';
    final cardViewPath =
        'views/$uid/${scheduledCard.deckKey}/${scheduledCard.key}/${_newKey()}';
    return Database().write(<String, dynamic>{
      '$scheduledCardPath/level': scheduledCard.level,
      '$scheduledCardPath/repeatAt':
          scheduledCard.repeatAt.millisecondsSinceEpoch,
      '$cardViewPath/levelBefore': cardReply.levelBefore,
      '$cardViewPath/reply': cardReply.reply,
      '$cardViewPath/timestamp': cardReply.timestamp.millisecondsSinceEpoch,
    });
  }

  Future<void> unshareDeck({
    @required DeckModel deck,
    @required String shareWithUid,
  }) =>
      // We want to make sure all values are set to `null`.
      // ignore: prefer_void_to_null
      Database().write(<String, Null>{
        'deck_access/${deck.key}/$shareWithUid': null,
        'decks/$shareWithUid/${deck.key}': null,
      });

  Future<void> shareDeck({
    @required DeckModel deck,
    @required String shareWithUid,
    @required AccessType access,
    String sharedDeckName,
    String shareWithUserEmail,
  }) async {
    final deckAccessPath = 'deck_access/${deck.key}/$shareWithUid';
    final deckPath = 'decks/$shareWithUid/${deck.key}';
    final updates = <String, dynamic>{
      '$deckAccessPath/access': access.toString(),
      '$deckPath/access': access.toString(),
    };
    if (deck.usersAccess.getItem(shareWithUid).value == null) {
      // If there's no DeckAccess, assume the deck hasn't been shared yet, as
      // opposed to changing access level for a previously shared deck.
      updates.addAll(<String, dynamic>{
        '$deckPath/name': deck.name,
        '$deckPath/markdown': deck.markdown,
        '$deckPath/deckType': deck.type.toString().toUpperCase(),
        '$deckPath/accepted': false,
        '$deckPath/lastSyncAt': 0,
        '$deckPath/category': deck.category,
        // Do not save latestTagSelection because it's very individual.
        // Do not save displayName and photoUrl because these are populated by
        // Cloud functions.
        '$deckAccessPath/email': shareWithUserEmail,
      });
    }

    return Database().write(updates);
  }

  Future<void> addFCM({@required FCMModel fcm}) =>
      Database().write(<String, dynamic>{
        'fcm/$uid/${fcm.key}': {
          'name': fcm.name,
          'language': fcm.language,
        }
      });

  Future<void> cleanupOrphanedScheduledCard(ScheduledCardModel sc) =>
      // We want to make sure all values are set to `null`.
      // ignore: prefer_void_to_null
      Database().write(<String, Null>{
        'learning/$uid/${sc.deckKey}/${sc.key}': null,
      });

  /// Delete orphaned [ScheduledCardModel] of the deck and add missing ones.
  /// Returns `true` if any changes were made.
  Future<bool> syncScheduledCards(DeckModel deck) async {
    final cards = BuiltSet<String>.of(deck.cards.value.map((card) => card.key));
    final scheduledCards = BuiltSet<String>.of(
        deck.scheduledCards.value.map((scheduledCard) => scheduledCard.key));

    final updates = <String, dynamic>{};

    for (final key in cards.union(scheduledCards)) {
      final scheduledCardPath = 'learning/$uid/${deck.key}/$key';
      if (cards.contains(key)) {
        if (!scheduledCards.contains(key)) {
          updates['$scheduledCardPath/level'] = 0;
          updates['$scheduledCardPath/repeatAt'] =
              ScheduledCardModel.computeRepeatAtBase(
            newCard: true,
            shuffle: true,
          ).millisecondsSinceEpoch;
        }
      } else {
        updates[scheduledCardPath] = null;
      }
    }

    if (updates.isEmpty) {
      return false;
    }

    await Database().write(updates);
    return true;
  }

  String _newKey() => FirebaseDatabase.instance.reference().push().key;

  /// Delete image from FB Storage
  Future<void> deleteImage(String url) async =>
      (await FirebaseStorage.instance.getReferenceFromUrl(url)).delete();

  Future<String> uploadImage(Uint8List data, String deckKey) async =>
      (await (await FirebaseStorage.instance
                  .ref()
                  .child('cards')
                  .child(deckKey)
                  .child(Uuid().v1())
                  .putData(data)
                  .onComplete)
              .ref
              .getDownloadURL())
          .toString();
}
