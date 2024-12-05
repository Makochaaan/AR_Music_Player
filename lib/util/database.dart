import 'package:sqlite3/sqlite3.dart';

class Database {
  
  // データベースのテーブルを初期化
  void initTable() {
    final db = sqlite3.openInMemory();

    if (db.select('SELECT * FROM Image').isEmpty) {
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
    if (db.select('SELECT * FROM Music').isEmpty) {
      db.execute('''
        CREATE TABLE Music (
          ImageId INTEGER,
          MusicId INTEGER,
          MusicPath TEXT,
          Title TEXT,
          Artist TEXT,
          Album TEXT,
        )
      ''');
    }
    db.dispose(); 
  }

  // データベースに画像データを挿入
  // ボタンのクリックに応じて自動で画像IDを生成
  void insertImage(String imagePath, String place, String time, String description) {
    final db = sqlite3.openInMemory();

    final sqlText = db.prepare('INSERT INTO Image(ImagePath, Place, Time, Description) VALUES (?, ?, ?, ?)');

    sqlText.execute([imagePath, place, time, description]);

    sqlText.dispose();
    db.dispose();
  }

  // データベースに音楽データを挿入
  // 画像ページより選択する際に画像IDを指定する
  // API経由の場合は音楽IDを指定、そこより各種情報を取得
  // ローカルファイルからの場合は音楽IDを指定せず、ファイルパスを指定
  void insertMusic(int imageId,int ?musicId, String ?musicPath, String ?title, String ?artist, String ?album) {
    final db = sqlite3.openInMemory();

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
  void deleteData(int imageId) {
    final db = sqlite3.openInMemory();

    final sqlText = db.prepare('DELETE FROM Image WHERE ImageId = ?;DELETE FROM Music WHERE ImageId = ?;');
    sqlText.execute([imageId, imageId]);
    sqlText.dispose();

    db.dispose();
  }

  void updateImage(int iamgeId, String place, String time, String description) {
    final db = sqlite3.openInMemory();

    final sqlText = db.prepare('UPDATE Image SET Place = ?, Time = ?, Description = ? WHERE ImageId = ?');
    sqlText.execute([place, time, description, iamgeId]);
  }

  void updateMusic(int imageId, int ?musicId, String ?musicPath, String ?title, String ?artist, String ?album) {
    final db = sqlite3.openInMemory();

    if (musicId == null) {
      final sqlText = db.prepare('UPDATE Music SET MusicPath = ?, Title = ?, Artist = ?, Album = ? WHERE ImageId = ?');
      sqlText.execute([musicPath, title, artist, album, imageId]);
    } else {
      final sqlText = db.prepare('UPDATE Music SET Title = ?, Artist = ?, Album = ?, MusicId = ? WHERE ImageId = ?');
      sqlText.execute([title, artist, album, musicId, imageId]);
    } 
  }

}