import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:charset_converter/charset_converter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// ファイルを処理する機能を搭載したクラス
// CopyFile: ファイルをコピーする機能を提供するメソッド
// 与えたパスに存在するファイルをアプリ内のassetsフォルダにコピーする
// audioファイル、画像ファイルをコピーするために使用
// GetFile: ファイルを取得するメソッド
// assetsフォルダ内のファイルを取得するために使用
// GetTag等でファイルを処理するために使用
// GetTag: 音楽ファイルからタグを取得するメソッド(mp3のみ現在対応)


class ProcessFile {
  Future<void> copyFileToAssets(String selectedFilePath, String folderName) async {
    // ドキュメントディレクトリのパスを取得
    final directory = await getApplicationDocumentsDirectory();
    final targetDirectory = Directory(p.join(directory.path, folderName));

    // フォルダが存在しない場合は作成
    if (!await targetDirectory.exists()) {
      await targetDirectory.create(recursive: true);
    }

    final fileName = p.basename(selectedFilePath);
    final newPath = p.join(targetDirectory.path, fileName);

    // ファイルをコピー
    await File(selectedFilePath).copy(newPath);
  }

  // 与えたデータをファイルとして保存する
  Future<String> saveDataToFile(Uint8List data, int imageId, String folderName) async {
    final directory = await getApplicationDocumentsDirectory();
    final targetDirectory = Directory(p.join(directory.path, folderName));
    // フォルダが存在しない場合は作成
    if (!await targetDirectory.exists()) {
      await targetDirectory.create(recursive: true);
    }

    late final String fileName;
    if (folderName == "audio") {
      fileName = 'audio_$imageId.mp3';
    } else if (folderName == "image") {
      fileName = 'image_$imageId.jpg';
    }

    final path = p.join(targetDirectory.path, fileName);
    final file = File(path);
    // 同名のファイルが存在する場合は削除
    if (await file.exists()) {
      await file.delete();
    }

    await file.writeAsBytes(data);

    return path;
  }

  Future<File> GetAudioFileFromLocal() async {
    FilePickerResult? result;
    result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Please Play Music File', type: FileType.audio
    );
    if (result != null) {
      File file = File(result.files.single.path!);
      copyFileToAssets(result.files.single.path!,"audio");
      return file;
    } else {
      return File('');
    }
  }

  Future<List<String>> GetTag(File file) async {
    Uint8List tags = await file.readAsBytes();
    tags = tags.sublist(tags.length - 128, tags.length);
    String title = await CharsetConverter.decode("Shift_JIS", tags.sublist(3,33));
    String artist =  await CharsetConverter.decode("Shift_JIS", tags.sublist(33,63));
    String album =  await CharsetConverter.decode("Shift_JIS", tags.sublist(63,93));
    print('Title: $title');
    print('Artist: $artist');
    print('Album: $album');
    return [title, artist, album];
  }

  Future<Uint8List?> extractAlbumArt(File file) async {
  final bytes = await file.readAsBytes();

  // 最初の10バイトを読み取り、ID3 タグの存在を確認する
  if (bytes.length < 10 || String.fromCharCodes(bytes.sublist(0, 3)) != "ID3") {
    // ID3 タグが存在しない場合、アルバムアートは見つかりません
    // return Uint8List.fromList([]);
    return null;
  }

  // ID3 タグのバージョンを取得
  final version = bytes[3];
  final majorVersion = bytes[4];

  // ヘッダーのサイズを取得
  var headerSize = (bytes[6] & 0x7F) * 0x200000 +
      (bytes[7] & 0x7F) * 0x4000 +
      (bytes[8] & 0x7F) * 0x80 +
      (bytes[9] & 0x7F);

  // ヘッダーサイズにフラグのサイズを加える
  if ((bytes[5] & 0x10) == 0x10) {
    headerSize += 10;
  }

  // アルバムアートのフレームを検索
  var index = 10;
  while (index < headerSize - 10) {
    final frameHeader = String.fromCharCodes(bytes.sublist(index, index + 4));

    if (frameHeader == "\x00\x00\x00\x00") {
      break;
    }

    final frameSize = bytes[index + 4] * 0x1000000 +
        bytes[index + 5] * 0x10000 +
        bytes[index + 6] * 0x100 +
        bytes[index + 7];

    final frameFlags = bytes[index + 8] * 0x100 + bytes[index + 9];

    if (frameHeader == "APIC") {
      // APIC フレーム（アルバムアート）が見つかった場合
      final encoding = bytes[index + 10];
      final mimeTypeStart = index + 11;
      var mimeTypeEnd = mimeTypeStart;
      while (bytes[mimeTypeEnd] != 0) {
        mimeTypeEnd++;
      }
      final mimeType = String.fromCharCodes(bytes.sublist(mimeTypeStart, mimeTypeEnd));

      final descriptionStart = mimeTypeEnd + 1;
      var descriptionEnd = descriptionStart;
      while (bytes[descriptionEnd] != 0) {
        descriptionEnd++;
      }
      final description = String.fromCharCodes(bytes.sublist(descriptionStart, descriptionEnd));

      final imageDataStart = descriptionEnd + 1;
      final imageData = bytes.sublist(imageDataStart, index + frameSize);

      return Uint8List.fromList(imageData);
    }

    index += 10 + frameSize;
  }

  // return Uint8List.fromList([]);
  return null;
}
  
}
