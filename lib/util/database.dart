import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

class DatabaseHelper {
  
  // データベースのテーブルを初期化
  void initTable() {
    final dbPath = p.join(Directory.current.path, 'assets', 'user_database.db');
    final db = sqlite3.open(dbPath);

    try {
      db.select('DELETE FROM Image');
    } catch(e) {
      db.execute('''
        CREATE TABLE Image (
          ImageId INTEGER PRIMARY KEY,
          ImagePath TEXT,
          Place TEXT,
          Time TEXT,
          Description TEXT
        )
      ''');
    }

    try {
      db.select('DELETE FROM Music');
    } catch(e) {
      db.execute('''
        CREATE TABLE Music (
          ImageId INTEGER,
          MusicId INTEGER,
          MusicPath TEXT,
          Title TEXT,
          Artist TEXT,
          Album TEXT
        )
      ''');
    }
    db.dispose(); 
  }

  // データベースに画像データを挿入
  // ボタンのクリックに応じて自動で画像IDを生成
  void insertImage({required String imagePath, required String place, required String time, required String description}) {
    final dbPath = p.join(Directory.current.path, 'assets', 'user_database.db');
    final db = sqlite3.open(dbPath);

    final sqlText = db.prepare('INSERT INTO Image(ImagePath, Place, Time, Description) VALUES (?, ?, ?, ?)');

    sqlText.execute([imagePath, place, time, description]);

    sqlText.dispose();
    db.dispose();
  }

  // データベースに音楽データを挿入
  // 画像ページより選択する際に画像IDを指定する
  // API経由の場合は音楽IDを指定、そこより各種情報を取得
  // ローカルファイルからの場合は音楽IDを指定せず、ファイルパスを指定
  void insertMusic({required int imageId,int? musicId, String? musicPath, String? title, String? artist, String? album}) {
    final dbPath = p.join(Directory.current.path, 'assets', 'user_database.db');
    final db = sqlite3.open(dbPath);

    // ファイルからの場合
    if (musicId == null) {
      final sqlText = db.prepare('INSERT INTO Music(ImageId, MusicPath, Title, Artist, Album) VALUES (?, ?, ?, ?, ?)');
      sqlText.execute([imageId, musicPath, title, artist, album]);
      sqlText.dispose();
    }

    // API経由の場合
    else {
      final sqlText = db.prepare('INSERT INTO Music(ImageId, MusicId, Title, Artist, Album) VALUES (?, ?, ?, ?, ?)');
      sqlText.execute([imageId, musicId, title, artist, album]);
      sqlText.dispose();
    }
    
    db.dispose();
  }

  // データの削除。画像IDに紐づいた両情報を削除
  // 中間IDを削除した場合、IDを詰める
  void deleteData({required int imageId}) {
    final dbPath = p.join(Directory.current.path, 'assets', 'user_database.db');
    final db = sqlite3.open(dbPath);

    db.execute('BEGIN TRANSACTION');

    try {
      // データの削除
      final deleteImageSql = db.prepare('DELETE FROM Image WHERE ImageId = ?');
      deleteImageSql.execute([imageId]);
      deleteImageSql.dispose();

      final deleteMusicSql = db.prepare('DELETE FROM Music WHERE ImageId = ?');
      deleteMusicSql.execute([imageId]);
      deleteMusicSql.dispose();

      // IDの更新
      final updateImageSql = db.prepare('UPDATE Image SET ImageId = ImageId - 1 WHERE ImageId > ?');
      updateImageSql.execute([imageId]);
      updateImageSql.dispose();

      final updateMusicSql = db.prepare('UPDATE Music SET ImageId = ImageId - 1 WHERE ImageId > ?');
      updateMusicSql.execute([imageId]);
      updateMusicSql.dispose();

      db.execute('COMMIT');

    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    } finally {
      db.dispose();
    }
  }

  void updateImage({required int iamgeId, required String place, required String time, required String description}) {
    final dbPath = p.join(Directory.current.path, 'assets', 'user_database.db');
    final db = sqlite3.open(dbPath);

    final sqlText = db.prepare('UPDATE Image SET Place = ?, Time = ?, Description = ? WHERE ImageId = ?');
    sqlText.execute([place, time, description, iamgeId]);
  }

  void updateMusic({required int imageId, int? musicId, String? musicPath, String? title, String? artist, String? album}) {
    final dbPath = p.join(Directory.current.path, 'assets', 'user_database.db');
    final db = sqlite3.open(dbPath);

    // ファイルからの場合
    if (musicId == null) {
      final sqlText = db.prepare('UPDATE Music SET MusicId = ?, MusicPath = ?, Title = ?, Artist = ?, Album = ? WHERE ImageId = ?');
      sqlText.execute([null, musicPath, title, artist, album, imageId]);
    } else { // API経由の場合
      final sqlText = db.prepare('UPDATE Music SET MusicPath = ?, Title = ?, Artist = ?, Album = ?, MusicId = ? WHERE ImageId = ?');
      sqlText.execute([null, title, artist, album, musicId, imageId]);
    } 
  }

}

// void main() {
//   final databaseHelper = DatabaseHelper();
//   databaseHelper.initTable();
  // for (int i=0; i<10; i++) {
  //   databaseHelper.insertImage(imagePath:"a", place:"a", time:"a", description:"a");
  //   if (i%4 == 0) {
  //     databaseHelper.insertMusic(imageId: i, musicId: 5, title: "b", artist: "b", album: "b");
  //   } else {   
  //     databaseHelper.insertMusic(imageId: i, musicPath: "b", title: "b", artist: "b", album: "b");
  //   }
  // }

  // databaseHelper.deleteData(imageId: 10);
  // databaseHelper.updateImage(iamgeId: 1, place: "b", time: "b", description: "b");
  // databaseHelper.updateMusic(imageId: 1, musicId: 1, title: "c", artist: "c", album: "c");
  // databaseHelper.updateMusic(imageId: 1, musicPath: "c", title: "c", artist: "c", album: "c");

// }