import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'playerPage.dart';

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
    for (int i = 0; i < widget.pictureList.length; i++) {
      String objectName = widget.pictureList[i]['ImageId'].toString();
      _unityWidgetController!.postMessage(objectName,'methodName',widget.pictureList[i]['ImagePath']); // Send a message to the Unity game
    }
    // _unityWidgetController!.postMessage('gameObject','methodName','message'); // Send a message to the Unity game
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

void main() {
  runApp(const MaterialApp(
    home: UnityDemoScreen(pictureList: []),
  ));
}