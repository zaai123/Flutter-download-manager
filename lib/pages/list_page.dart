import 'dart:io';
import 'dart:typed_data';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:download_manager/abstracts/ads_callback.dart';
import 'package:download_manager/abstracts/app_bar_callbacks.dart';
import 'package:download_manager/abstracts/theme_callbacks.dart';
import 'package:download_manager/dialog/delete_dialog.dart';
import 'package:download_manager/dialog/folder_dialog.dart';
import 'package:download_manager/dialog/zip_creating_dialog.dart';
import 'package:download_manager/locale/locales.dart';
import 'package:download_manager/model/file_model.dart';
import 'package:download_manager/model/menu_choice.dart';
import 'package:download_manager/pages/settings_page.dart';
import 'package:download_manager/util/util.dart';
import 'package:download_manager/widgets/files_list_view.dart';
import 'package:download_manager/widgets/search_bar.dart';
import 'package:download_manager/widgets/sort_option_widget.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thumbnails/thumbnails.dart';

class ListPage extends StatefulWidget {
  String directoryPath;
  AdsCallBack adsCallBack;

  ListPage(this.directoryPath, this.adsCallBack);

  @override
  _ListPageState createState() => _ListPageState(this.directoryPath, this.adsCallBack);
}

class _ListPageState extends State<ListPage> implements AppBarCallBacks {
  bool isPermissionGranted = false;
  bool isLoaded = false;
  bool canShowShare = false;
  List<FileModel> fileModelList = List();
  List<SelectedFileModel> selectedList = List();

  ThemeCallBack themeCallBack;

  bool canShowUnZip = false;
  String mainPath = '';
  String currentPath = '';

  GlobalKey<ScaffoldState> globalKey = GlobalKey();

  String directoryPath;

  MenuChoice _selectedChoice = choices[0];

  bool canShowPopUp = false;
  String copyPath = '';
  String movePath = '';
  bool isSearching = false;
  bool canSearch = false;
  List<FileModel> searchList;
  TextEditingController searchController = TextEditingController();

  AdsCallBack adsCallBack;

  _ListPageState(this.directoryPath, this.adsCallBack);

