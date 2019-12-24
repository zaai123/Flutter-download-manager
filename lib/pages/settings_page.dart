import 'package:download_manager/abstracts/ads_callback.dart';
import 'package:download_manager/abstracts/theme_callbacks.dart';
import 'package:download_manager/contants/constants.dart';
import 'package:download_manager/locale/locales.dart';
import 'package:download_manager/util/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:package_info/package_info.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {

  ThemeCallBack themeCallBack;
  AdsCallBack adsCallBack;

  SettingsPage(this.themeCallBack, this.adsCallBack);

  @override
  _SettingsPageState createState() => _SettingsPageState(this.themeCallBack, this.adsCallBack);
}

class _SettingsPageState extends State<SettingsPage> {

  bool valueTheme = false;
  bool valueExtension = false;
  var themeText = 'Enable Dark theme';
  var themeSubtitle = 'Enable or disable dark theme';
  var extensionTitle = 'Hide extension';
  var extensionSubTitle = 'Hide & show file extension';
  var appVersion = '';


  PackageInfo packageInfo;

  ThemeCallBack themeCallBack;

  AdsCallBack adsCallBack;

  _SettingsPageState(this.themeCallBack, this.adsCallBack);

  @override
  void initState() {
    super.initState();
    if(Util.adsCounter < 1){
      adsCallBack.showInterstitial();
    }
    getPackageInfo();
    valueTheme = Util.isDarkThemeOn;
    valueExtension = Util.isExtensionOn;
    Future.delayed(Duration(milliseconds: 150)).then((value){
      themeText = valueTheme ? AppLocalizations.of(context).disableTheme : AppLocalizations.of(context).enableTheme;
      extensionTitle = valueExtension ? AppLocalizations.of(context).hideExtension : AppLocalizations.of(context).showExtension;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).settings),),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: 'General',
            tiles: [
              SettingsTile.switchTile(
                subtitle: themeSubtitle,
                title: themeText,
                leading: CircleAvatar(child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(MaterialCommunityIcons.theme_light_dark,
                    color: Colors.white,),
                ), backgroundColor: Colors.lightBlue,),
                switchValue: valueTheme,
                onToggle: (bool value) {
                  changeTheme(value);
                },
              ),
              SettingsTile.switchTile(
                subtitle: extensionSubTitle,
                title: extensionTitle,
                leading: CircleAvatar(child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(MaterialCommunityIcons.theme_light_dark,
                    color: Colors.white,),
                ), backgroundColor: Colors.lightBlue,),
                switchValue: valueExtension,
                onToggle: (bool value) {
                  changeExtension(value);
                },
              ),
            ],
          ),
          SettingsSection(
            title: AppLocalizations.of(context).privacy,
            tiles: [
              SettingsTile(title: AppLocalizations.of(context).privacyPolicy,
                  subtitle: AppLocalizations.of(context).privacyPolicySubtitle,
                  onTap: () {
                    _launchURL();
                  },
                  leading: CircleAvatar(child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Entypo.info, color: Colors.white,),
                  ), backgroundColor: Colors.lightBlue,)),
            ],
          ),
          SettingsSection(
            title: AppLocalizations.of(context).about,
            tiles: [
              SettingsTile(
                  title: AppLocalizations.of(context).appVersion, subtitle: appVersion, onTap: () {},
                  leading: CircleAvatar(child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Entypo.info, color: Colors.white,),
                  ), backgroundColor: Colors.lightBlue,)),
            ],
          )
        ],
      ),
    );
  }

  void changeTheme(bool value) {
    themeCallBack.onThemeChange(value);
    valueTheme = value;
    setState(() {
      themeText = !value ? AppLocalizations.of(context).enableTheme : AppLocalizations.of(context).disableTheme;
    });
  }

  void changeExtension(bool value) {
    value ? Util.prefs.setInt(Constants.EXTENSION_PREF, Constants.YES) :
    Util.prefs.setInt(Constants.EXTENSION_PREF, Constants.NO);
    print('Extension value: ' + value.toString());
    setState(() {
      valueExtension = value;
      extensionTitle = value ? AppLocalizations.of(context).hideExtension : AppLocalizations.of(context).showExtension;
      Util.isExtensionOn = value;
    });
  }

  void getPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
      print('App version: ' + appVersion);
    });
  }

  _launchURL() async {
    const url = 'https://gifs-app.com/DownloadManagerPrivacyController';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

