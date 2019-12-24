import 'package:download_manager/abstracts/theme_callbacks.dart';
import 'package:download_manager/contants/constants.dart';
import 'package:download_manager/locale/locales.dart';
import 'package:download_manager/model/file_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Util {
  static bool isDarkThemeOn = false;
  static bool isExtensionOn = false;
  static SharedPreferences prefs;

  static ThemeCallBack themeCallBack;

  static SnackBar pasteSnackBar;
  static List<FileModel> copyList = List();
  static List<FileModel> moveList = List();

  static var adsCounter = 0;

  static Future<bool> checkDarkTheme() async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    return prefs.getInt(Constants.THEME_PREF) == null
        ? false
        : prefs.getInt(Constants.THEME_PREF) == Constants.NO
            ? false
            : prefs.getInt(Constants.THEME_PREF) == Constants.YES
                ? true
                : false;
  }

  static checkExtension() async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    return prefs == null ? true : prefs.getInt(Constants.EXTENSION_PREF) == null ? true :
        prefs.getInt(Constants.EXTENSION_PREF) == Constants.NO ? false : true;
  }

  static initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  static String getSortTypeName(BuildContext context) {
    return prefs.getString(Constants.SORT_TYPE_PREF) == null
        ? AppLocalizations.of(context).name
        : prefs.getString(Constants.SORT_TYPE_PREF) ==
                SORT_TYPE.CHANGED_DATE.toString()
            ? AppLocalizations.of(context).dateAndTime
            : prefs.getString(Constants.SORT_TYPE_PREF) ==
                    SORT_TYPE.NAME.toString()
                ? AppLocalizations.of(context).name
                : prefs.getString(Constants.SORT_TYPE_PREF) ==
                        SORT_TYPE.SIZE.toString()
                    ? AppLocalizations.of(context).size
                    : AppLocalizations.of(context).type;
  }

  static String getUpDownPrefsName(BuildContext context) {
    return prefs.getString(Constants.SORT_UP_DOWN_PREF) == null
        ? AppLocalizations.of(context).ascending
        : prefs.getString(Constants.SORT_UP_DOWN_PREF) ==
                UP_DOWN_SORT_TYPES.ASCENDING.toString()
            ? AppLocalizations.of(context).ascending
            : AppLocalizations.of(context).descending;
  }

  static void setSortTypePrefs(int value) {
    value == 0
        ? prefs.setString(Constants.SORT_TYPE_PREF, SORT_TYPE.NAME.toString())
        : value == 1
            ? prefs.setString(
                Constants.SORT_TYPE_PREF, SORT_TYPE.SIZE.toString())
            : value == 2
                ? prefs.setString(
                    Constants.SORT_TYPE_PREF, SORT_TYPE.CHANGED_DATE.toString())
                : prefs.setString(
                    Constants.SORT_TYPE_PREF, SORT_TYPE.TYPE.toString());
  }

  static void setUpDownPrefs(int value) {
    value == 0 ? prefs.setString(Constants.SORT_UP_DOWN_PREF,
            UP_DOWN_SORT_TYPES.ASCENDING.toString())
        : prefs.setString(Constants.SORT_UP_DOWN_PREF, UP_DOWN_SORT_TYPES.DESCENDING.toString());
  }

  static SORT_TYPE getSortType() {
    return prefs.getString(Constants.SORT_TYPE_PREF) == null
        ? SORT_TYPE.NAME
        : prefs.getString(Constants.SORT_TYPE_PREF) == SORT_TYPE.NAME.toString()
            ? SORT_TYPE.NAME
            : prefs.getString(Constants.SORT_TYPE_PREF) ==
                    SORT_TYPE.SIZE.toString()
                ? SORT_TYPE.SIZE
                : prefs.getString(Constants.SORT_TYPE_PREF) ==
                        SORT_TYPE.CHANGED_DATE.toString()
                    ? SORT_TYPE.CHANGED_DATE
                    : SORT_TYPE.TYPE;
  }

  static UP_DOWN_SORT_TYPES getUpDownSortType() {
    return prefs.getString(Constants.SORT_UP_DOWN_PREF) == null
        ? UP_DOWN_SORT_TYPES.ASCENDING
        : prefs.getString(Constants.SORT_UP_DOWN_PREF) ==
                UP_DOWN_SORT_TYPES.ASCENDING.toString()
            ? UP_DOWN_SORT_TYPES.ASCENDING
            : UP_DOWN_SORT_TYPES.DESCENDING;
  }
}

enum SORT_TYPE { CHANGED_DATE, NAME, SIZE, TYPE }

enum UP_DOWN_SORT_TYPES { ASCENDING, DESCENDING }
