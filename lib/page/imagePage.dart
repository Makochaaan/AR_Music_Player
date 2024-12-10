import 'dart:io';
import 'package:flutter/material.dart';
import '../util/processFile.dart';
import '../util/database.dart';
import 'package:audiotags/audiotags.dart';
import 'dart:developer';

class AddInfoPage extends StatefulWidget {

  final Map<String, dynamic> pictureData;
  const AddInfoPage({Key? key, required this.pictureData}) : super(key: key);

  @override
  _AddInfoPageState createState() => _AddInfoPageState();
}

class _AddInfoPageState extends State<AddInfoPage> {

  late int imageId = widget.pictureData['ImageId'];
  Map<String, dynamic> musicList = {};
  File musicFile = File('');
  int trigger = 0;
  

  late DatabaseHelper databaseHelper;

  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseHelper();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    final musicData = await databaseHelper.getMusicInfo(imageId: imageId);
    if (musicData.isEmpty) {
      return;
    } else {
      print('Music Data: $musicData');
      setState(() {
        musicList = musicData[0];
      });
    }
  }

  Future<void> _refreshDatabase() async {
    final musicData = await databaseHelper.getMusicInfo(imageId: imageId);
    log('Refreshing database...');
    log('Refreshing Music Data: $musicData');
    for (var element in musicData) {
      log('music Item: $element');
    }
    if (mounted) {
        setState(() {
            musicList = musicData[0];
        });
    }
  }


  @override
  Widget build(BuildContext context) {
    final imagePath = widget.pictureData['ImagePath'];
    var place = (widget.pictureData['Place']!=null)?widget.pictureData['Place']:"";
    var time = (widget.pictureData['Time']!=null)?widget.pictureData['Time']:"";
    var description = (widget.pictureData['Description']!=null)?widget.pictureData['Description']:"";

    var title = (musicList['Title']!=null)?musicList['Title']:"";
    var artist = (musicList['Artist']!=null)?musicList['Artist']:"";
    var album = (musicList['Album']!=null)?musicList['Album']:"";
    var albumArtPath = (musicList['AlbumImagePath']!=null)?musicList['AlbumImagePath']:"";


    // 音楽情報が存在する場合
    if (title != ""|| artist != ""|| album != ""){
      // albumArtByte = base64Decode(widget.musicList[widget.index][3]);
      final componentWithMusic = Scaffold(
        appBar: AppBar(
          title: const Text("画像情報ページ"),
        ),
        body: SingleChildScrollView(
          child: Container(
            // padding: EdgeInsets.all(64),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.file(File(imagePath)),
                Column(children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    child: const Column(children: <Widget>[Text("Picture Data")]),
                  ),
                  Row(children: [const Text("Place:"), Text(place),]),
                  Row(children: [const Text("Time:"),  Text(time),]),
                  Row(children: [const Text("Description:"), Text(description)],)
                ]),
                
                Container(
                  padding: const EdgeInsets.all(32),
                  child: Column(children: <Widget>[
                    const Text("Music"),
                    Text(title),
                    Text(artist),
                    Text(album),
                    if(albumArtPath != "")Image.file(File(albumArtPath!)),
                    TextButton(
                      child: const Text("Change Music"),
                      onPressed: () async {
                        final processer = ProcessFile();
                        musicFile = await processer.GetAudioFileFromLocal(); // 音楽ファイルのローカルからの取得
                        await processer.saveDataToFile(musicFile.readAsBytesSync(), imageId, 'audio'); // 音楽ファイルの保存(再生時に使用)
                        Tag? tag = await AudioTags.read(musicFile.path); // 取得した音楽ファイルのタグ情報の取得
                        if (tag != null){
                          // 音楽情報の更新
                          if (tag.pictures.isNotEmpty){
                            final albumImagePath = await processer.saveDataToFile(tag.pictures[0].bytes, imageId, 'image');
                            await databaseHelper.updateMusic(imageId: imageId, musicPath: musicFile.path, title: tag.title, artist: tag.trackArtist, album: tag.album, albumImagePath: albumImagePath);
                            print('Refreshing database after updation...');
                            await _refreshDatabase();
                            print('Refreshed database after updation...');
                            setState(() => {
                              title = tag.title,
                              artist = tag.trackArtist,
                              album = tag.album,
                              albumArtPath = albumImagePath,
                            });
                          } else {
                            await databaseHelper.updateMusic(imageId: imageId, musicPath: musicFile.path, title: tag.title, artist: tag.trackArtist, album: tag.album);
                            print('Refreshing database after updation...');
                            await _refreshDatabase();
                            print('Refreshed database after updation...');
                            setState(() => {
                              title = tag.title,
                              artist = tag.trackArtist,
                              album = tag.album,
                            });
                          }
                          
                        }
                      },),
                  // AddAlbumArt(byte: albumArtByte),
                  ])
                ),
              ]
            )
          ),
        ),
      );
      return componentWithMusic;
    } else { // 音楽情報が存在しない場合(初期状態)

      final componentInit = Scaffold(
        appBar: AppBar(
          title: const Text("画像情報ページ"),
        ),
        body: SingleChildScrollView(
          child: Container(
            // padding: EdgeInsets.all(64),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.file(File(imagePath)),
                Column(children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    child: const Column(children: <Widget>[Text("Picture Data")]),
                  ),
                  Row(children: [const Text("Place:"), Text(place),]),
                  Row(children: [const Text("Time:"),  Text(time),]),
                ]),
                
                Container(
                  padding: const EdgeInsets.all(32),
                  child: Column(children: <Widget>[
                    Row(children: <Widget>[
                      const Text("Music"),
                      Container(
                        padding: const EdgeInsets.all(32),
                        child:TextButton( child: const Text('Add Music'), 
                          onPressed: () async {
                            final processer = ProcessFile();
                            musicFile = await processer.GetAudioFileFromLocal(); // 音楽ファイルのローカルからの取得
                            await processer.saveDataToFile(musicFile.readAsBytesSync(), imageId, 'audio'); // 音楽ファイルの保存(再生時に使用)
                            Tag? tag = await AudioTags.read(musicFile.path); // 取得した音楽ファイルのタグ情報の取得
                            log('Inserting music: $musicFile.path');
                            if (tag != null){
                              // 音楽情報の更新
                              if (tag.pictures.isNotEmpty) {
                                // アルバムアートが存在する場合
                                final albumImagePath = await processer.saveDataToFile(tag.pictures[0].bytes, imageId, 'image');
                                await databaseHelper.insertMusic(imageId: imageId, musicPath: musicFile.path, title: tag.title, artist: tag.trackArtist, album: tag.album, albumImagePath: albumImagePath);
                                print('Refreshing database after insertion...');
                                await _refreshDatabase();
                                print('Refreshed database after insertion...');
                                setState(() => {
                                  title = tag.title,
                                  artist = tag.trackArtist,
                                  album = tag.album,
                                  albumArtPath = albumImagePath,
                                });
                              } else {
                                // 音楽情報の更新
                                await databaseHelper.insertMusic(imageId: imageId, musicPath: musicFile.path, title: tag.title, artist: tag.trackArtist, album: tag.album);
                                print('Refreshing database after insertion...');
                                await _refreshDatabase();
                                print('Refreshed database after insertion...');
                                setState(() => {
                                  title = tag.title,
                                  artist = tag.trackArtist,
                                  album = tag.album,
                                });
                              }
                            }
                          },                           
                        ),
                      ),
                    ]),
                  ])
                ),
              ]
            )
          ),
        ),
      );

      // databaseHelper.close();
      return componentInit;
    }
  }
}