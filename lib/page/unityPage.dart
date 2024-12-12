import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'playerPage.dart';
import '../util/database.dart';
import 'dart:developer';

class UnityDemoScreen extends StatefulWidget {

  final List<Map<String,dynamic>> pictureList;

  const UnityDemoScreen({Key? key, required this.pictureList}) : super(key: key);

  @override
  State<UnityDemoScreen> createState() => _UnityDemoScreenState();
}

class _UnityDemoScreenState extends State<UnityDemoScreen> {
  static final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  UnityWidgetController? _unityWidgetController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        bottom: false,
        child: WillPopScope(
          onWillPop: () async {
            // Pop the category page if Android back button is pressed.
            return true;
          },
          child: Container(
            color: Colors.yellow,
            child: UnityWidget(
              onUnityCreated: onUnityCreated,
              onUnityMessage: onUnityMessage,
            ),
          ),
        ),
      ),
    );
  }

  // Callback that connects the created controller to the unity controller
  void onUnityCreated(controller) {
    _unityWidgetController = controller;
    // TODO:ゲームオブジェクトを10個作成。名称はimageIdに従う。それぞれのゲームオブジェクトに対して画像パスを渡す。
    // TODO:Unity側のGameObject名等の確認
    for (int i = 0; i < widget.pictureList.length; i++) {
      String objectName = widget.pictureList[i]['ImageId'].toString();
      String imagePath = widget.pictureList[i]['ImagePath'];
      log('Sending message to Unity: objectName=$objectName, imagePath=$imagePath');
      _unityWidgetController!.postMessage('XR Origin','RegisterImagePath',imagePath);
      log('[DONE]Sent message to Unity: objectName=$objectName, imagePath=$imagePath');
       // Send a message to the Unity game
    }
  }

  // Callback that receives messages from the Unity game
  void onUnityMessage(message) {
    print('Received message from Unity: ${message.toString()}');
    int index = int.parse(message.toString());
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => playerPage(imageId: index),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Add this line to ensure widgets are initialized
  final databaseHelper = DatabaseHelper();
  final List<Map<String, dynamic>> pictureData = await databaseHelper.getImageInfo();

  runApp(MaterialApp(
    home: UnityDemoScreen(pictureList: pictureData),
  ));
}