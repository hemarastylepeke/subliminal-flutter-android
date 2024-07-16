import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'audio_manager.dart';
import 'database_helper.dart';

const primaryColor = Color(0xFF00DC82);

class Music extends StatefulWidget {
  const Music({Key? key}) : super(key: key);

  @override
  _MusicState createState() => _MusicState();
}

class _MusicState extends State<Music> {
  late AudioPlayer _audioPlayer;
  List<Map<String, dynamic>> _solfeggioFrequencies = [];
  List<Map<String, dynamic>> _bonusFrequencies = [];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioManager.instance.audioPlayer;
    _loadAudioFiles();
  }

  void _loadAudioFiles() async {
    final dbHelper = DatabaseHelper();
    final solfeggioFiles = await dbHelper.getSolfeggioFrequencies();
    final bonusFiles = await dbHelper.getBonusFrequencies();

    setState(() {
      _solfeggioFrequencies = solfeggioFiles;
      _bonusFrequencies = bonusFiles;
    });
  }

  void _playAudio(String path) async {
    await _audioPlayer.play(AssetSource(path));
  }

  void _pauseAudio() async {
    await _audioPlayer.pause();
  }

  void _stopAudio() async {
    await _audioPlayer.stop();
  }

  Widget _buildAudioList(List<Map<String, dynamic>> audioFiles) {
    return ListView.builder(
      itemCount: audioFiles.length,
      itemBuilder: (context, index) {
        final audio = audioFiles[index];
        return ListTile(
          title: Text(audio['title']),
          subtitle: Text(audio['description']),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () => _playAudio(audio['path']),
              ),
              IconButton(
                icon: const Icon(Icons.pause),
                onPressed: _pauseAudio,
              ),
              IconButton(
                icon: const Icon(Icons.stop),
                onPressed: _stopAudio,
              ),
            ],
          ),
        );
      },
    );
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
              children: [
                Expanded(child: _buildAudioList(_solfeggioFrequencies)),
                Expanded(child: _buildAudioList(_bonusFrequencies)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
