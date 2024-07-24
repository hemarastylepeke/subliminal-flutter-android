import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:accordion/accordion.dart';
import 'audio_manager.dart';
import 'database_helper.dart';

const primaryColor = Color(0xFF00DC82);
const borderColor = Color(0xFF0f172a);
const dropdownBackgroundColor = Color(0xFF1e293b);

class Music extends StatefulWidget {
  const Music({Key? key}) : super(key: key);

  @override
  _MusicState createState() => _MusicState();
}

class _MusicState extends State<Music> with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  List<Map<String, dynamic>> _solfeggioFrequencies = [];
  List<Map<String, dynamic>> _bonusFrequencies = [];
  int? _playingIndex;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioManager.instance.audioPlayer;
    _loadAudioFiles();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  void _togglePlayPause(String path, int index) async {
    if (_playingIndex == index) {
      await _audioPlayer.pause();
      setState(() {
        _playingIndex = null;
      });
    } else {
      await _audioPlayer.play(AssetSource(path));
      setState(() {
        _playingIndex = index;
      });
    }
  }

  Widget _buildAnimatedWave() {
    return ScaleTransition(
      scale: _animationController,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Icon(Icons.bar_chart, color: Colors.white),
      ),
    );
  }

  Widget _buildAudioList(List<Map<String, dynamic>> audioFiles) {
    return Column(
      children: audioFiles.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> audio = entry.value;
        return Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Accordion(
                maxOpenSections: 1,
                headerBackgroundColor: borderColor,
                headerPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                children: [
                  AccordionSection(
                    isOpen: false,
                    header: Text(audio['title'],
                        style: const TextStyle(color: Colors.white)),
                    content: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(audio['description'],
                          style: const TextStyle(color: Colors.white)),
                    ),
                    contentBackgroundColor: dropdownBackgroundColor,
                    rightIcon: const Icon(
                      Icons.arrow_drop_down_outlined,
                      color: primaryColor,
                      size: 35,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Buttons Container
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: Icon(
                            _playingIndex == index
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 30,
                            color: primaryColor,
                          ),
                          onPressed: () =>
                              _togglePlayPause(audio['path'], index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.stop,
                              size: 30, color: Colors.red),
                          onPressed: () {
                            _audioPlayer.stop();
                            setState(() {
                              _playingIndex = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  // Animated Wave Container
                  _playingIndex == index
                      ? _buildAnimatedWave()
                      : Container(width: 50, height: 50),
                ],
              ),
            ],
          ),
        );
      }).toList(),
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
          Padding(
            padding: const EdgeInsets.only(
                top: 80.0, bottom: 80.0), // Adjust top and bottom padding
            child: ListView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0), // Add horizontal padding
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 8.0), // Adjust vertical padding
                  child: Text(
                    'Solfeggio Frequencies',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildAudioList(_solfeggioFrequencies),
                const Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 8.0), // Adjust vertical padding
                  child: Text(
                    'Bonus Frequencies',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildAudioList(_bonusFrequencies),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
