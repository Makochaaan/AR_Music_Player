import 'package:ar_music_player/const.dart';
import 'package:flutter/material.dart';
import 'page/mainPage.dart';

void main() {
  runApp(const ARMusicPlayerApp());
}

class ARMusicPlayerApp extends StatelessWidget {
  const ARMusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Music Player',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Constants.PRIMARY_COLOR),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}
