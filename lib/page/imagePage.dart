import 'dart:io';
import 'package:flutter/material.dart';
import '../util/processFile.dart';
import 'dart:typed_data';
import '../util/database.dart';

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
  Uint8List albumArtByte = Uint8List(0);
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
    print('Refreshing database...');
    for (var element in musicData) {
      print('music Item: $element');
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
                    TextButton(
                      child: const Text("Add Music"),
                      onPressed: () async {
                        final processer = ProcessFile();
                        musicFile = await processer.GetAudioFileFromLocal();
                        var tag = await processer.GetTag(musicFile);
                          
                        // TODO: 画像からアルバムアートを取得する
                        // var buffer = await processer.extractAlbumArt(musicFile);
                        // if (buffer != null){
                        // trigger = 1;

                        // 音楽情報の更新
                        if (title != "" || artist != "" || album != "") {
                          await databaseHelper.updateMusic(imageId: imageId, musicPath: musicFile.path, title: tag[0].toString(), artist: tag[1].toString(), album: tag[2].toString());
                          print('Refreshing database after insertion...');
                          await _refreshDatabase();
                          print('Refreshed database after insertion...');
                          setState(() => {
                            // pathStr = musicFile.path.toString(), 
                            title = tag[0].toString(),
                            artist = tag[1].toString(),
                            album = tag[2].toString(),
                            // albumArtByte = buffer,
                            // widget.musicList[widget.index] = [titleLarge, artist, album, base64Encode(albumArtByte)],
                          });
                        } else { // 新規音楽情報の追加
                          await databaseHelper.insertMusic(imageId: imageId, musicPath: musicFile.path, title: tag[0].toString(), artist: tag[1].toString(), album: tag[2].toString());
                          print('Refreshing database after insertion...');
                          await _refreshDatabase();
                          print('Refreshed database after insertion...');
                          setState(() => {
                            // pathStr = musicFile.path.toString(), 
                            title = tag[0].toString(),
                            artist = tag[1].toString(),
                            album = tag[2].toString(),
                            // albumArtByte = buffer,
                            // widget.musicList[widget.index] = [titleLarge, artist, album, base64Encode(albumArtByte)],
                          });
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

      // databaseHelper.close();
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
                              musicFile = await processer.GetAudioFileFromLocal();
                              var tag = await processer.GetTag(musicFile);
                              // var buffer = await processer.extractAlbumArt(musicFile);
                              // if (buffer != null){
                                // trigger = 1;
                              await databaseHelper.insertMusic(imageId: imageId, musicPath: musicFile.path, title: tag[0].toString(), artist: tag[1].toString(), album: tag[2].toString());
                              print('Refreshing database after insertion...');
                              await _refreshDatabase();
                              print('Refreshed database after insertion...');
                              setState(() => {
                                // pathStr = musicFile.path.toString(), 
                                title = tag[0].toString(),
                                artist = tag[1].toString(),
                                album = tag[2].toString(),
                                // albumArtByte = buffer,
                                // widget.musicList[widget.index] = [titleLarge, artist, album, base64Encode(albumArtByte)],
                              });
                              // }                            
                          },
                        ),
                      ),
                    ]),
                    // (trigger==1)?AddAlbumArt(byte: albumArtByte):const Text(""),

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