import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:flutter/widgets.dart';

Future<void> connectToSpotify() async {
  try {
    bool result = await SpotifySdk.connectToSpotifyRemote(
      clientId: '062df57dd36f424e8f53edf40fe5f260',
      redirectUrl: 'ar_musicplayer://callback',
    );
    if (result) {
      print('Connected to Spotify');
    }
  } catch (e) {
    print('Failed to connect: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 追加
  await connectToSpotify();
}