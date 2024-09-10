import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../util/processFile.dart';

class AddAlbumArt extends StatefulWidget {
  final Uint8List byte;
  AddAlbumArt({required this.byte});
  @override
  _AddAlbumArtState createState() => _AddAlbumArtState();
}

class _AddAlbumArtState extends State<AddAlbumArt> {

  final processer = ProcessFile();

  @override
  Widget build(BuildContext context) {

    var albumArt = Image.memory(widget.byte, width: 100, height: 100, fit: BoxFit.cover,);

    return Image(image:albumArt.image);
  }
}