import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer';
import 'package:flutter/material.dart';

class DatabaseHelper {
  static const String dbName = 'user_database.db';
  static const String imageTable = 'Image';
  static const String musicTable = 'Music';

  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getDatabasesPath();
    final dbPath = join(directory, dbName);

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS $imageTable (
            ImageId INTEGER PRIMARY KEY,
            ImagePath TEXT,
            Place TEXT,
            Time TEXT,
            Description TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS $musicTable (
            ImageId INTEGER,
            MusicId INTEGER,
            MusicPath TEXT,
            Title TEXT,
            Artist TEXT,
            Album TEXT,
            AlbumImagePath TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertImage({required String imagePath}) async {
    final dbClient = await db;
    int id = await dbClient.insert(imageTable, {'ImagePath': imagePath});
    log('Image inserted with ID: $id and Path: $imagePath');
  }

  Future<void> insertMusic({
    required int imageId,
    int? musicId,
    String? musicPath,
    String? title,
    String? artist,
    String? album,
    String? albumImagePath,
  }) async {
    final dbClient = await db;
    await dbClient.insert(musicTable, {
      'ImageId': imageId,
      if (musicId != null) 'MusicId': musicId,
      if (musicId == null) 'MusicPath': musicPath,
      'Title': title,
      'Artist': artist,
      'Album': album,
      if (albumImagePath != null) 'AlbumImagePath': albumImagePath,
    });
  }

  Future<void> deleteData({required int imageId}) async {
    final dbClient = await db;
    await dbClient.transaction((txn) async {
      await txn.delete(imageTable, where: 'ImageId = ?', whereArgs: [imageId]);
      await txn.delete(musicTable, where: 'ImageId = ?', whereArgs: [imageId]);
    });
  }

  Future<void> updateImage({
    required int imageId,
    required String place,
    required String time,
    required String description,
  }) async {
    final dbClient = await db;
    await dbClient.update(
      imageTable,
      {
        'Place': place,
        'Time': time,
        'Description': description,
      },
      where: 'ImageId = ?',
      whereArgs: [imageId],
    );
  }

  Future<void> updateMusic({
    required int imageId,
    int? musicId,
    String? musicPath,
    String? title,
    String? artist,
    String? album,
    String? albumImagePath,
  }) async {
    final dbClient = await db;
    await dbClient.update(
      musicTable,
      {
        if (musicId == null) 'MusicPath': musicPath,
        'Title': title,
        'Artist': artist,
        'Album': album,
        if (musicId != null) 'MusicId': musicId,
        if (albumImagePath != null) 'AlbumImagePath': albumImagePath,
      },
      where: 'ImageId = ?',
      whereArgs: [imageId],
    );
  }

  Future<List<Map<String, dynamic>>> getImageInfo({int? index}) async {
    final dbClient = await db;
    if (index != null) {
      final List<Map<String, dynamic>> result = await dbClient.query(imageTable, where: 'ImageId = ?', whereArgs: [index]);
      return result;
    } else {
      final List<Map<String, dynamic>> result = await dbClient.query(imageTable);
      print('Image info result: $result');
      return result;
    }
    
  }

  Future<List<Map<String, dynamic>>> getMusicInfo({required int imageId}) async {
    final dbClient = await db;
    final result = await dbClient.query(musicTable, where: 'ImageId = ?', whereArgs: [imageId]);
    print('Music Data : $result');
    return result;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseHelper();
  await dbHelper.insertImage(imagePath: 'path/to/image');
  await dbHelper.insertImage(imagePath: 'path/to/imageas');
  await dbHelper.insertMusic(
    imageId: 1,
    title: 'title',
    artist: 'artist',
    album: 'album',
  );
  await dbHelper.updateImage(
    imageId: 1,
    place: 'place',
    time: 'time',
    description: 'description',
  );
  await dbHelper.updateMusic(
    imageId: 1,
    title: 'new title',
    artist: 'new artist',
    album: 'new album',
  );
  await dbHelper.deleteData(imageId: 1);
  final imageInfo = await dbHelper.getImageInfo();
  for (var element in imageInfo) {
    print(element);
  }
  final musicInfo = await dbHelper.getMusicInfo(imageId: 1);
  for (var element in musicInfo) {
    print(element);
  }
}