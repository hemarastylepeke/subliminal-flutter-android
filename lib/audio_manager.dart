import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  AudioManager._privateConstructor();

  static final AudioManager _instance = AudioManager._privateConstructor();

  static AudioManager get instance => _instance;

  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayer get audioPlayer => _audioPlayer;

  void dispose() {
    _audioPlayer.dispose();
  }
}
