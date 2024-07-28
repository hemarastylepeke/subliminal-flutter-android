import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:accordion/accordion.dart';
import 'audio_manager.dart';
import 'database_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'dart:math';
import 'dart:io';

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
  TextEditingController _leftFreqController = TextEditingController();
  TextEditingController _rightFreqController = TextEditingController();
  bool _isGenerating = false;

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
    _leftFreqController.dispose();
    _rightFreqController.dispose();
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

  Future<void> _generateAndPlayBeats() async {
    final int sampleRate = 44100; // Standard sample rate
    final int duration = 10; // Duration in seconds
    final int numSamples = sampleRate * duration;

    double frequencyLeft = double.tryParse(_leftFreqController.text) ?? 440.0;
    double frequencyRight = double.tryParse(_rightFreqController.text) ?? 445.0;

    // Generate PCM data for both channels
    Uint8List leftChannel =
        generateSineWave(numSamples, sampleRate, frequencyLeft);
    Uint8List rightChannel =
        generateSineWave(numSamples, sampleRate, frequencyRight);

    // Combine channels into a single audio buffer
    Uint8List combinedBuffer = combineChannels(leftChannel, rightChannel);

    // Save PCM data to a temporary file and play it
    final file = await _writeToFile(combinedBuffer);
    await _audioPlayer.play(DeviceFileSource(file.path));
    setState(() {
      _isGenerating = true;
    });
  }

  Uint8List generateSineWave(int numSamples, int sampleRate, double frequency) {
    Uint8List buffer =
        Uint8List(numSamples * 2); // 2 bytes per sample (16-bit audio)
    for (int i = 0; i < numSamples; i++) {
      double t = i / sampleRate;
      int sample = (32767.0 * sin(2.0 * pi * frequency * t)).toInt();
      buffer[2 * i] = sample & 0xFF; // LSB
      buffer[2 * i + 1] = (sample >> 8) & 0xFF; // MSB
    }
    return buffer;
  }

  Uint8List combineChannels(Uint8List leftChannel, Uint8List rightChannel) {
    assert(leftChannel.length == rightChannel.length);
    Uint8List combinedBuffer = Uint8List(leftChannel.length * 2);
    for (int i = 0; i < leftChannel.length / 2; i++) {
      combinedBuffer[4 * i] = leftChannel[2 * i];
      combinedBuffer[4 * i + 1] = leftChannel[2 * i + 1];
      combinedBuffer[4 * i + 2] = rightChannel[2 * i];
      combinedBuffer[4 * i + 3] = rightChannel[2 * i + 1];
    }
    return combinedBuffer;
  }

  Future<File> _writeToFile(Uint8List data) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/binaural_beats.pcm');
    await file.writeAsBytes(data);
    return file;
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
          margin: const EdgeInsets.all(5.0),
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
                      : const SizedBox(width: 50, height: 50),
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
                'Sounds',
                style: TextStyle(
                  color: primaryColor,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Frequencies'),
              Tab(text: 'Beats'),
              Tab(text: 'Music'),
            ],
            indicatorColor: primaryColor,
            labelColor: primaryColor,
            unselectedLabelColor: Colors.white,
          ),
        ),
        body: TabBarView(
          children: [
            // Frequencies Tab
            Stack(
              fit: StackFit.expand, // Ensure Stack covers the entire screen
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
                      top: kToolbarHeight), // Adjust padding for the tab bar
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0)
                        .copyWith(bottom: 80.0),
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 90.0, bottom: 16),
                        child: Text(
                          'Solfeggio Frequencies',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Description Container
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 22, 22, 22),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Solfeggio frequencies are a set of frequencies that are believed to have healing properties when listened to through music or on its own.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      _buildAudioList(_solfeggioFrequencies),
                      const Padding(
                        padding: EdgeInsets.only(top: 16.0, bottom: 16),
                        child: Text(
                          'Bonus Frequencies',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Description Container
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 22, 22, 22),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Our Bonus frequencies can be used to enhance the effectiveness of the subliminal messages. These frequencies are designed to influence brain activity or physiological responses in ways that complement the intended messages.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      _buildAudioList(_bonusFrequencies),
                    ],
                  ),
                ),
              ],
            ),

            // Generate Binaural Beats Tab
            Stack(
              fit: StackFit.expand,
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
                  padding: const EdgeInsets.only(top: kToolbarHeight),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 22, 22, 22),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Generate Binaural Beats',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _leftFreqController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Left Ear Frequency (Hz)',
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: const TextStyle(color: Colors.black),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _rightFreqController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Right Ear Frequency (Hz)',
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: const TextStyle(color: Colors.black),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed:
                                _isGenerating ? null : _generateAndPlayBeats,
                            child: Text(_isGenerating
                                ? 'Generating...'
                                : 'Generate and Play'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Music tab
            Stack(
              fit: StackFit.expand,
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
                  padding: const EdgeInsets.only(top: kToolbarHeight),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 22, 22, 22),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Music will go here',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
