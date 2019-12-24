import 'dart:io';

import 'package:archive/archive.dart';
import 'package:download_manager/abstracts/ads_callback.dart';
import 'package:download_manager/abstracts/app_bar_callbacks.dart';
import 'package:download_manager/dialog/unzip_dialog.dart';
import 'package:download_manager/model/file_model.dart';
import 'package:download_manager/pages/list_page.dart';
import 'package:download_manager/util/util.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';

class FileListView extends StatefulWidget {

  List<FileModel> listFileModel;
  AppBarCallBacks appBarCallBacks;
  AdsCallBack adsCallBack;

  FileListView(this.listFileModel, this.appBarCallBacks, this.adsCallBack);

  @override
  _FileListViewState createState() =>
      _FileListViewState(this.listFileModel, this.appBarCallBacks, this.adsCallBack);
}

class _FileListViewState extends State<FileListView> {

  List<FileModel> listFileModel;
  AppBarCallBacks appBarCallBacks;
  AdsCallBack adsCallBack;

  _FileListViewState(this.listFileModel, this.appBarCallBacks, this.adsCallBack);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (BuildContext context, index) {
        FileModel fileModel = listFileModel[index];
        return Column(
          children: <Widget>[
            InkWell(
              onLongPress: () {
                selectOrDeselect(fileModel, index);
              },
              onTap: () {
                openIntentOrSelect(index, fileModel);
              },
              child: Container(
                  color: fileModel.isSelected
                      ? Theme.of(context).selectedRowColor
                      : Theme.of(context).cardColor,
                  width: double.infinity,
                  height: 100,
                  padding: EdgeInsets.all(0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      fileModel.fileExtension == FILE_TYPE.IMAGE
                          ? imageWidget(fileModel)
                          : fileModel.fileExtension == FILE_TYPE.APK ? apkIcon()
                              : fileModel.fileExtension == FILE_TYPE.VIDEO
                                  ? getVideoImage(fileModel) : getIcon(fileModel.fileExtension),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                Util.isExtensionOn ? fileModel.name : fileModel.nameWithoutExtension,
                                style: Theme.of(context).textTheme.title,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                getDateTime(fileModel.changedDate),
                                //getFileSize(fileModel.size),
                                textAlign: TextAlign.left,
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                getSizeOrItems(fileModel),
                                //getFileSize(fileModel.size),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Icon(
                            MaterialCommunityIcons.check_circle_outline,
                            color: Colors.green,
                          ),
                        ),
                        visible: fileModel.isSelected,
                      )
                    ],
                  )),
            ),
            Divider(
              height: .5,
            )
          ],
        );
      },
      itemCount: listFileModel.length,
    );
  }

  Widget imageWidget(FileModel fileModel) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        child:  Image.file(
          File(fileModel.path),
          fit: BoxFit.cover,
          width: 60,
          height: 60,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  String getFileSize(int size){
    return filesize(size);
  }

  getIcon(FILE_TYPE fileExtension) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0),
      child: Icon(
        fileExtension == FILE_TYPE.VIDEO
            ? MaterialCommunityIcons.video_image
            : fileExtension == FILE_TYPE.DIRECTORY
                ? MaterialCommunityIcons.folder
                : fileExtension == FILE_TYPE.AUDIO
                    ? MaterialCommunityIcons.music
                    : fileExtension == FILE_TYPE.TEXT
                        ? MaterialCommunityIcons.note_text
                        : fileExtension == FILE_TYPE.PDF
                            ? MaterialCommunityIcons.file_pdf
                            : fileExtension == FILE_TYPE.ZIP
                                ? MaterialCommunityIcons.folder_zip
                                : MaterialCommunityIcons.file_question,
        size: 60,
        color: fileExtension == FILE_TYPE.ZIP
            ? Colors.yellow
            : fileExtension == FILE_TYPE.PDF
                ? Colors.redAccent
                : fileExtension == FILE_TYPE.APK
                    ? Colors.green
                    : fileExtension == FILE_TYPE.DIRECTORY
                        ? Colors.orange
                        : fileExtension == FILE_TYPE.AUDIO
                            ? Colors.lightGreen
                            : fileExtension == FILE_TYPE.VIDEO
                                ? Colors.purple : fileExtension == FILE_TYPE.TEXT ?
            Colors.brown[400]
                                : Colors.redAccent,
        semanticLabel: 'apk',
      ),
    );
  }

  apkIcon() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: ImageIcon(AssetImage('assets/images/apk_icon.png'),
          size: 60, color: Colors.green),
    );
  }

  void openIntentOrSelect(int index, FileModel fileModel) {
    appBarCallBacks.listLength() > 0 && fileModel.isSelected
        ? deselect(index, fileModel)
        : appBarCallBacks.listLength() > 0 && !fileModel.isSelected
            ? select(index, fileModel)
            : openIntent(fileModel);
  }

  void selectOrDeselect(FileModel fileModel, int index) {
    fileModel.isSelected
        ? deselect(index, fileModel)
        : select(index, fileModel);
  }

  deselect(int index, FileModel fileModel) {
    print("Enter here in deselect");
    appBarCallBacks.onDeselected(index, fileModel);
  }

  select(int index, FileModel fileModel) {
    print("Enter here in select");
    setState(() {
      Util.copyList.clear();
      Util.moveList.clear();
    });
    appBarCallBacks.onSelected(index, fileModel);
  }

  openIntent(FileModel fileModel) {

    if(fileModel.fileExtension == FILE_TYPE.DIRECTORY){
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ListPage(fileModel.path, adsCallBack)));
    }else if(fileModel.fileExtension == FILE_TYPE.ZIP){
      showDialog(context: context, builder: (BuildContext context) {
        return UnZipDialog(fileModel.name);
      }).then((value){
        if(value != null && value){
          unZip(fileModel);
        }
      });
    }else{
      FILE_TYPE extension = fileModel.fileExtension;
      String path = fileModel.path;
      extension == FILE_TYPE.IMAGE ? OpenFile.open(path, type: 'image/*') :
          extension == FILE_TYPE.APK ? OpenFile.open(path, type: 'application/vnd.android.package-archive'):
              extension == FILE_TYPE.PDF ? OpenFile.open(path, type: 'application/pdf'):
                  extension == FILE_TYPE.TEXT ? OpenFile.open(path, type: 'text/plain'):
                      extension == FILE_TYPE.VIDEO ? OpenFile.open(path, type: 'video/*'):
                          extension == FILE_TYPE.AUDIO ? OpenFile.open(path, type: 'audio/*'):
      OpenFile.open(fileModel.path);
    }

  }

  getVideoImage(FileModel fileModel) {
    if (fileModel.videoThumbnail == null) {
      print('Thumbnail is null');
    } else {
      print('Thumbnail is not null');
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        child: fileModel.videoThumbnail == null
            ? Icon(MaterialCommunityIcons.video, size: 50, color: Colors.purple)
            : Container(width: 60, height: 60,
                child: Stack(
                  children: <Widget>[
                    Image.file(
                      File(fileModel.videoThumbnail),
                      fit: BoxFit.cover, width: 60, height: 60,
                    ),
                    Center(
                      child: Container(width: 30, height: 30,
                        child: Icon(
                          Entypo.controller_play, size: 20, color: Colors.white,
                        ),
                        decoration: BoxDecoration(color: Colors.black54,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.all(0),
                      ),
                    )
                  ],
                ),
              ),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  void unZip(FileModel fileModel) {
    String path = appBarCallBacks.getCurrentPath();
    String name = fileModel.name.split('.').toList()[0];

    path = path + '/' + name;
    Directory dir = Directory(path);

    if (!dir.existsSync()) {
      dir.createSync();
    } else {
      String dirName = name + '_1';
      dir = Directory(appBarCallBacks.getCurrentPath() + '/' + dirName);

      print('Path before: ' + dir.path);
      if(dir.existsSync()){
        dirName = getDirName(fileModel.path, 1, name, dirName);
        print('Dir name: ' + dirName);
        name = dirName;
      }else{
        name = name + '_1';
        print('Name: ' + name);
      }
      path = appBarCallBacks.getCurrentPath() +'/' + name;
      dir = Directory(path);
      dir.createSync();
      print('Path after: ' + dir.path);
    }

    List<int> bytes = File(fileModel.path).readAsBytesSync();
    Archive archive = ZipDecoder().decodeBytes(bytes);

    // Extract the contents of the Zip archive to disk.
    for (ArchiveFile file in archive) {
      String filename = file.name;
      if (file.isFile) {
        List<int> data = file.content;
        File(dir.path + '/' + filename)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory(dir.path + '/' + filename)
          ..create(recursive: true);
      }
    }

    File file = File(path);
    FileStat fileStat = file.statSync();
    int count = dir.listSync().length;
    FileModel newFileModel = FileModel(
      dirFilesCount: count,
      formattedSize: getFileSize(fileStat.size),
      isSelected: false,
      fileType: 'Directory',
      uri: file.uri,
      size: fileStat.size,
      path: file.path,
      modifiedDate: fileStat.modified,
      changedDate: fileStat.changed,
      accessedDate: fileStat.accessed,
      name: name,
      fileExtension: FILE_TYPE.DIRECTORY,
    );

    appBarCallBacks.unZipSuccess(newFileModel);

  }

  String getDirName(String path, int number, String mainName, String dirName){

    String dirPath = appBarCallBacks.getCurrentPath() + '/' + dirName;

    Directory dir = Directory(dirPath);
    print('Path: ' + dirPath + ', Is exists: ' + dir.existsSync().toString());
    print('Name: ' + mainName + ', DirName: ' + dirName);

    String newDirName = '';

    bool isFound = false;
    while(!isFound){
      if(dir.existsSync()){
        number += 1;
        print('Number in if: ' + number.toString());
        newDirName = mainName + '_' + number.toString();
        print('Main name in while: ' + mainName);
        dirPath = appBarCallBacks.getCurrentPath() + '/' + newDirName;
        dir = Directory(dirPath);
      }else{
        print('Number in else: ' + number.toString());
        isFound = true;
      }
    }

    List<String> list = dir.path.split('/').toList();

    String tempName = list[list.length -1];

    print('Temp name: ' + tempName);

   /* if(dir.existsSync()){
      getDirName(path, number++, name);
      print('Path: ' + dirPath);
    }
    print('Path: ' + dirPath);*/
    return tempName;

  }

  String getDateTime(DateTime dateTime) {
    DateFormat format = DateFormat('d MMMM yyyy');
    return format.format(dateTime);
  }

  String getSizeOrItems(FileModel fileModel) {
    return fileModel.fileExtension == FILE_TYPE.DIRECTORY && fileModel.dirFilesCount > 1
        ? fileModel.dirFilesCount.toString() +  ' Items' :
        fileModel.fileExtension == FILE_TYPE.DIRECTORY && fileModel.dirFilesCount <= 1
            ? fileModel.dirFilesCount.toString() + ' Item' :
    fileModel.formattedSize;
  }
}
