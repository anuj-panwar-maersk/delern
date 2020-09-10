// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de_DE locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'de_DE';

  static m0(number) => "Beantwortet: ${number}";

  static m1(numberOfCards, total) => "${numberOfCards} von ${total} zu lernen";

  static m2(date) =>
      "Die nächste zu lernende Karte wird am ${date} vorgeschlagen. Möchtest du trotzdem weiter lernen?";

  static m3(url) => "Konnte url nicht starten ${url}";

  static m4(deckName) => "Lernen: ${deckName}";

  static m5(number) => "Karten im Lernset: ${number}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function>{
        "accessibilityAddImageLabel":
            MessageLookupByLibrary.simpleMessage("Bild hinzufügen"),
        "add": MessageLookupByLibrary.simpleMessage("Hinzufügen"),
        "addCardTooltip":
            MessageLookupByLibrary.simpleMessage("Karte hinzufügen"),
        "addCardsDeckMenu":
            MessageLookupByLibrary.simpleMessage("Karten hinzufügen"),
        "addDeckTooltip":
            MessageLookupByLibrary.simpleMessage("Lernset hinzufügen"),
        "anonymous": MessageLookupByLibrary.simpleMessage("Anonymous"),
        "answeredCards": m0,
        "appNotInstalledSharingDeck": MessageLookupByLibrary.simpleMessage(
            "Dieser Benutzer hat Delern noch nicht installiert. Möchtest du eine Einladung verschicken?"),
        "backSideHint": MessageLookupByLibrary.simpleMessage("Rückseite:"),
        "basicDeckType": MessageLookupByLibrary.simpleMessage("Basis"),
        "canEdit": MessageLookupByLibrary.simpleMessage("Kann bearbeiten"),
        "canView": MessageLookupByLibrary.simpleMessage("Kann anschauen"),
        "cardAddedUserMessage":
            MessageLookupByLibrary.simpleMessage("Karte wurde hinzugefügt"),
        "cardAndReversedAddedUserMessage": MessageLookupByLibrary.simpleMessage(
            "Karte und umgekehrte Karte wurden hinzugefügt"),
        "cardDeletedUserMessage":
            MessageLookupByLibrary.simpleMessage("Karte wurde gelöscht"),
        "cardsToLearnLabel": m1,
        "continueAnonymously":
            MessageLookupByLibrary.simpleMessage("Als Gast fortfahren"),
        "continueEditingQuestion": MessageLookupByLibrary.simpleMessage(
            "Du hast ungespeicherte Änderungen. Möchtest du die Bearbeitung fortsetzen?"),
        "continueLearningQuestion": m2,
        "couldNotLaunchUrl": m3,
        "createDeckTooltip":
            MessageLookupByLibrary.simpleMessage("Lernset erstellen"),
        "deck": MessageLookupByLibrary.simpleMessage("Lernset"),
        "deckDeletedUserMessage":
            MessageLookupByLibrary.simpleMessage("Lernset wurde gelöscht"),
        "deckSettingsTooltip":
            MessageLookupByLibrary.simpleMessage("Einstellungen des Lernsets"),
        "deckType": MessageLookupByLibrary.simpleMessage("Lernset Typ"),
        "decksRefreshed":
            MessageLookupByLibrary.simpleMessage("Lernsets erneuert"),
        "delete": MessageLookupByLibrary.simpleMessage("Löschen"),
        "deleteCardQuestion": MessageLookupByLibrary.simpleMessage(
            "Möchtest diese Karte löschen?"),
        "deleteCardTooltip":
            MessageLookupByLibrary.simpleMessage("Karte löschen"),
        "deleteDeckButton":
            MessageLookupByLibrary.simpleMessage("Lernset löschen"),
        "deleteDeckOwnerAccessQuestion": MessageLookupByLibrary.simpleMessage(
            "Dieses Lernset, alle Karten und die Lernhistorie werden entfernt. Wenn du dieses Lernset mit anderen Benutzern geteilt hast, wird es auch von allen Benutzern, mit denen es geteilt wird, entfernt. Möchtest du das Lernset löschen?"),
        "deleteDeckWriteReadAccessQuestion": MessageLookupByLibrary.simpleMessage(
            "Das Lernset wird nur von deinem Konto entfernt, alle Karten und die Lernhistorie verbleiben beim Besitzer und anderen Benutzern. Möchtest du das Lernset löschen?"),
        "discard": MessageLookupByLibrary.simpleMessage("Verwerfen"),
        "doNotKnowCardTooltip":
            MessageLookupByLibrary.simpleMessage("Ich weiß es nicht."),
        "edit": MessageLookupByLibrary.simpleMessage("Bearbeiten"),
        "editCardTooltip":
            MessageLookupByLibrary.simpleMessage("Karte bearbeiten"),
        "editCardsDeckMenu":
            MessageLookupByLibrary.simpleMessage("Karten bearbeiten"),
        "emailAddressHint":
            MessageLookupByLibrary.simpleMessage("E-Mail Adresse"),
        "emptyCardsList":
            MessageLookupByLibrary.simpleMessage("Füge deine Karten hinzu"),
        "emptyDecksList":
            MessageLookupByLibrary.simpleMessage("Füge deine Lernsets hinzu"),
        "emptyUserSharingList":
            MessageLookupByLibrary.simpleMessage("Teile deinen Lernset"),
        "errorUserMessage": MessageLookupByLibrary.simpleMessage("Fehler: "),
        "featureNotAvailableUserMessage": MessageLookupByLibrary.simpleMessage(
            "Diese Funktion ist derzeit nicht verfügbar. Bitte versuche es später."),
        "flip": MessageLookupByLibrary.simpleMessage("flip"),
        "frontSideHint": MessageLookupByLibrary.simpleMessage("Frontseite:"),
        "germanDeckType": MessageLookupByLibrary.simpleMessage("Deutsch"),
        "imageFromGalleryLabel":
            MessageLookupByLibrary.simpleMessage("Von Galerie"),
        "imageFromPhotoLabel":
            MessageLookupByLibrary.simpleMessage("Foto aufnehmen"),
        "imageLoadingErrorUserMessage": MessageLookupByLibrary.simpleMessage(
            "Fehler beim Laden des Bildes. Bitte versuche es später."),
        "installEmailApp": MessageLookupByLibrary.simpleMessage(
            "Bitte installiere die E-Mail-App"),
        "intervalLearning": MessageLookupByLibrary.simpleMessage("Intervall"),
        "intervalLearningTooltip": MessageLookupByLibrary.simpleMessage(
            "Für das Intervall-Lernen bestellte Lernkarten starten"),
        "inviteToAppMessage": MessageLookupByLibrary.simpleMessage(
            "Ich lade dich ein, Delern zu installieren, eine App für das Lernen mit Intervallwiederholungen, die es dir ermöglicht, schnell und einfach zu lernen!\n\nInstalliere es von:\nGoogle Play: https://play.google.com/store/apps/details?id=org.dasfoo.delern\nApp Store: https://itunes.apple.com/us/app/delern/id1435734822\n\nNach der Installation folgen Sie den neuesten Nachrichten von Delern auf:\nFacebook: https://fb.me/das.delern\nLinkedIn: https://www.linkedin.com/company/delern\nVK: https://vk.com/delern\nTwitter: https://twitter.com/dasdelern"),
        "knowCardTooltip": MessageLookupByLibrary.simpleMessage("Ich weiß"),
        "learning": m4,
        "legacyAcceptanceLabel": MessageLookupByLibrary.simpleMessage(
            "Mit der Benutzung dieser App akzeptierst du die "),
        "legacyPartsConnector":
            MessageLookupByLibrary.simpleMessage(" und die  "),
        "listOFDecksScreenTitle":
            MessageLookupByLibrary.simpleMessage("Lernsets"),
        "markdown": MessageLookupByLibrary.simpleMessage("Markdown"),
        "menuTooltip": MessageLookupByLibrary.simpleMessage("Menu"),
        "navigationDrawerAbout":
            MessageLookupByLibrary.simpleMessage("Über uns"),
        "navigationDrawerContactUs":
            MessageLookupByLibrary.simpleMessage("Kontaktiere uns"),
        "navigationDrawerInviteFriends":
            MessageLookupByLibrary.simpleMessage("Lade Freunde ein"),
        "navigationDrawerSignIn":
            MessageLookupByLibrary.simpleMessage("Anmelden"),
        "navigationDrawerSignOut":
            MessageLookupByLibrary.simpleMessage("Abmelden"),
        "no": MessageLookupByLibrary.simpleMessage("nein"),
        "noAccess": MessageLookupByLibrary.simpleMessage("Kein Zugang"),
        "noAddingWithReadAccessUserMessage":
            MessageLookupByLibrary.simpleMessage(
                "Du kanst keine Karten mit Lesezugriff hinzufügen."),
        "noDeletingWithReadAccessUserMessage":
            MessageLookupByLibrary.simpleMessage(
                "Du kanst keine Karte mit Lesezugriff löschen."),
        "noEditingWithReadAccessUserMessage":
            MessageLookupByLibrary.simpleMessage(
                "Du kanst keine Karte mit Lesezugriff bearbeiten."),
        "noSharingAccessUserMessage": MessageLookupByLibrary.simpleMessage(
            "Nur der Besitzer eines Lernsets kann es teilen."),
        "noUpdates":
            MessageLookupByLibrary.simpleMessage("Keine Aktualisierungen"),
        "numberOfCards": m5,
        "offlineProfileTooltip":
            MessageLookupByLibrary.simpleMessage("Profil (du bist offline)"),
        "offlineUserMessage": MessageLookupByLibrary.simpleMessage(
            "Du bist offline, bitte versuche es später"),
        "other": MessageLookupByLibrary.simpleMessage("andere"),
        "owner": MessageLookupByLibrary.simpleMessage("Besitzer"),
        "peopleLabel": MessageLookupByLibrary.simpleMessage("Personen"),
        "privacyPolicy":
            MessageLookupByLibrary.simpleMessage("Datenschutzerklärung"),
        "profileTooltip": MessageLookupByLibrary.simpleMessage("Profil"),
        "reversedCardLabel": MessageLookupByLibrary.simpleMessage(
            "Fügen Sie eine umgekehrte Kopie dieser Karte hinzu"),
        "save": MessageLookupByLibrary.simpleMessage("Speichern"),
        "saveChangesQuestion": MessageLookupByLibrary.simpleMessage(
            "Möchtest Änderungen speichern?"),
        "scrollToStartLabel":
            MessageLookupByLibrary.simpleMessage("Zum Anfang blättern"),
        "searchHint": MessageLookupByLibrary.simpleMessage("Suche..."),
        "send": MessageLookupByLibrary.simpleMessage("Senden"),
        "serverUnavailableUserMessage": MessageLookupByLibrary.simpleMessage(
            "Server vorübergehend nicht verfügbar, bitte versuche es später noch einmal"),
        "settingsDeckMenu":
            MessageLookupByLibrary.simpleMessage("Einstellungen"),
        "shareDeckMenu": MessageLookupByLibrary.simpleMessage("Teilen"),
        "shareDeckTooltip":
            MessageLookupByLibrary.simpleMessage("Lernset teilen"),
        "shuffleTooltip":
            MessageLookupByLibrary.simpleMessage("Karten mischen"),
        "signInAccountExistWithDifferentCredentialWarning":
            MessageLookupByLibrary.simpleMessage(
                "Du hast dich zuvor mit dieser E-Mail bei der Anwendung angemeldet, jedoch bei einem anderen Anbieter (z.B. Google statt Facebook). Bitte melden dich bei demselben Provider an, den du zuvor verwendet hast."),
        "signInCredentialAlreadyInUseWarning": MessageLookupByLibrary.simpleMessage(
            "Das von dir gewählte Konto ist bereits bei der Anmeldung registriert. Wenn du mit der Anmeldung weitermachst, gehen alle Daten, die du anonym erstellt hast, verloren. Möchtest du fortfahren?"),
        "signInScreenOr": MessageLookupByLibrary.simpleMessage("oder"),
        "signInWithFacebook": MessageLookupByLibrary.simpleMessage("Facebook"),
        "signInWithGoogle": MessageLookupByLibrary.simpleMessage("Google"),
        "signInWithLabel": MessageLookupByLibrary.simpleMessage("Anmelde mit:"),
        "splashScreenFeatures": MessageLookupByLibrary.simpleMessage(
            "Alle Daten werden in der Cloud gespeichert und über alle Ihre Geräte hinweg synchronisiert. Du kannst Karten auch mit deinen Freunden und Kollegen teilen."),
        "swissDeckType": MessageLookupByLibrary.simpleMessage("Schweizerisch"),
        "termsOfService":
            MessageLookupByLibrary.simpleMessage("Nutzungsbedingungen"),
        "unknownDeckType": MessageLookupByLibrary.simpleMessage("Unbekannt"),
        "viewLearning": MessageLookupByLibrary.simpleMessage("Ansehen"),
        "viewLearningTooltip": MessageLookupByLibrary.simpleMessage(
            "Lerne alle Karten in beliebiger Reihenfolge zu"),
        "whoHasAccessLabel":
            MessageLookupByLibrary.simpleMessage("Wer hat Zugang"),
        "yes": MessageLookupByLibrary.simpleMessage("Ja")
      };
}
