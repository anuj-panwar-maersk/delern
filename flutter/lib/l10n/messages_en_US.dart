// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en_US locale. All the
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
  String get localeName => 'en_US';

  static m0(number) => "Answered: ${number}";

  static m1(numberOfCards, total) => "${numberOfCards} of ${total} to learn";

  static m2(date) =>
      "Next card to learn is suggested at ${date}. Would you like to continue learning anyway?";

  static m3(url) => "Could not launch url ${url}";

  static m4(deckName) => "Learning: ${deckName}";

  static m5(number) => "Cards in this folder: ${number}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function>{
        "accessibilityAddImageLabel":
            MessageLookupByLibrary.simpleMessage("Add Image"),
        "add": MessageLookupByLibrary.simpleMessage("Add"),
        "addCardTooltip": MessageLookupByLibrary.simpleMessage("Add Card"),
        "addCardsDeckMenu": MessageLookupByLibrary.simpleMessage("Add Cards"),
        "addDeckTooltip": MessageLookupByLibrary.simpleMessage("Add Deck"),
        "addReminder": MessageLookupByLibrary.simpleMessage("Add Reminder"),
        "anonymous": MessageLookupByLibrary.simpleMessage("Anonymous"),
        "answeredCards": m0,
        "appNotInstalledSharingDeck": MessageLookupByLibrary.simpleMessage(
            "This user hasn\'t installed Delern yet. Do you want to sent an invite?"),
        "backSideHint": MessageLookupByLibrary.simpleMessage("Back side:"),
        "basicDeckType": MessageLookupByLibrary.simpleMessage("Basic"),
        "canEdit": MessageLookupByLibrary.simpleMessage("Can Edit"),
        "canView": MessageLookupByLibrary.simpleMessage("Can View"),
        "cardAddedUserMessage":
            MessageLookupByLibrary.simpleMessage("Card was added"),
        "cardAndReversedAddedUserMessage": MessageLookupByLibrary.simpleMessage(
            "Card and reversed card were added"),
        "cardDeletedUserMessage":
            MessageLookupByLibrary.simpleMessage("Card was deleted"),
        "cardsFontSize":
            MessageLookupByLibrary.simpleMessage("Cards font size"),
        "cardsToLearnLabel": m1,
        "chooseTimeOfDayLabel":
            MessageLookupByLibrary.simpleMessage("Choose time of day"),
        "chosenTimeExistsError":
            MessageLookupByLibrary.simpleMessage("Chosen time already exists."),
        "continueAnonymously":
            MessageLookupByLibrary.simpleMessage("Continue as a Guest"),
        "continueEditingQuestion": MessageLookupByLibrary.simpleMessage(
            "You have unsaved changes. Would you like to continue editing?"),
        "continueLearningQuestion": m2,
        "couldNotLaunchUrl": m3,
        "createDeckTooltip":
            MessageLookupByLibrary.simpleMessage("Create deck"),
        "deck": MessageLookupByLibrary.simpleMessage("Deck"),
        "deckDeletedUserMessage":
            MessageLookupByLibrary.simpleMessage("Deck was deleted"),
        "deckSettingsTooltip":
            MessageLookupByLibrary.simpleMessage("Settings of deck"),
        "deckType": MessageLookupByLibrary.simpleMessage("Deck Type"),
        "decksRefreshed":
            MessageLookupByLibrary.simpleMessage("Decks refreshed"),
        "defaultNotification":
            MessageLookupByLibrary.simpleMessage("Praktice makes perfect"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteCardQuestion": MessageLookupByLibrary.simpleMessage(
            "Do you want to delete this card?"),
        "deleteCardTooltip":
            MessageLookupByLibrary.simpleMessage("Delete card"),
        "deleteDeckButton": MessageLookupByLibrary.simpleMessage("Delete Deck"),
        "deleteDeckOwnerAccessQuestion": MessageLookupByLibrary.simpleMessage(
            "The deck, all cards and learning history will be removed.\n\nIf you have shared this deck with other users, it will also be removed from all users it is shared with. Do you want to delete the deck?"),
        "deleteDeckWriteReadAccessQuestion": MessageLookupByLibrary.simpleMessage(
            "The deck will be removed from your account only, all cards and learning history will remain with the owner and other users. Do you want to delete the deck?"),
        "discard": MessageLookupByLibrary.simpleMessage("Discard"),
        "doNotKnowCardTooltip":
            MessageLookupByLibrary.simpleMessage("I don\'t know"),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "editCardTooltip": MessageLookupByLibrary.simpleMessage("Edit card"),
        "editCardsDeckMenu": MessageLookupByLibrary.simpleMessage("Edit Cards"),
        "emailAddressHint":
            MessageLookupByLibrary.simpleMessage("Email address"),
        "emptyCardsList":
            MessageLookupByLibrary.simpleMessage("Add your cards"),
        "emptyDecksList":
            MessageLookupByLibrary.simpleMessage("Add your decks"),
        "emptyUserSharingList":
            MessageLookupByLibrary.simpleMessage("Share your deck"),
        "errorUserMessage": MessageLookupByLibrary.simpleMessage("Error: "),
        "featureNotAvailableUserMessage": MessageLookupByLibrary.simpleMessage(
            "This feature is currently not available. Please try it later."),
        "flip": MessageLookupByLibrary.simpleMessage("flip"),
        "frontSideHint": MessageLookupByLibrary.simpleMessage("Front side:"),
        "germanDeckType": MessageLookupByLibrary.simpleMessage("German"),
        "imageFromGalleryLabel":
            MessageLookupByLibrary.simpleMessage("From Gallery"),
        "imageFromPhotoLabel":
            MessageLookupByLibrary.simpleMessage("Take Photo"),
        "imageLoadingErrorUserMessage": MessageLookupByLibrary.simpleMessage(
            "Error during loading the image. Please try it later."),
        "installEmailApp":
            MessageLookupByLibrary.simpleMessage("Please install Email App"),
        "intervalLearning":
            MessageLookupByLibrary.simpleMessage("Interval Learning"),
        "intervalLearningTooltip": MessageLookupByLibrary.simpleMessage(
            "Start learning cards ordered for interval learning"),
        "inviteToAppMessage": MessageLookupByLibrary.simpleMessage(
            "I invite you to install Delern, a spaced repetition learning app, which will allow you to learn quickly and easily!\n\nProceed to install it from:\nGoogle Play: https://play.google.com/store/apps/details?id=org.dasfoo.delern\nApp Store: https://itunes.apple.com/us/app/delern/id1435734822\n\nAfter install, follow Delern latest news on:\nFacebook: https://fb.me/das.delern\nLinkedIn: https://www.linkedin.com/company/delern\nVK: https://vk.com/delern\nTwitter: https://twitter.com/dasdelern"),
        "knowCardTooltip": MessageLookupByLibrary.simpleMessage("I know"),
        "later": MessageLookupByLibrary.simpleMessage("Later"),
        "learnCardsNotificationSuggestion":
            MessageLookupByLibrary.simpleMessage(
                "Would you like to schedule notifications to learn cards?"),
        "learning": m4,
        "legacyAcceptanceLabel": MessageLookupByLibrary.simpleMessage(
            "By using this app you accept the "),
        "legacyPartsConnector":
            MessageLookupByLibrary.simpleMessage(" and the  "),
        "listOFDecksScreenTitle":
            MessageLookupByLibrary.simpleMessage("List of decks"),
        "menuTooltip": MessageLookupByLibrary.simpleMessage("Menu"),
        "navigationDrawerAbout": MessageLookupByLibrary.simpleMessage("About"),
        "navigationDrawerContactUs":
            MessageLookupByLibrary.simpleMessage("Contact Us"),
        "navigationDrawerInviteFriends":
            MessageLookupByLibrary.simpleMessage("Invite Friends"),
        "navigationDrawerSignIn":
            MessageLookupByLibrary.simpleMessage("Sign In"),
        "navigationDrawerSignOut":
            MessageLookupByLibrary.simpleMessage("Sign Out"),
        "newName": MessageLookupByLibrary.simpleMessage("New name"),
        "no": MessageLookupByLibrary.simpleMessage("no"),
        "noAccess": MessageLookupByLibrary.simpleMessage("No access"),
        "noAddingWithReadAccessUserMessage":
            MessageLookupByLibrary.simpleMessage(
                "You cannot add cards with a read access."),
        "noDeletingWithReadAccessUserMessage":
            MessageLookupByLibrary.simpleMessage(
                "You cannot delete card with a read access."),
        "noEditingWithReadAccessUserMessage":
            MessageLookupByLibrary.simpleMessage(
                "You cannot edit card with a read access."),
        "noSharingAccessUserMessage": MessageLookupByLibrary.simpleMessage(
            "Only owner of deck can share it."),
        "noUpdates": MessageLookupByLibrary.simpleMessage("No updates"),
        "notificationInSettingsSchedule": MessageLookupByLibrary.simpleMessage(
            "You can also do it later in app settings."),
        "notificationPurpose": MessageLookupByLibrary.simpleMessage(
            "Notifications for learning cards"),
        "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
        "numberOfCards": m5,
        "offlineProfileTooltip":
            MessageLookupByLibrary.simpleMessage("Profile (you are offline)"),
        "offlineUserMessage": MessageLookupByLibrary.simpleMessage(
            "You are offline, please try it later"),
        "ok": MessageLookupByLibrary.simpleMessage("ok"),
        "other": MessageLookupByLibrary.simpleMessage("other"),
        "owner": MessageLookupByLibrary.simpleMessage("Owner"),
        "peopleLabel": MessageLookupByLibrary.simpleMessage("People"),
        "privacyPolicy": MessageLookupByLibrary.simpleMessage("Privacy Policy"),
        "profileTooltip": MessageLookupByLibrary.simpleMessage("Profile"),
        "rename": MessageLookupByLibrary.simpleMessage("Rename"),
        "renameDeck": MessageLookupByLibrary.simpleMessage("Rename folder"),
        "reversedCardLabel": MessageLookupByLibrary.simpleMessage(
            "Add a reversed copy of this card"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "saveChangesQuestion": MessageLookupByLibrary.simpleMessage(
            "Do you want to save changes?"),
        "scrollToStartLabel":
            MessageLookupByLibrary.simpleMessage("Scroll to the beginning"),
        "searchHint": MessageLookupByLibrary.simpleMessage("Search..."),
        "send": MessageLookupByLibrary.simpleMessage("Send"),
        "serverUnavailableUserMessage": MessageLookupByLibrary.simpleMessage(
            "Server temporarily unavailable, please try again later"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "settingsDeckMenu": MessageLookupByLibrary.simpleMessage("Settings"),
        "shareDeckMenu": MessageLookupByLibrary.simpleMessage("Share"),
        "shareDeckTooltip": MessageLookupByLibrary.simpleMessage("Share deck"),
        "shuffleTooltip": MessageLookupByLibrary.simpleMessage("Shuffle cards"),
        "signInAccountExistWithDifferentCredentialWarning":
            MessageLookupByLibrary.simpleMessage(
                "You have previously signed in to the application using this email, but with a different provider (e.g. Google instead of Facebook). Please sign in with the same provider you have used before."),
        "signInCredentialAlreadyInUseWarning": MessageLookupByLibrary.simpleMessage(
            "The account you have chosen is already registered with the application. If you continue with sign in, all data that you have created anonymously will be lost. Would you like to continue?"),
        "signInScreenOr": MessageLookupByLibrary.simpleMessage("or"),
        "signInWithApple":
            MessageLookupByLibrary.simpleMessage("Sign in with Apple"),
        "signInWithFacebook":
            MessageLookupByLibrary.simpleMessage("Sign in with Facebook"),
        "signInWithGoogle":
            MessageLookupByLibrary.simpleMessage("Sign in with Google"),
        "signInWithLabel":
            MessageLookupByLibrary.simpleMessage("Sign in with:"),
        "splashScreenFeatures": MessageLookupByLibrary.simpleMessage(
            "All the data will be saved in the Cloud and synchronized across all your devices. You can also share cards with your friends and colleagues"),
        "swissDeckType": MessageLookupByLibrary.simpleMessage("Swiss"),
        "termsOfService":
            MessageLookupByLibrary.simpleMessage("Terms of Service"),
        "unknownDeckType": MessageLookupByLibrary.simpleMessage("Unknown"),
        "viewLearning":
            MessageLookupByLibrary.simpleMessage("One after another"),
        "viewLearningTooltip": MessageLookupByLibrary.simpleMessage(
            "Start learning all cards in any order"),
        "whoHasAccessLabel":
            MessageLookupByLibrary.simpleMessage("Who has access"),
        "yes": MessageLookupByLibrary.simpleMessage("Yes")
      };
}
