import 'package:flutter/material.dart';
import '../component/displayImage.dart';
import '../component/addImageDialog.dart';
import '../util/database.dart';
import 'unityPage.dart';
import 'dart:developer';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override 
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  List<Map<String, dynamic>> pictureList = [];
  late DatabaseHelper databaseHelper;
  bool isDatabaseInitialized = false;
  
  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseHelper();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    final pictureData = await databaseHelper.getImageInfo();
    setState(() {
      isDatabaseInitialized = true;
      pictureList = pictureData;
    });
  }

  Future<void> _refreshDatabase() async {
    final pictureData = await databaseHelper.getImageInfo();
    log('Database refreshed: ${pictureData.length} items loaded.');
    for (var element in pictureData) {
      log('Item: $element');
    }
    if (mounted) {
        setState(() {
            pictureList = pictureData;
        });
    }
    
  }

  @override
  Widget build(BuildContext context) {
    if (!isDatabaseInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  
    final component = Scaffold(
      appBar: AppBar(
        title: const Text('画像一覧'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 5,
            childAspectRatio: 0.8,
          ),
        itemCount: pictureList.length+1, // 現在登録されている画像数+1
        itemBuilder: (context, index){ // 順次画像を表示
          if (index>=pictureList.length || pictureList.isEmpty){
            // 「画像を追加」窓を追加する処理
            return InkWell(
              onTap: () async {
                try {
                  // ダイアログからの結果を取得
                  final newPictureComponent = await showDialog<dynamic>(
                    context: context,
                    builder: (_) {
                      return const AddImageDialog();
                    },
                  );
                  // 挿入処理
                  if (newPictureComponent != null) {
                    if (newPictureComponent is List<String>) {
                      for (var imagePath in newPictureComponent) {
                        log('Inserting image: $imagePath');
                        await databaseHelper.insertImage(imagePath: imagePath);
                        log('Inserted image: $imagePath');
                      }
                    } else if (newPictureComponent is String) {
                      log('Inserting image: $newPictureComponent');
                      await databaseHelper.insertImage(imagePath: newPictureComponent);
                      log('Inserted image: $newPictureComponent');
                    }
                  }

                  // 挿入後にデータベースをリフレッシュ
                  log('Refreshing database after insertion...');
                  await _refreshDatabase();
                  log('Database refresh complete.');
                } catch (e, stackTrace) {
                  log('Error during image insertion or refresh: $e');
                  log('Stack trace: $stackTrace');
                }
              },
              child: SizedBox( // カードデザイン
                child: Card(
                  margin: const EdgeInsets.all(30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(0, 80, 0, 0),
                    child: Column(
                      children: [
                        Icon(Icons.add_a_photo),
                        Center(
                          child: Text("add Image",style: TextStyle(fontSize: 20.0)),
                        ),
                      ],
                  ),), 
                ),
              ),
            );
          } else {
            // 画像ウィンドウを生成する処理
            return DisplayImageWidget(index: index);
          }
        },
      ),
     

      // TODO：フッター処理
      bottomNavigationBar:Container(
        height: 60,
        color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
            onPressed: () {},
            icon: const Icon(Icons.home),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 1),
              ),
              child:IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return UnityDemoScreen(pictureList: pictureList);
                      //pictureListとmusicListを与える
                    }),
                  );
                  
                },
                icon: const Icon(Icons.camera_alt_rounded),
              ), 
            ),
            
            IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
            ),
          ],
        ),
      ),
    );

    return component;
  }
}