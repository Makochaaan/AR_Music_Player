import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../util/database.dart';

void main() {
  runApp(const MaterialApp(home: playerPage(imageId:1)));
}

class playerPage extends StatefulWidget {

  final int imageId;

  const playerPage({super.key, required this.imageId});

  @override
  playerPageState createState() => playerPageState();
}

class playerPageState extends State<playerPage> {
  late AudioPlayer player = AudioPlayer();
  late DatabaseHelper databaseHelper;
  bool isInitialized = false;

  Map<String, dynamic> musicList = {};
  String musicPath = "";

  Map<String, dynamic> pictureList = {};

  
  @override
  void initState() {
    super.initState();

    databaseHelper = DatabaseHelper();
    _initializeDatabase();
    _initializePlayer();
  }

  Future<void> _initializeDatabase() async {
    final musicData = await databaseHelper.getMusicInfo(imageId: widget.imageId); // TODO:Unityより伝播されるIdを取得する
    final pictureData = await databaseHelper.getImageInfo(index: widget.imageId); 
    setState(() {
      musicList = musicData[0];
      musicPath = musicData[0]['MusicPath'];
      pictureList = pictureData[0];
      isInitialized = true;
    });
  }

  Future<void> _initializePlayer() async {
    player = AudioPlayer();
    player.setReleaseMode(ReleaseMode.stop);
    

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await player.setSource(DeviceFileSource(musicPath));
      // await player.resume();
    }); 
  }

  @override
  void dispose() {
    player.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var imagePath = pictureList['ImagePath'];

    if (!isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Simple Player'),
        ),
        body: Column( children:[
          Image.file(File(imagePath)),
          PlayerWidget(player: player,musicData:musicList),
          ]
          )
      );
    }
  }
}

// The PlayerWidget is a copy of "/lib/components/player_widget.dart".
//#region PlayerWidget

class PlayerWidget extends StatefulWidget {
  final AudioPlayer player;
  final Map<String, dynamic> musicData;

  const PlayerWidget({required this.player,required this.musicData,super.key});

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState();
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  PlayerState? playerState;
  Duration? duration0;
  Duration? position0;

  StreamSubscription? durationSubscription;
  StreamSubscription? positionSubscription;
  StreamSubscription? playerCompleteSubscription;
  StreamSubscription? playerStateChangeSubscription;

  bool get isPlaying => playerState == PlayerState.playing;

  bool get isPaused => playerState == PlayerState.paused;

  String get durationText => duration0?.toString().split('.').first ?? '';

  String get positionText => position0?.toString().split('.').first ?? '';

  AudioPlayer get player => widget.player;

  @override
  void initState() {
    super.initState();
    // Use initial values from player
    playerState = player.state;
    player.getDuration().then(
          (value) => setState(() {
            duration0 = value;
          }),
        );
    player.getCurrentPosition().then(
          (value) => setState(() {
            position0 = value;
          }),
        );
    initStreams();
  }

  @override
  void setState(VoidCallback fn) {
    // Subscriptions only can be closed asynchronously,
    // therefore events can occur after widget has been disposed.
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    durationSubscription?.cancel();
    positionSubscription?.cancel();
    playerCompleteSubscription?.cancel();
    playerStateChangeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    print("Music Title:${widget.musicData['Title']}");
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: [
            Text("Music Title:${widget.musicData['Title']}"),
            Column(
              children: [
                Text("Artist:${widget.musicData['Artist']}"),
                Text("Album:${widget.musicData['Album']}"),
              ],),
          ],),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: const Key('play_button'),
              onPressed: isPlaying ? null : play,
              iconSize: 48.0,
              icon: const Icon(Icons.play_arrow),
              color: color,
            ),
            IconButton(
              key: const Key('pause_button'),
              onPressed: isPlaying ? pause : null,
              iconSize: 48.0,
              icon: const Icon(Icons.pause),
              color: color,
            ),
            IconButton(
              key: const Key('stop_button'),
              onPressed: isPlaying || isPaused ? stop : null,
              iconSize: 48.0,
              icon: const Icon(Icons.stop),
              color: color,
            ),
          ],
        ),
        Slider(
          onChanged: (value) {
            final duration = duration0;
            if (duration == null) {
              return;
            }
            final position = value * duration.inMilliseconds;
            player.seek(Duration(milliseconds: position.round()));
          },
          value: (position0 != null &&
                  duration0 != null &&
                  position0!.inMilliseconds > 0 &&
                  position0!.inMilliseconds < duration0!.inMilliseconds)
              ? position0!.inMilliseconds / duration0!.inMilliseconds
              : 0.0,
        ),
        Text(
          position0 != null
              ? '$positionText / $durationText'
              : duration0 != null
                  ? durationText
                  : '',
          style: const TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }

  void initStreams() {
    durationSubscription = player.onDurationChanged.listen((duration) {
      setState(() => duration0 = duration);
    });

    positionSubscription = player.onPositionChanged.listen(
      (p) => setState(() => position0 = p),
    );

    playerCompleteSubscription = player.onPlayerComplete.listen((event) {
      setState(() {
        playerState = PlayerState.stopped;
        position0 = Duration.zero;
      });
    });

    playerStateChangeSubscription =
        player.onPlayerStateChanged.listen((state) {
      setState(() {
        playerState = state;
      });
    });
  }

  Future<void> play() async {
    await player.resume();
    setState(() => playerState = PlayerState.playing);
  }

  Future<void> pause() async {
    await player.pause();
    setState(() => playerState = PlayerState.paused);
  }

  Future<void> stop() async {
    await player.stop();
    setState(() {
      playerState = PlayerState.stopped;
      position0 = Duration.zero;
    });
  }
}
