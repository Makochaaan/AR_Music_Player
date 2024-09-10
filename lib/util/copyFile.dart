import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CopyFile {
  Future<void> CopyFileToAppFolder(selectedFilePath) async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String appFolderPath = appDirectory.path;
    String fileName = selectedFilePath.split('/').last;
    String newPath = '$appFolderPath/$fileName';

    // ファイルをコピー
    await File(selectedFilePath).copy(newPath);
  }

}