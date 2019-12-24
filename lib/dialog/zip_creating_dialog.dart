import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:download_manager/abstracts/app_bar_callbacks.dart';
import 'package:download_manager/locale/locales.dart';
import 'package:download_manager/model/file_model.dart';
import 'package:download_manager/util/util.dart';
import 'package:download_manager/util/widget_utils.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';

class ZipCreatingDialog extends StatefulWidget {
  List<SelectedFileModel> selectedList;
  AppBarCallBacks appBarCallBacks;
  String currentPath;

  ZipCreatingDialog(this.selectedList, this.appBarCallBacks, this.currentPath);

  @override
  _ZipCreatingDialogState createState() => _ZipCreatingDialogState(this.selectedList, this.appBarCallBacks, this.currentPath);
}

class _ZipCreatingDialogState extends State<ZipCreatingDialog> {

  List<SelectedFileModel> selectedList;
  AppBarCallBacks appBarCallBacks;
  String currentPath;

  _ZipCreatingDialogState(this.selectedList, this.appBarCallBacks, this.currentPath);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500)).then((value){
      createZip(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      shape: WidgetUtils.bigButtonShape,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(AppLocalizations.of(context).creatingZip, style: Theme.of(context).textTheme.headline,),
          ),

          Container(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(AppLocalizations.of(context).pleaseWait +  '...', style: Theme.of(context).textTheme.subtitle,),
          )
        ],
      ),
    );
  }

  void createZip(BuildContext context) async {
    var encoder = ZipFileEncoder();
    DateTime dateTime = DateTime.now();
    String name = 'Archive' + dateTime.millisecondsSinceEpoch.toString() + '.zip';
    String path = currentPath + '/' + name;
    encoder.create(path);
    for(SelectedFileModel selectedFileModel in selectedList){
      if(selectedFileModel.fileModel.fileExtension != FILE_TYPE.DIRECTORY) {
        File file = File(selectedFileModel.fileModel.path);
        encoder.addFile(file, selectedFileModel.fileModel.name);
      }else{
        Directory dir = Directory(selectedFileModel.fileModel.path);
        encoder.addDirectory(dir);
      }
    }
    encoder.close();

    File file = File(path);
    FileStat fileStat = file.statSync();

    String nameWithoutExtension = name.split('.').toList()[0];

    FileModel fileModel = FileModel(
      videoThumbnail: '',
      fileExtension: FILE_TYPE.ZIP,
      name: name,
      accessedDate: fileStat.accessed,
      changedDate: fileStat.changed,
      modifiedDate: fileStat.modified,
      path: path,
      size: fileStat.size,
      uri: file.uri,
      fileType: 'zip',
      isSelected: false,
      formattedSize: filesize(fileStat.size),
      nameWithoutExtension: nameWithoutExtension,
      dirFilesCount: 0
    );

    appBarCallBacks.zipCreated(fileModel);
    /*UP_DOWN_SORT_TYPES upDownSortType = Util.getUpDownSortType();
    upDownSortType == UP_DOWN_SORT_TYPES.ASCENDING
        ? appBarCallBacks.sortAscendingList(Util.getSortType())
        : appBarCallBacks.sortDescendingList(Util.getSortType());*/
    Navigator.pop(context);
  }
}
