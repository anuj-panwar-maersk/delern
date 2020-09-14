// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru_RU locale. All the
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
  String get localeName => 'ru_RU';

  static m0(number) => "Отвечено: ${number}";

  static m1(numberOfCards, total) => "${numberOfCards} из ${total} на изучение";

  static m2(date) =>
      "Следующая карточка рекомендуется к повторению ${date}. Вы хотите продолжить изучение?";

  static m3(url) => "Не удалось запустить ссылку ${url}";

  static m4(deckName) => "Изучение: ${deckName}";

  static m5(number) => "Карточек в списке: ${number}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function>{
        "accessibilityAddImageLabel":
            MessageLookupByLibrary.simpleMessage("Добавить картинку"),
        "add": MessageLookupByLibrary.simpleMessage("Добавить"),
        "addCardTooltip":
            MessageLookupByLibrary.simpleMessage("Добавить карточку"),
        "addCardsDeckMenu":
            MessageLookupByLibrary.simpleMessage("Добавить карточки"),
        "addDeckTooltip":
            MessageLookupByLibrary.simpleMessage("Добавить список"),
        "anonymous":
            MessageLookupByLibrary.simpleMessage("Анонимный пользователь"),
        "answeredCards": m0,
        "appNotInstalledSharingDeck": MessageLookupByLibrary.simpleMessage(
            "Данный пользователь еще не установил Delern. Отправить приглашение?"),
        "backSideHint":
            MessageLookupByLibrary.simpleMessage("Обратная сторона:"),
        "basicDeckType": MessageLookupByLibrary.simpleMessage("Базовый"),
        "canEdit": MessageLookupByLibrary.simpleMessage("Может редактировать"),
        "canView": MessageLookupByLibrary.simpleMessage("Может просматривать"),
        "cardAddedUserMessage":
            MessageLookupByLibrary.simpleMessage("Карточка добавлена"),
        "cardAndReversedAddedUserMessage": MessageLookupByLibrary.simpleMessage(
            "Карточка и обратная карточка были добавлены"),
        "cardDeletedUserMessage":
            MessageLookupByLibrary.simpleMessage("Карточка удалена"),
        "cardsToLearnLabel": m1,
        "continueAnonymously":
            MessageLookupByLibrary.simpleMessage("Продолжить как гость"),
        "continueEditingQuestion": MessageLookupByLibrary.simpleMessage(
            "У Вас есть несохраненные изменения. Хотите продолжить редактирование?"),
        "continueLearningQuestion": m2,
        "couldNotLaunchUrl": m3,
        "createDeckTooltip":
            MessageLookupByLibrary.simpleMessage("Создать список"),
        "deck": MessageLookupByLibrary.simpleMessage("Список"),
        "deckDeletedUserMessage":
            MessageLookupByLibrary.simpleMessage("Список был удален"),
        "deckSettingsTooltip":
            MessageLookupByLibrary.simpleMessage("Настройки списка"),
        "deckType": MessageLookupByLibrary.simpleMessage("Тип списка"),
        "decksRefreshed":
            MessageLookupByLibrary.simpleMessage("Списки обновлены"),
        "delete": MessageLookupByLibrary.simpleMessage("Удалить"),
        "deleteCardQuestion": MessageLookupByLibrary.simpleMessage(
            "Вы хотите удалить эту карточку?"),
        "deleteCardTooltip":
            MessageLookupByLibrary.simpleMessage("Удалить карточку"),
        "deleteDeckButton":
            MessageLookupByLibrary.simpleMessage("Удалить список"),
        "deleteDeckOwnerAccessQuestion": MessageLookupByLibrary.simpleMessage(
            "Список, все карточки и история изучения будут удалены.\n\nЕсли вы поделились списком с другими пользователями, он также будет удален у них. Вы хотите удалить список?"),
        "deleteDeckWriteReadAccessQuestion": MessageLookupByLibrary.simpleMessage(
            "Список будет удален с Вашего аккаунта, все карточки и история изучения останутся у владельца списка и остальных пользователей. Вы хотите удалить список?"),
        "discard": MessageLookupByLibrary.simpleMessage("Отменить изменения"),
        "doNotKnowCardTooltip":
            MessageLookupByLibrary.simpleMessage("Я не знаю"),
        "edit": MessageLookupByLibrary.simpleMessage("Редактировать"),
        "editCardTooltip":
            MessageLookupByLibrary.simpleMessage("Редактировать карточку"),
        "editCardsDeckMenu":
            MessageLookupByLibrary.simpleMessage("Редактировать карточки"),
        "emailAddressHint":
            MessageLookupByLibrary.simpleMessage("Адрес электронной почты"),
        "emptyCardsList":
            MessageLookupByLibrary.simpleMessage("Добавьте карточки"),
        "emptyDecksList":
            MessageLookupByLibrary.simpleMessage("Добавьте списки"),
        "emptyUserSharingList":
            MessageLookupByLibrary.simpleMessage("Поделитесь списком"),
        "errorUserMessage":
            MessageLookupByLibrary.simpleMessage("Произошла ошибка: "),
        "featureNotAvailableUserMessage": MessageLookupByLibrary.simpleMessage(
            "Эта функция в данный момент недоступна. Пожалуйста попробуйте позже."),
        "flip": MessageLookupByLibrary.simpleMessage("перевернуть"),
        "frontSideHint":
            MessageLookupByLibrary.simpleMessage("Передняя сторона:"),
        "germanDeckType": MessageLookupByLibrary.simpleMessage("Немецкий"),
        "imageFromGalleryLabel":
            MessageLookupByLibrary.simpleMessage("Из Галереи"),
        "imageFromPhotoLabel":
            MessageLookupByLibrary.simpleMessage("Сфотографировать"),
        "imageLoadingErrorUserMessage": MessageLookupByLibrary.simpleMessage(
            "Ошибка при загрузке картинки. Пожалуйста попробуйте позже."),
        "installEmailApp": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста установите приложение Электронной Почты"),
        "intervalLearning":
            MessageLookupByLibrary.simpleMessage("Интервальное"),
        "intervalLearningTooltip": MessageLookupByLibrary.simpleMessage(
            "Начать изучение карточек в порядке интервального обучения"),
        "inviteToAppMessage": MessageLookupByLibrary.simpleMessage(
            "Я приглашаю Вас установить Delern, систему интервального изучения, которая позволяет изучать быстро и легко!\n\nПройдите по ссылке чтобы установить из\nGoogle Play: https://play.google.com/store/apps/details?id=org.dasfoo.delern\nApp Store: https://itunes.apple.com/us/app/delern/id1435734822\n\nПосле установки, следите за последними новостями Delern:\nFacebook: https://fb.me/das.delern\nLinkedIn: https://www.linkedin.com/company/delern\nVK: https://vk.com/delern\nTwitter: https://twitter.com/dasdelern"),
        "knowCardTooltip": MessageLookupByLibrary.simpleMessage("Я знаю"),
        "learning": m4,
        "legacyAcceptanceLabel": MessageLookupByLibrary.simpleMessage(
            "При использовании приложения Вы соглашаетесь с  "),
        "legacyPartsConnector": MessageLookupByLibrary.simpleMessage(" и  "),
        "listOFDecksScreenTitle":
            MessageLookupByLibrary.simpleMessage("Список папок"),
        "markdown": MessageLookupByLibrary.simpleMessage("Маркдаун"),
        "menuTooltip": MessageLookupByLibrary.simpleMessage("Меню"),
        "navigationDrawerAbout":
            MessageLookupByLibrary.simpleMessage("О приложении"),
        "navigationDrawerContactUs":
            MessageLookupByLibrary.simpleMessage("Связаться с нами"),
        "navigationDrawerInviteFriends":
            MessageLookupByLibrary.simpleMessage("Пригласить друзей"),
        "navigationDrawerSignIn": MessageLookupByLibrary.simpleMessage("Войти"),
        "navigationDrawerSignOut":
            MessageLookupByLibrary.simpleMessage("Выход"),
        "no": MessageLookupByLibrary.simpleMessage("нет"),
        "noAccess": MessageLookupByLibrary.simpleMessage("Нет доступа"),
        "noAddingWithReadAccessUserMessage":
            MessageLookupByLibrary.simpleMessage(
                "Вы не можете добавлять карточки с доступом на чтение."),
        "noDeletingWithReadAccessUserMessage":
            MessageLookupByLibrary.simpleMessage(
                "Вы не можете удалить карточки с доступом на чтение."),
        "noEditingWithReadAccessUserMessage":
            MessageLookupByLibrary.simpleMessage(
                "Вы не можете редактировать карточки с доступом на чтение."),
        "noSharingAccessUserMessage": MessageLookupByLibrary.simpleMessage(
            "Только владелец может поделиться списком."),
        "noUpdates": MessageLookupByLibrary.simpleMessage("Нет обновлений"),
        "numberOfCards": m5,
        "offlineProfileTooltip":
            MessageLookupByLibrary.simpleMessage("Профиль (Вы не в сети)"),
        "offlineUserMessage": MessageLookupByLibrary.simpleMessage(
            "Нет сети, пожалуйста, попробуйте позже"),
        "other": MessageLookupByLibrary.simpleMessage("другие"),
        "owner": MessageLookupByLibrary.simpleMessage("Владелец"),
        "peopleLabel": MessageLookupByLibrary.simpleMessage("Люди"),
        "privacyPolicy":
            MessageLookupByLibrary.simpleMessage("Политика Конфиденциальности"),
        "profileTooltip": MessageLookupByLibrary.simpleMessage("Профиль"),
        "reversedCardLabel": MessageLookupByLibrary.simpleMessage(
            "Добавить обратную копию этой карточки"),
        "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
        "saveChangesQuestion": MessageLookupByLibrary.simpleMessage(
            "Вы хотите сохранить изменения?"),
        "scrollToStartLabel":
            MessageLookupByLibrary.simpleMessage("Прокрутить до начала"),
        "searchHint": MessageLookupByLibrary.simpleMessage("Поиск..."),
        "send": MessageLookupByLibrary.simpleMessage("Отправить"),
        "serverUnavailableUserMessage": MessageLookupByLibrary.simpleMessage(
            "Сервер временно недоступен, пожалуйста, попробуйте позже"),
        "settingsDeckMenu": MessageLookupByLibrary.simpleMessage("Настройки"),
        "shareDeckMenu": MessageLookupByLibrary.simpleMessage("Поделиться"),
        "shareDeckTooltip":
            MessageLookupByLibrary.simpleMessage("Поделиться списком"),
        "shuffleTooltip":
            MessageLookupByLibrary.simpleMessage("Перемешать карточки"),
        "signInAccountExistWithDifferentCredentialWarning":
            MessageLookupByLibrary.simpleMessage(
                "Вы уже регистрировались в приложении с этим адресом электронной почты, но с использованием другого сервиса (например, Google вместо Facebook). Пожалуйста, войдите с использованием того же сервиса, которым вы пользовались раньше"),
        "signInCredentialAlreadyInUseWarning": MessageLookupByLibrary.simpleMessage(
            "Вы уже регистрировались в приложении с этим аккаунтом. Если Вы продолжите, все данные, которые Вы создали анонимно, будут потеряны. Желаете продолжить?"),
        "signInScreenOr": MessageLookupByLibrary.simpleMessage("или"),
        "signInWithFacebook": MessageLookupByLibrary.simpleMessage("Facebook"),
        "signInWithGoogle": MessageLookupByLibrary.simpleMessage("Google"),
        "signInWithLabel":
            MessageLookupByLibrary.simpleMessage("Войти с помощью:"),
        "splashScreenFeatures": MessageLookupByLibrary.simpleMessage(
            "Данные и прогресс изучения будут сохранены в Облаке и синхронизированы на всех Ваших устройствах. Вы также можете поделиться карточками с друзьями и коллегами"),
        "swissDeckType": MessageLookupByLibrary.simpleMessage("Швейцарский"),
        "termsOfService":
            MessageLookupByLibrary.simpleMessage("Условия Использования"),
        "unknownDeckType": MessageLookupByLibrary.simpleMessage("Неизвестный"),
        "viewLearning": MessageLookupByLibrary.simpleMessage("Просмотр"),
        "viewLearningTooltip": MessageLookupByLibrary.simpleMessage(
            "Начать изучение всех карточек в любом порядке"),
        "whoHasAccessLabel":
            MessageLookupByLibrary.simpleMessage("У кого есть доступ"),
        "yes": MessageLookupByLibrary.simpleMessage("Да")
      };
}
