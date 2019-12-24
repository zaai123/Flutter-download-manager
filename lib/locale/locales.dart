import 'package:download_manager/l10n/messages_all.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return AppLocalizations();
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String get appName {
    return Intl.message(
      'Download manager',
      name: 'appName',
    );
  }

  String get createFolderTitle {
    return Intl.message(
      'Create folder',
      name: 'createFolderTitle',
    );
  }

  String get folderNameHint {
    return Intl.message(
      'Folder name',
      name: 'folderNameHint',
    );
  }

  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
    );
  }

  String get create {
    return Intl.message(
      'Create',
      name: 'create',
    );
  }

  String get list {
    return Intl.message(
      'List',
      name: 'list',
    );
  }

  String get sortBy {
    return Intl.message(
      'Sort By',
      name: 'sortBy',
    );
  }

  String get name {
    return Intl.message(
      'Name',
      name: 'name',
    );
  }

  String get size {
    return Intl.message(
      'Size',
      name: 'size',
    );
  }

  String get dateAndTime {
    return Intl.message(
      'Date & time',
      name: 'dateAndTime',
    );
  }

  String get type {
    return Intl.message(
      'Type',
      name: 'type',
    );
  }

  String get ascending {
    return Intl.message(
      'Ascending',
      name: 'ascending',
    );
  }

  String get descending {
    return Intl.message(
      'Descending',
      name: 'descending',
    );
  }

  String get done {
    return Intl.message(
      'Done',
      name: 'done',
    );
  }

  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
    );
  }

  String get enableTheme {
    return Intl.message(
      'Enable dark theme',
      name: 'enableTheme',
    );
  }

  String get disableTheme {
    return Intl.message(
      'Disable Theme',
      name: 'disableTheme',
    );
  }

  String get hideExtension {
    return Intl.message(
      'Hide Extension',
      name: 'hideExtension',
    );
  }

  String get showExtension {
    return Intl.message(
      'Show extension',
      name: 'showExtension',
    );
  }

  String get privacy {
    return Intl.message(
      'Privacy',
      name: 'privacy',
    );
  }

  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
    );
  }

  String get privacyPolicySubtitle {
    return Intl.message(
      'Check out our privacy policy',
      name: 'privacyPolicySubtitle',
    );
  }

  String get about {
    return Intl.message(
      'About',
      name: 'about',
    );
  }

  String get appVersion {
    return Intl.message(
      'App version',
      name: 'appVersion',
    );
  }

  String get areYouSure {
    return Intl.message(
      'Are you sure?',
      name: 'areYouSure',
    );
  }

  String get areYouSureDesc {
    return Intl.message(
      'Are you sure you want to delete these files? Once you delete them you can\'t recover them.',
      name: 'areYouSureDesc',
    );
  }

  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
    );
  }

  String get shareFile {
    return Intl.message(
      'Share File',
      name: 'shareFile',
    );
  }

  String get shareFiles {
    return Intl.message(
      'Share Files',
      name: 'shareFiles',
    );
  }

  String get creatingZip {
    return Intl.message(
      'Creating zip',
      name: 'creatingZip',
    );
  }

  String get pleaseWait {
    return Intl.message(
      'Please wait',
      name: 'pleaseWait',
    );
  }

  String get extractHere {
    return Intl.message(
      'Extract Here',
      name: 'extractHere',
    );
  }

  String get copy {
    return Intl.message(
      'Copy',
      name: 'copy',
    );
  }

  String get copyHere {
    return Intl.message(
      'Copy here',
      name: 'copyHere',
    );
  }

  String get move {
    return Intl.message(
      'Move',
      name: 'move',
    );
  }

  String get moveHere {
    return Intl.message(
      'Move here',
      name: 'moveHere',
    );
  }

  String get selected {
    return Intl.message(
      'Selected',
      name: 'selected',
    );
  }

  String get moveWarning {
    return Intl.message(
      'You cannot move files in same directory',
      name: 'moveWarning',
    );
  }

  String get copyWarning {
    return Intl.message(
      'You cannot copy files in same directory',
      name: 'copyWarning',
    );
  }

  String get createdSuccess {
    return Intl.message(
      'Created successfully',
      name: 'createdSuccess',
    );
  }

  String get deleteSuccess {
    return Intl.message(
      'Files deleted successfully',
      name: 'deleteSuccess',
    );
  }

  String get noFiles {
    return Intl.message(
      'No downloaded files found!',
      name: 'noFiles',
    );
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'pt']
        .contains(locale.languageCode != null ? locale.languageCode : "en");
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) {
    return false;
  }
}
