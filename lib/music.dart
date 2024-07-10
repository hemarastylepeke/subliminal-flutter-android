import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'audio_manager.dart'; // Import the AudioManager

const primaryColor = Color(0xFF00DC82);

class Music extends StatefulWidget {
  const Music({Key? key}) : super(key: key);

  @override
  _MusicState createState() => _MusicState();
}

class _MusicState extends State<Music> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioManager.instance.audioPlayer;
  }

  void _playAudio() async {
    await _audioPlayer.play(AssetSource('sample_audio.mp3'));
  }

  void _pauseAudio() async {
    await _audioPlayer.pause();
  }

  void _stopAudio() async {
    await _audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/alternate_logo.png',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 200),
            const Text(
              'Music',
              style: TextStyle(
                color: primaryColor,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/wallpaper2.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: _playAudio,
                  child: const Text('Play Audio'),
                ),
                ElevatedButton(
                  onPressed: _pauseAudio,
                  child: const Text('Pause Audio'),
                ),
                ElevatedButton(
                  onPressed: _stopAudio,
                  child: const Text('Stop Audio'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