  @override
  void initState() {
    super.initState();
    themeCallBack = Util.themeCallBack;
    BackButtonInterceptor.add(backButtonInterceptor);
    requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          deselectAll();
          setState(() {
            Util.copyList.clear();
            Util.moveList.clear();
          });
          createFolderDialog();
        },
        child: Icon(
          MaterialCommunityIcons.folder_plus,
          color: Theme.of(context).cardColor,
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: directoryPath.isNotEmpty &&
                selectedList.isEmpty &&
                Util.copyList.isEmpty &&
                Util.moveList.isEmpty
            ? true
            : false,
        title: Util.copyList.isEmpty &&
                selectedList.isEmpty &&
                Util.moveList.isEmpty
            ? Text(AppLocalizations.of(context).list)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                      icon: Icon(MaterialCommunityIcons.close),
                      onPressed: () {
                        deselectAll();
                        setState(() {
                          Util.copyList.clear();
                          Util.moveList.clear();
                        });
                      }),
                  Flexible(
                    child: Text(Util.copyList.isEmpty && Util.moveList.isEmpty
                        ? AppLocalizations.of(context).selected + ' ' + selectedList.length.toString()
                        : Util.copyList.isEmpty && Util.moveList.isNotEmpty
                            ? AppLocalizations.of(context).moveHere
                            : AppLocalizations.of(context).copyHere, style: Theme.of(context).textTheme.title,
                    overflow: TextOverflow.ellipsis,),
                  )
                ],
              ),
        actions: Util.copyList.isNotEmpty
            ? <Widget>[
                IconButton(
                    icon: Icon(MaterialCommunityIcons.content_paste),
                    onPressed: () => pasteFiles(), padding: EdgeInsets.all(0),),
              ]
            : Util.moveList.isNotEmpty
                ? <Widget>[
                    IconButton(
                        icon: Icon(MaterialCommunityIcons.folder_move),
                        onPressed: () => moveFiles(),),
                  ]
                : selectedList.isNotEmpty
                    ? <Widget>[
                        Visibility(
                          child: IconButton(
                              icon: Icon(MaterialCommunityIcons.share),
                              onPressed: () => shareFiles(), padding: EdgeInsets.all(0),),
                          visible: canShowShare,
                        ),
                        IconButton(
                            icon: Icon(MaterialCommunityIcons.delete),
                            onPressed: () => deleteFiles(), padding: EdgeInsets.all(0),),
                        IconButton(
                            icon: Icon(MaterialCommunityIcons.folder_zip),
                            onPressed: () => createZip()),
                        Visibility(
                          child: IconButton(
                              icon: Icon(Octicons.file_zip), onPressed: () {}, padding: EdgeInsets.all(0),),
                          visible: canShowUnZip,
                        ),
                        Visibility(
                          child: PopupMenuButton(
                            itemBuilder: (BuildContext context) {
                              return choices.skip(0).map((c) {
                                return PopupMenuItem<MenuChoice>(
                                  value: c,
                                  child: Text(c.title),
                                );
                              }).toList();
                            },
                            onSelected: _selectMenu,
                          ),
                          visible: canShowPopUp,
                        )
                      ]
                    : <Widget>[
                        IconButton(
                            icon: Icon(MaterialCommunityIcons.sort),
                            onPressed: () => showSortListDialog()),
                        IconButton(
                            icon: Icon(MaterialCommunityIcons.settings),
                            onPressed: () => _goToSettings()),
                        /*IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () => setState(() => canSearch = true))*/
                      ],
      ),
      body: !isPermissionGranted
          ? Center(child: Text('App needs permission to access download folder. Thanks.'))
          : isLoaded && fileModelList.isNotEmpty
              ? Column(
                  children: <Widget>[
                    Visibility(child: SearchBar(this), visible: canSearch),
                    pathText(),
                    Expanded(
                        child: !isSearching && fileModelList.isNotEmpty ? FileListView(fileModelList, this, adsCallBack):
                    isSearching && searchList.isNotEmpty ? FileListView(searchList, this, adsCallBack):
                    Text('example'))
                  ],
                )
              : isLoaded && fileModelList.isEmpty && !isSearching
                  ? Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        pathText(),
                        Expanded(
                            child: Center(
                                child: Text(AppLocalizations.of(context).noFiles)))
                      ],
                    )
                  : Center(child: CircularProgressIndicator()),
    );
  }

  Widget pathText() {
    return Container(
      width: double.infinity,
      color: Colors.black38,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          mainPath,
          style: Theme.of(context).textTheme.subtitle,
        ),
      ),
    );
  }

  void loadList() {
    Future<Directory> downloadsDirectory =
        DownloadsPathProvider.downloadsDirectory;
    downloadsDirectory.then((dir) {
      getFilesList(dir);
    });
  }

  getFilesList(Directory dir) {
    List<FileSystemEntity> filesList = dir.listSync();
    mainPath = dir.path;
    currentPath = mainPath;
    print('Path: ' + dir.path);
    for (FileSystemEntity fileSystemEntity in filesList) {
      FileStat fileStat = fileSystemEntity.statSync();

      String path = fileSystemEntity.path;
      List<String> list = path.split('/');

      String name = list[list.length - 1];

      String nameWihoutExtension = '';


      FILE_TYPE fileType = fileStat.type == FileSystemEntityType.directory ? FILE_TYPE.DIRECTORY : getFileType(path);

      if(fileStat.type == FileSystemEntityType.directory){
        nameWihoutExtension = name;
      }else{
        if(name.contains('.')){
          nameWihoutExtension = name.split('.').toList()[0];
        }else{
          nameWihoutExtension = name;
        }
      }

      int filesCount = 0;
      if (fileType == FILE_TYPE.DIRECTORY) {
        Directory directory = Directory(path);
        filesCount = directory.listSync().length;
      }

      FileModel fileModel = FileModel(
          name: name,
          accessedDate: fileStat.accessed,
          changedDate: fileStat.changed,
          modifiedDate: fileStat.modified,
          path: fileSystemEntity.path,
          size: fileStat.size,
          uri: fileSystemEntity.uri,
          fileExtension: fileType,
          fileType: fileStat.type == FileSystemEntityType.directory ? 'dir' : 'file',
          isSelected: false,
          formattedSize: filesize(fileStat.size),
          dirFilesCount: filesCount,
      nameWithoutExtension: nameWihoutExtension);

      fileModelList.add(fileModel);

      if (fileModel.fileExtension == FILE_TYPE.VIDEO) {
        getVideoThumbnail(fileModel.path).then((thumbnailName) {
          fileModel.videoThumbnail = thumbnailName;
        });
      }
    }
    print('List lenght: ' + fileModelList.length.toString());

    setState(() {
      isLoaded = true;
    });
  }

  void requestPermission() async {
    var isGranted = await checkPermission();

    if (!isGranted) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      PermissionStatus permissionStatus = permissions[PermissionGroup.storage];
      if (permissionStatus == PermissionStatus.denied) {
        requestPermission();
        return;
      } else {
        isPermissionGranted = true;
        directoryPath.isEmpty ? loadList() : getDirectoryList();
      }
    } else {
      isPermissionGranted = true;
      directoryPath.isEmpty ? loadList() : getDirectoryList();
    }
    setState(() {});
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

  FILE_TYPE getFileType(String path) {
    path = path.toLowerCase();
    return path.endsWith('.jpg') || path.endsWith('.png')
        ? FILE_TYPE.IMAGE
        : path.endsWith('apk') ? FILE_TYPE.APK
            : path.endsWith('mp3') || path.endsWith('wav') || path.endsWith('flac')
                ? FILE_TYPE.AUDIO : path.endsWith('pdf')
                    ? FILE_TYPE.PDF : path.endsWith('text') || path.endsWith('txt') ? FILE_TYPE.TEXT
        : path.endsWith('mp4') || path.endsWith('3gp') | path.endsWith('webm') ||
                                path.endsWith('mkv') ? FILE_TYPE.VIDEO
                            : path.endsWith('zip') ? FILE_TYPE.ZIP : FILE_TYPE.UNKNOWN;
  }

  @override
  onDeselected(int index, FileModel fileModel) {
    SelectedFileModel selectedFileModel = selectedList.firstWhere((i) => index == i.index);
    setState(() {
      selectedList.remove(selectedFileModel);
      fileModelList[index].isSelected = false;
      checkShare();
      checkZip();
      checkPopUpMenu();
    });
  }

  @override
  onSelected(int index, FileModel fileModel) {
    setState(() {
      selectedList.add(SelectedFileModel(fileModel: fileModel, index: index));
      fileModelList[index].isSelected = true;
      checkShare();
      checkZip();
      checkPopUpMenu();
    });
  }

  checkShare() {
    for (SelectedFileModel selectedFileModel in selectedList) {
      FILE_TYPE fileExtension = selectedFileModel.fileModel.fileExtension;
      if (fileExtension == FILE_TYPE.ZIP ||
          fileExtension == FILE_TYPE.DIRECTORY ||
          fileExtension == FILE_TYPE.UNKNOWN ||
          fileExtension == FILE_TYPE.APK) {
        canShowShare = false;
        return;
      }
    }
    canShowShare = true;
  }

  checkZip() {
    if (selectedList.length == 1 &&
        selectedList[0].fileModel.fileExtension == FILE_TYPE.ZIP) {
      canShowUnZip = true;
    } else {
      canShowUnZip = false;
    }
  }

  checkPopUpMenu() {
    List<SelectedFileModel> list = selectedList
        .where((i) => i.fileModel.fileExtension == FILE_TYPE.DIRECTORY)
        .toList();
    list.isEmpty ? canShowPopUp = true : canShowPopUp = false;
  }

  @override
  int listLength() {
    return selectedList.length;
  }

  void deselectAll() {
    setState(() {
      selectedList.clear();
      List<FileModel> clearList =
          fileModelList.where((i) => i.isSelected).toList();
      for (FileModel fileModel in clearList) {
        fileModel.isSelected = false;
      }
      clearList.clear();
    });
  }

  bool backButtonInterceptor(bool stopDefaultButtonEvent) {
    if (selectedList.isEmpty) {
      return false;
    } else {
      deselectAll();
      return true;
    }
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(backButtonInterceptor);
    super.dispose();
  }

  void showSortListDialog() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SortOptionsWidget(this);
        },
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20))));
  }

  void _goToSettings() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => SettingsPage(themeCallBack, adsCallBack)));
  }

  @override
  sortAscendingList(SORT_TYPE sortOrder) {
    switch (sortOrder) {
      case SORT_TYPE.NAME:
        setState(() {
          fileModelList.sort((i, n) => i.name.compareTo(n.name));
        });
        break;
      case SORT_TYPE.SIZE:
        setState(() {
          fileModelList.sort((i, n) => i.size.compareTo(n.size));
        });
        break;
      case SORT_TYPE.CHANGED_DATE:
        setState(() {
          fileModelList.sort((i, n) => i.changedDate.compareTo(n.changedDate));
        });
        break;
      case SORT_TYPE.TYPE:
        setState(() {
          fileModelList.sort((i, n) =>
              i.fileExtension.toString().compareTo(n.fileExtension.toString()));
        });
        break;
      default:
        break;
    }
  }

  Future<String> getVideoThumbnail(String path) async {
    print('Video path: ' + path);
    String thumb = await Thumbnails.getThumbnail(
        videoFile: path, imageType: ThumbFormat.PNG, quality: 30);

    return thumb;
  }

  @override
  sortDescendingList(SORT_TYPE sortOrder) {
    switch (sortOrder) {
      case SORT_TYPE.NAME:
        setState(() {
          fileModelList.sort((i, n) => n.name.compareTo(i.name));
        });
        break;
      case SORT_TYPE.SIZE:
        setState(() {
          fileModelList.sort((i, n) => n.size.compareTo(i.size));
        });
        break;
      case SORT_TYPE.TYPE:
        setState(() {
          fileModelList.sort((i, n) =>
              n.fileExtension.toString().compareTo(i.fileExtension.toString()));
        });
        break;
      case SORT_TYPE.CHANGED_DATE:
        setState(() {
          fileModelList.sort((i, n) => n.changedDate.compareTo(i.changedDate));
        });
        break;
      default:
        break;
    }
  }

  void createFolderDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CreateFolderDialog(this);
        });
  }

  @override
  createFolder(String folderName) {
    Directory newDir = Directory(mainPath + '/' + folderName);

    bool isExists = newDir.existsSync();

    if (isExists) {
      showFolderExistsSnackBar(folderName);
    } else {
      newDir.create(recursive: true).then((dir) {
        print('Folder created');
        if (dir != null) {
          FileStat fileStat = dir.statSync();
          int count = dir.listSync().length;
          FileModel fileModel = FileModel(
              isSelected: false,
              fileType: 'directory',
              uri: dir.uri,
              size: fileStat.size,
              path: dir.path,
              modifiedDate: fileStat.modified,
              changedDate: fileStat.changed,
              accessedDate: fileStat.accessed,
              name: folderName,
              fileExtension: FILE_TYPE.DIRECTORY,
              dirFilesCount: count,
              formattedSize: filesize(fileStat.size),
              nameWithoutExtension: folderName,
              videoThumbnail: '');
          setState(() {
            fileModelList.add(fileModel);
          });
          snackBar(folderName + ' ' + AppLocalizations.of(context).createdSuccess);
        }
      });
    }
  }

  void showFolderExistsSnackBar(String folderName) {
    snackBar(folderName + ' already exists');
  }

  void snackBar(String message) {
    globalKey.currentState.showSnackBar(
        SnackBar(content: Text(message), duration: Duration(seconds: 2)));
  }

  shareFiles() async {
    File f = File(selectedList[0].fileModel.path);
    if (selectedList.length == 1) {
      Share.file(AppLocalizations.of(context).shareFile, selectedList[0].fileModel.name,
          f.readAsBytesSync(), '*/*',
          text: 'Share file with download manager');
    } else {
      Map<String, Uint8List> fileByteDataList = Map();

      for (SelectedFileModel selectedFileModel in selectedList) {
        File f = File(selectedFileModel.fileModel.path);

        fileByteDataList[selectedFileModel.fileModel.name] =
            f.readAsBytesSync();
      }

      Share.files(AppLocalizations.of(context).shareFiles, fileByteDataList, '*/*',
          text: 'Share files with download manager');
    }
    deselectAll();
  }

  void createZip() async {
    print('Enter here');
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ZipCreatingDialog(selectedList, this, mainPath);
        },
        barrierDismissible: false);
  }

  void deleteFiles() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DeleteDialog(selectedList, this);
        }).then((value) {
      if (value != null && value) {
        setState(() {
          fileModelList.removeWhere((i) => i.isSelected);
        });
        snackBar(AppLocalizations.of(context).deleteSuccess);
        for (SelectedFileModel selectedFileModel in selectedList) {
          File file = File(selectedFileModel.fileModel.path);
          file.delete(recursive: true).then((value) {
            print("Value: " + value.toString());
          });
        }
        deselectAll();
      }
    });
  }

  @override
  zipCreated(FileModel fileModel) {
    setState(() {
      fileModelList.add(fileModel);
    });
    snackBar(fileModel.name + ' ' +AppLocalizations.of(context).createdSuccess);
    deselectAll();
  }

  getDirectoryList() {
    Directory dir = Directory(directoryPath);
    getFilesList(dir);
  }

  @override
  String getCurrentPath() {
    return mainPath;
  }

  @override
  unZipSuccess(FileModel fileModel) {
    setState(() {
      fileModelList.add(fileModel);
    });
    snackBar(fileModel.name + ' extracted successfully');
  }

  copyFiles() {
    copyPath = getCurrentPath();
    for (SelectedFileModel selectedFileModel in selectedList) {
      if (Util.copyList.isEmpty) {
        setState(() {
          Util.copyList.add(selectedFileModel.fileModel);
        });
      } else {
        Util.copyList.add(selectedFileModel.fileModel);
      }
    }
    print(('Copy list length: ' + Util.copyList.length.toString()));
    deselectAll();
  }

  createMoveList() {
    movePath = getCurrentPath();
    for (SelectedFileModel selectedFileModel in selectedList) {
      Util.moveList.isEmpty
          ? setState(() => Util.moveList.add(selectedFileModel.fileModel))
          : Util.moveList.add(selectedFileModel.fileModel);
    }
    deselectAll();
  }

  moveFiles() {
    if (movePath != getCurrentPath()) {
      for (FileModel fileModel in Util.moveList) {
        File file = File(fileModel.path);
        String newPath = getCurrentPath() + '/' + fileModel.name;
        file.copy(newPath);
        int count = 0;
        if (fileModel.fileExtension == FILE_TYPE.DIRECTORY) {
          Directory dir = Directory(fileModel.path);
          count = dir.listSync().length;
        }
        setState(() {
          FileStat fileStat = file.statSync();
          fileModelList.add(FileModel(
            formattedSize: filesize(fileStat.size),
            videoThumbnail: '',
            fileExtension: fileModel.fileExtension,
            name: fileModel.name,
            accessedDate: fileStat.accessed,
            changedDate: fileStat.changed,
            modifiedDate: fileStat.modified,
            path: file.path,
            size: fileStat.size,
            uri: file.uri,
            fileType: fileModel.fileExtension.toString(),
            isSelected: false,
            dirFilesCount: count,
          ));
        });
        Future.delayed(Duration(milliseconds: 500)).then((value) {
          file.delete();
        });
      }
    } else {
      snackBar(AppLocalizations.of(context).moveWarning);
    }
  }

  void pasteFiles() {
    print(
        'Current path: ${getCurrentPath()}, File Path: ${Util.copyList[0].path}');
    if (copyPath != getCurrentPath()) {
      for (FileModel fileModel in Util.copyList) {
        File file = File(fileModel.path);
        print('Current path: ' + getCurrentPath());
        file.copy(getCurrentPath() + '/' + fileModel.name);
        int count = 0;
        if (fileModel.fileExtension == FILE_TYPE.DIRECTORY) {
          Directory dir = Directory(fileModel.path);
          count = dir.listSync().length;
        }
        setState(() {
          FileStat fileStat = file.statSync();
          fileModelList.add(FileModel(
            formattedSize: filesize(fileStat.size),
            videoThumbnail: '',
            fileExtension: fileModel.fileExtension,
            name: fileModel.name,
            accessedDate: fileStat.accessed,
            changedDate: fileStat.changed,
            modifiedDate: fileStat.modified,
            path: file.path,
            size: fileStat.size,
            uri: file.uri,
            fileType: fileModel.fileExtension.toString(),
            isSelected: false,
            dirFilesCount: count,
          ));
        });
      }
      setState(() {
        Util.copyList.clear();
      });
    } else {
      snackBar(AppLocalizations.of(context).copyWarning);
    }
  }

  void _selectMenu(MenuChoice value) {
    setState(() {
      _selectedChoice = value;
    });
    value.title == 'Copy' ? copyFiles() : createMoveList();
  }

  @override
  closeSearch() {
    setState(() {
      isSearching = false;
      searchList.clear();
      canSearch = false;
    });
  }

  @override
  search(String searchString) {
    print('String: $searchString');
    if(searchString.isNotEmpty){
      isSearching = true;
      searchList = fileModelList.where((i) => i.name.toLowerCase().contains(searchString.toLowerCase())).toList();
      print('Search list: ' + searchList.length.toString());
    }else{
      isSearching = false;
      searchList.clear();
    }
    setState((){});

    print('Is searching: ' + isSearching.toString());
  }

  @override
  List<FileModel> getFilesModelList() {
    return fileModelList;
  }
}
