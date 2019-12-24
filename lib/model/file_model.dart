class FileModel {
  String name;
  int size;
  String fileType;
  DateTime modifiedDate;
  DateTime changedDate;
  DateTime accessedDate;
  String path;
  Uri uri;
  FILE_TYPE fileExtension;
  bool isSelected;
  String videoThumbnail;
  String formattedSize;
  int dirFilesCount;
  String nameWithoutExtension;

  FileModel(
      {this.name,
      this.size,
      this.fileType,
      this.modifiedDate,
      this.changedDate,
      this.accessedDate,
      this.path,
      this.uri,
      this.fileExtension,
      this.isSelected,
      this.videoThumbnail,
      this.formattedSize,
      this.dirFilesCount,
      this.nameWithoutExtension});
}

class SelectedFileModel {
  FileModel fileModel;
  int index;

  SelectedFileModel({this.fileModel, this.index});

  FileModel getFileModel(SelectedFileModel selectedFileModel){
    return selectedFileModel.fileModel;
  }

}

enum FILE_TYPE { IMAGE, VIDEO, APK, PDF, TEXT, AUDIO, DIRECTORY, UNKNOWN, ZIP }
