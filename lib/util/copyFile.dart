import 'dart:io';
import 'package:path/path.dart' as p;


// 与えたパスに存在するファイルをアプリ内のassetsフォルダにコピーする
// audioファイル、画像ファイルをコピーするために使用
class CopyFile {
  Future<void> copyFileToAssets(String selectedFilePath, String folderName) async {
    final directory = Directory(p.join(Directory.current.path, 'assets/$folderName'));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final fileName = p.basename(selectedFilePath);
    final newPath = p.join(directory.path, fileName);

    // ファイルをコピー
    await File(selectedFilePath).copy(newPath);
  }
}