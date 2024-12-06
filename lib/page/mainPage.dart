import 'package:flutter/material.dart';
import '../component/displayImage.dart';
import '../component/addImageDialog.dart';
import '../util/database.dart';
import 'unityPage.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override 
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  List<List<dynamic>> pictureList = [];
  List<List<dynamic>> musicList = [];
  late DatabaseHelper databaseHelper;
  
  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseHelper();
    databaseHelper.getImageInfo(pictureList: pictureList);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
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
                databaseHelper = DatabaseHelper();
                final newPictureComponent = await showDialog<dynamic>(
                  context: context,
                  builder: (_) {
                    return const AddImageDialog();
                  });
                if (newPictureComponent != null) {
                  if (newPictureComponent is List<String>){
                    setState(() {
                      for (var i = 0; i < newPictureComponent.length; i++) {
                        databaseHelper.insertImage(imagePath: newPictureComponent[i]);
                      }
                    });
                  } else if (newPictureComponent is String){
                    setState(() {
                      databaseHelper.insertImage(imagePath: newPictureComponent);
                    });
                  }
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
                      return UnityDemoScreen(pictureList: pictureList, musicList: musicList);
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
  }
}