import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'audio_manager.dart';
import 'database_helper.dart';

const primaryColor = Color(0xFF00DC82);
const borderColor = Color(0xFF0f172a);

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

  Widget _buildAudioGrid(List<Map<String, dynamic>> audioFiles) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: audioFiles.length,
      itemBuilder: (context, index) {
        final audio = audioFiles[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AudioDetailsPage(audio: audio),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    audio['image_path'],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 10.0,
                  left: 10.0,
                  right: 10.0,
                  child: Text(
                    audio['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
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
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Solfeggio Frequencies',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildAudioGrid(_solfeggioFrequencies),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Bonus Frequencies',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildAudioGrid(_bonusFrequencies),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AudioDetailsPage extends StatefulWidget {
  final Map<String, dynamic> audio;

  const AudioDetailsPage({Key? key, required this.audio}) : super(key: key);

  @override
  _AudioDetailsPageState createState() => _AudioDetailsPageState();
}

class _AudioDetailsPageState extends State<AudioDetailsPage> {
  AudioPlayer get _audioPlayer => AudioManager.instance.audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: primaryColor, // Change the back button color
        ),
        title: Text(
          widget.audio['title'],
          style: const TextStyle(
            color: primaryColor, // Change the title color
          ),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    widget.audio['description'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _isPlaying
                      ? [
                          Container(
                            padding: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF431407)
                                  .withOpacity(0.5), // Background color
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF9A3412), // Border color
                                width: 1.0, // Border width
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.pause),
                              color: Colors.white, // Play button icon color
                              iconSize:
                                  40.0, // Increase the size of the play icon
                              onPressed: () => _audioPlayer.pause(),
                              tooltip: 'Pause',
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Container(
                            padding: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF431407)
                                  .withOpacity(0.5), // Background color
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF9A3412), // Border color
                                width: 1.0, // Border width
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.stop),
                              color: Colors.pink, // Play button icon color
                              iconSize:
                                  40.0, // Increase the size of the play icon
                              onPressed: () => _audioPlayer.stop(),
                              tooltip: 'Stop',
                            ),
                          ),
                        ]
                      : [
                          Container(
                            padding: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: primaryColor
                                  .withOpacity(0.1), // Background color
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.play_arrow),
                              color: Colors.white, // Play button icon color
                              iconSize:
                                  40.0, // Increase the size of the play icon
                              onPressed: () => _audioPlayer
                                  .play(AssetSource(widget.audio['path'])),
                              tooltip: 'Play',
                            ),
                          ),
                        ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
