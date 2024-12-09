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

  late int imageId = widget.pictureData[0];
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
    setState(() {
      musicList = musicData[0];
    });
  }


  @override
  Widget build(BuildContext context) {
    final imagePath = widget.pictureData[1];
    var place = (widget.pictureData[2]!=null)?widget.pictureData[2]:"";
    var time = (widget.pictureData[3]!=null)?widget.pictureData[3]:"";
    var description = (widget.pictureData[4]!=null)?widget.pictureData[4]:"";

    var title = (musicList[3]!=null)?musicList[3]:"";
    var artist = (musicList[4]!=null)?musicList[4]:"";
    var album = (musicList[5]!=null)?musicList[5]:"";


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
                          setState(() => {
                            databaseHelper.updateMusic(imageId: imageId, musicPath: musicFile.path, title: tag[0].toString(), artist: tag[1].toString(), album: tag[2].toString()),
                            // pathStr = musicFile.path.toString(), 
                            title = tag[0].toString(),
                            artist = tag[1].toString(),
                            album = tag[2].toString(),
                            // albumArtByte = buffer,
                            // widget.musicList[widget.index] = [titleLarge, artist, album, base64Encode(albumArtByte)],
                          });
                        } else { // 新規音楽情報の追加
                          setState(() => {
                            databaseHelper.insertMusic(imageId: imageId, musicPath: musicFile.path, title: tag[0].toString(), artist: tag[1].toString(), album: tag[2].toString()),
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
                              setState(() => {
                                databaseHelper.insertMusic(imageId: imageId, musicPath: musicFile.path, title: tag[0].toString(), artist: tag[1].toString(), album: tag[2].toString()),
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