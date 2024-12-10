import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../util/processFile.dart';
import '../component/displayAlbumArt.dart';
import 'dart:typed_data';
import 'dart:convert';

class AddInfoPage extends StatefulWidget {

  final XFile picture;
  final List<List<String>> musicList;
  final int index;
  const AddInfoPage({super.key, required this.picture, required this.musicList, required this.index});

  @override
  _AddInfoPageState createState() => _AddInfoPageState();
}

class _AddInfoPageState extends State<AddInfoPage> {

  String title = "";
  String artist = "";
  String album = "";
  String pathStr = "";
  File musicFile = File('');
  Uint8List albumArtByte = Uint8List(0);
  int trigger = 0;

  @override
  Widget build(BuildContext context) {

    if (widget.musicList[widget.index][0] != ""||widget.musicList[widget.index][1] != ""||widget.musicList[widget.index][2] != ""||widget.musicList[widget.index][3] != ""){
      title = widget.musicList[widget.index][0];
      artist = widget.musicList[widget.index][1];
      album = widget.musicList[widget.index][2];
      albumArtByte = base64Decode(widget.musicList[widget.index][3]);
      
      
      return Scaffold(
        appBar: AppBar(
          title: const Text("画像情報ページ"),
        ),
        body: SingleChildScrollView(
          child: Container(
            // padding: EdgeInsets.all(64),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.file(File(widget.picture.path)),
                Column(children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    child: const Column(children: <Widget>[Text("Picture Data")]),
                  ),
                  const Row(children: [Text("Place:"), Text("a"),]),
                  const Row(children: [Text("Time:"),  Text("a"),]),
                ]),
                
                Container(
                  padding: const EdgeInsets.all(32),
                  child: Column(children: <Widget>[
                    const Text("Music"),
                    Text(title),
                    Text(artist),
                    Text(album),
                  AddAlbumArt(byte: albumArtByte),
                  ])
                ),
              ]
            )
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text("画像情報ページ"),
        ),
        body: SingleChildScrollView(
          child: Container(
            // padding: EdgeInsets.all(64),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.file(File(widget.picture.path)),
                Column(children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    child: const Column(children: <Widget>[Text("Picture Data")]),
                  ),
                  const Row(children: [Text("Place:"), Text("a"),]),
                  const Row(children: [Text("Time:"),  Text("a"),]),
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
                            if (widget.musicList[widget.index][0] == ""&&widget.musicList[widget.index][1] == ""&&widget.musicList[widget.index][2] == ""&&widget.musicList[widget.index][3] == ""){
                              final processer = ProcessFile();
                              musicFile = await processer.GetAudioFileFromLocal();
                              var tag = await processer.GetTag(musicFile);
                              // var buffer = await processer.extractAlbumArt(musicFile);
                              // if (buffer != null){
                                trigger = 1;
                                setState(() => {
                                pathStr = musicFile.path.toString(), 
                                title = tag[0].toString(),
                                artist = tag[1].toString(),
                                album = tag[2].toString(),
                                // albumArtByte = buffer,
                                widget.musicList[widget.index] = [title, artist, album, base64Encode(albumArtByte)],
                                });
                              // } else {
                              //   setState(() => {
                              //   pathStr = musicFile.path.toString(), 
                              //   title = tag[0].toString(),
                              //   artist = tag[1].toString(),
                              //   album = tag[2].toString(),
                              //   widget.musicList[widget.index] = [title, artist, album,""],
                              //   });
                              // }
                            }                            
                          },
                        ),
                      ),
                    ]),
                    Text(title),
                    Text(artist),
                    Text(album),
                    (trigger==1)?AddAlbumArt(byte: albumArtByte):const Text(""),

                  ])
                ),
              ]
            )
          ),
        ),
      );
    }
  }
}