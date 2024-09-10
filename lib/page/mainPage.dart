import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'addImagePage.dart';
import '../component/displayImage.dart';
import '../component/addImageDialog.dart';
import 'unityCameraPage.dart';

class MainPage extends StatefulWidget {
  @override 
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  List<XFile> pictureList = [];
  List<List<String>> musicList = [["","","",""],["","","",""],["","","",""]];

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
        itemCount: pictureList.length+1,
        itemBuilder: (context, index){
          if (index>=pictureList.length || pictureList.isEmpty){
            return InkWell(
              onTap: () async {
                final newListComponent = await showDialog<dynamic>(
                  context: context,
                  builder: (_) {
                    return AddImageDialog();
                  });
                if (newListComponent != null) {
                  if (newListComponent is List<XFile>){
                    setState(() {
                      pictureList.addAll(newListComponent);
                    });
                  } else if (newListComponent is XFile){
                    setState(() {
                      pictureList.add(newListComponent);
                    });
                  }
                };
              },
              child: SizedBox(
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
            return DisplayImageWidget(index: index, pictureList: pictureList, musicList: musicList);
          }
        },
      ),
     

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