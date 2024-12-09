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

  List<Map<String,dynamic>> pictureList = [];
  late DatabaseHelper databaseHelper;
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseHelper();
    _initializeDatabase();
  }

  // 画像パスを取得
  // indexは0から始まるため、+1している
  Future<void> _initializeDatabase() async {
    var imageData = await databaseHelper.getImageInfo(index: widget.index+1);
    setState(() {
      pictureList = imageData;
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    // 画像のロード中
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    // ロードが完了後実行
    final picture = InkWell(
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
          child: Image.file(File(pictureList[0]['ImagePath'])),
        ),
      ),
    );

    return picture;
  }
}
