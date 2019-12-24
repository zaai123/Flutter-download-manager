import 'package:download_manager/model/file_model.dart';
import 'package:download_manager/util/util.dart';

abstract class AppBarCallBacks{

  onSelected(int index, FileModel fileModel);

  onDeselected(int index, FileModel fileModel);

  int listLength();

  List<FileModel> getFilesModelList();

  sortAscendingList(SORT_TYPE sortOrder);

  sortDescendingList(SORT_TYPE sortOrder);

  createFolder(String folderName);

  zipCreated(FileModel fileModel);

  String getCurrentPath();

  unZipSuccess(FileModel fileModel);

  search(String searchString);

  closeSearch();


}