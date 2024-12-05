import 'package:flutter/material.dart';
// playerPage: 音楽プレイヤー画面
// 引数：db内データid(int)
// 返り値：ページブロック
// 遷移前：unityPage

class PlayerPage extends StatefulWidget {
  final int id;
  const PlayerPage({super.key, required this.id});

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late int id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("音楽再生ページ"),
      ),
      body: const Column(
        // ここにウィジェットを追加
      ),
    );
  }
}