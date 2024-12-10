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

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainPage(),
      // home: playerPage(musicPath: "a", picture: XFile("a")),
    );
  }
}



