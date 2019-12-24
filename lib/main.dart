import 'dart:io';

import 'package:download_manager/abstracts/ads_callback.dart';
import 'package:download_manager/abstracts/theme_callbacks.dart';
import 'package:download_manager/pages/list_page.dart';
import 'package:download_manager/util/util.dart';
import 'package:download_manager/util/widget_utils.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';

import 'contants/constants.dart';
import 'locale/locales.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> implements ThemeCallBack, AdsCallBack {

  MobileAdTargetingInfo _targetingInfo;

  InterstitialAd interstitialAd;

  bool isInterstitialLoaded = false;

  @override
  void initState() {
    super.initState();

    _targetingInfo = MobileAdTargetingInfo(
        testDevices: <String>["921d9f790bee2d556a0c1ba857458eb0"]);

    FirebaseAdMob.instance.initialize(appId: Constants.APP_ID);
    InterstitialAd interstitialAd;
    loadInterstitial();


    if(Util.themeCallBack == null)
      Util.themeCallBack = this;
    initPrefs(context);
    checkDarkTheme();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      localizationsDelegates: [
        AppLocalizationsDelegate(),
        const FallbackCupertinoLocalisationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ""),
        Locale("es", "ES"),
        Locale('pt', "PT"),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the current device locale is supported
        if(locale == null){
          print("Locale is null");
          return supportedLocales.first;
        }
        if (locale.languageCode != null)
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
        // If the locale of the device is not supported, use the first one
        // from the list (English, in this case).
        return supportedLocales.first;
      },

      debugShowCheckedModeBanner: false,
      themeMode: Util.isDarkThemeOn ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          textTheme: TextTheme(
              title: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              subtitle: TextStyle(color: Colors.white60, fontSize: 12),
              body1: TextStyle(color: Colors.white),
              body2: TextStyle(color: Colors.white),
              button: TextStyle(color: Colors.grey[800], fontSize: 22),
              display1: TextStyle(color: Colors.white, fontSize: 16),
              display2: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              display3: TextStyle(color: Colors.white, fontSize: 16),
              display4: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
          ),
          dialogBackgroundColor: Colors.grey[850],
          popupMenuTheme: PopupMenuThemeData(color: Colors.grey[850], shape: WidgetUtils.bigButtonShape,),
          buttonTheme: ButtonThemeData(
              shape: WidgetUtils.bigButtonShape,
              buttonColor: Colors.blueGrey,
              height: 60,
              textTheme: ButtonTextTheme.normal),
          cardColor: Colors.black54,
          secondaryHeaderColor: Colors.grey[700],
          selectedRowColor: Colors.grey[850],
          buttonColor: Colors.lightBlue,

      ),
      title: 'Flutter Demo',
      theme: ThemeData(
          textTheme: TextTheme(
              title: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
              subtitle: TextStyle(color: Colors.black54, fontSize: 12),
              button: TextStyle(color: Colors.white, fontSize: 22),
              display1: TextStyle(color: Colors.white, fontSize: 16),
              display2: TextStyle(color: Colors.blueGrey, fontSize: 22, fontWeight: FontWeight.bold),
              display3: TextStyle(color: Colors.blueGrey[800], fontSize: 16),
              display4: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.lightBlueAccent,
          ),
          popupMenuTheme: PopupMenuThemeData(color: Colors.white, shape: WidgetUtils.bigButtonShape,),
          dialogBackgroundColor: Colors.white,
          buttonTheme: ButtonThemeData(
              shape: WidgetUtils.bigButtonShape,
              buttonColor: Colors.lightBlue,
              height: 60),
          primarySwatch: Colors.blue,
          secondaryHeaderColor: Colors.grey[300],
          cardColor: Colors.white,
          selectedRowColor: Colors.grey[200],
          buttonColor: Colors.lightBlue),
      home: ListPage('', this),
    );
  }

  void initPrefs(BuildContext context) {
    Util.initPrefs();
  }

  void checkDarkTheme() async {
    var checkTheme = await Util.checkDarkTheme();
    Util.isExtensionOn = await Util.checkExtension();
    setState(() {
      Util.isDarkThemeOn = checkTheme;
    });
  }

  @override
  onThemeChange(bool value) {
    print("Value: " + value.toString());
    if (value) {
      Util.prefs.setInt(Constants.THEME_PREF, Constants.YES);
      setState(() {
        Util.isDarkThemeOn = true;
      });
    } else {
      Util.prefs.setInt(Constants.THEME_PREF, Constants.NO);
      setState(() {
        Util.isDarkThemeOn = false;
      });
    }
  }

  void loadInterstitial() {
    interstitialAd = InterstitialAd(
      //adUnitId: InterstitialAd.testAdUnitId,
        adUnitId: Constants.INTERSTITIAL_ID,
        listener: (MobileAdEvent event) {
          if (event == MobileAdEvent.loaded) {
            isInterstitialLoaded = true;
            print("Interstitial loaded");
          } else if (event == MobileAdEvent.closed) {
            //loadInterstitial();
            Util.adsCounter++;
          }
        })
      ..load();
  }

  @override
  showInterstitial() {
   if(interstitialAd != null && isInterstitialLoaded){
     interstitialAd.show();
   }
  }
}


class FallbackCupertinoLocalisationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalisationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      DefaultCupertinoLocalizations.load(locale);

  @override
  bool shouldReload(FallbackCupertinoLocalisationsDelegate old) => false;
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void requestPermission() async {
    var isGranted = await checkPermission();

    if (!isGranted) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);
      PermissionStatus permissionStatus = permissions[PermissionGroup.storage];
      if (permissionStatus == PermissionStatus.denied) {
        requestPermission();
      } else {
        getDownloadFiles();
      }
    } else {
      getDownloadFiles();
    }
  }

  Future<bool> checkPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }

  void getDownloadFiles() async {
    Future<Directory> downloadsDirectory =
        DownloadsPathProvider.downloadsDirectory;
    downloadsDirectory.then((dir) {
      List<FileSystemEntity> filesList = dir.listSync();
      print('Path: ' + dir.path);
      for (FileSystemEntity fileSystemEntity in filesList) {
        fileSystemEntity.stat().then((fileStat) {
          print('Type: ' + fileStat.type.toString());
        });
      }
      print('List lenght: ' + dir.listSync().length.toString());
    });
  }
}
