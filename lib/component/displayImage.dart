import 'dart:io';
import 'package:flutter/material.dart';
import '../page/imagePage.dart';
import '../util/database.dart';

class DisplayImageWidget extends StatefulWidget {
  final int index;

  const DisplayImageWidget({super.key, required this.index});

  @override
  _DisplayImageWidgetState createState() => _DisplayImageWidgetState();
}

class _DisplayImageWidgetState extends State<DisplayImageWidget> {

  List<List<dynamic>> pictureList = [];

  @override
  void initState() {
    super.initState();
    final databaseHelper = DatabaseHelper();
    databaseHelper.getImageInfo(pictureList: pictureList, index: widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return AddInfoPage(pictureData: pictureList[0]);
          }),
        );
        
      },
      
      child: SizedBox(
        child: Card(
          margin: const EdgeInsets.all(30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Image.file(File(pictureList[0][1])),
        ),
      ),
    );
  }
}
