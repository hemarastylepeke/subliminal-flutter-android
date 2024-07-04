import 'dart:async';
import '../database_helper.dart';
import '../speech_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

const primaryColor = Color(0xFF00DC82);

class TrueCallerOverlay extends StatefulWidget {
  const TrueCallerOverlay({Key? key}) : super(key: key);

  @override
  State<TrueCallerOverlay> createState() => _TrueCallerOverlayState();
}

class _TrueCallerOverlayState extends State<TrueCallerOverlay> {
  int _currentMessageIndex = 0;
  Timer? _displayTimer;
  Timer? _hideTimer;
  bool _showMessage = true;

  final List<Map<String, String>> _messages = [
    {'category': '3rd eye development', 'message': 'I have a sixth sense'},
    {'category': '3rd eye development', 'message': 'I have a third eye'},
    {
      'category': '3rd eye development',
      'message': 'I have an activated pineal gland'
    },
    {'category': '3rd eye development', 'message': 'I can fly'},
    {'category': '3rd eye development', 'message': 'I can shapeshift'},
    {'category': '3rd eye development', 'message': 'I can astral travel'},
    {
      'category': '3rd eye development',
      'message': 'I can travel to other dimensions'
    },
    {
      'category': '3rd eye development',
      'message': 'There are unlimited dimensions'
    },
    {
      'category': '3rd eye development',
      'message': 'I remember all of my dreams'
    },
    {
      'category': '3rd eye development',
      'message': 'I remember all of my past lives'
    },
    {
      'category': '3rd eye development',
      'message': 'I have access to the akashic records'
    },
    {
      'category': '3rd eye development',
      'message': 'I can fully access my subconscious mind'
    },
    {
      'category': '3rd eye development',
      'message': 'I can fully access my conscious mind'
    },
    {'category': '3rd eye development', 'message': 'I am all-knowing'},
    {'category': '3rd eye development', 'message': 'I am clairaudient'},
    {'category': '3rd eye development', 'message': 'I am clairvoyant'},
    {
      'category': '3rd eye development',
      'message': 'My pineal gland is activated'
    },
    {'category': '3rd eye development', 'message': 'My pineal gland is open'},
    {
      'category': '3rd eye development',
      'message': 'I have access to the akashic records'
    },
    {
      'category': '3rd eye development',
      'message': 'I can see the past, present and future'
    },
    {'category': '3rd eye development', 'message': 'I can manifest anything'},
    {'category': '3rd eye development', 'message': 'I control my destiny'},
    {
      'category': '3rd eye development',
      'message': 'I can tap into my subconscious mind'
    },
    {
      'category': '3rd eye development',
      'message': 'I am programming my subconscious mind'
    },
    {
      'category': '3rd eye development',
      'message': 'My subconscious mind believe all of these messages'
    },
    {
      'category': '3rd eye development',
      'message': 'I am connected to infinite intelligence'
    },
    {
      'category': '3rd eye development',
      'message': 'I have access to all energy'
    },
    {'category': '3rd eye development', 'message': 'I am pure energy'},
    {'category': '3rd eye development', 'message': 'I am light'},
    {
      'category': '3rd eye development',
      'message': 'My birth name is only my name but not who I am'
    },
    {
      'category': '3rd eye development',
      'message': 'I can see through my minds eye'
    },
    {
      'category': '3rd eye development',
      'message': 'My 3rd eye is fully functional'
    },
    {
      'category': '3rd eye development',
      'message': 'No weapon formed against me shall prosper'
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _startMessageRotation();
  }

  Future<void> _initializeDatabase() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.insertCategory('3rd eye development');
    await dbHelper.insertCategory('Accelerated learning');
    await dbHelper.insertCategory('Accept myself');

    for (var entry in _messages) {
      await dbHelper.insertMessage(entry['message']!, entry['category']!);
    }
  }

  void _startMessageRotation() {
    _displayTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final dbHelper = DatabaseHelper();
      List<String> messages = await dbHelper.getMessages();
      setState(() {
        _showMessage = true;
        _currentMessageIndex = (_currentMessageIndex + 1) % messages.length;
        final ttsSettings = Provider.of<TtsSettings>(context, listen: false);
        ttsSettings
            .speak(messages[_currentMessageIndex]); // Speak the current message
      });

      // Hide the message after 2 seconds TO DO: Modify it later
      _hideTimer = Timer(const Duration(seconds: 2), () {
        setState(() {
          _showMessage = false;
        });
      });
    });
  }

  @override
  void dispose() {
    _displayTimer?.cancel();
    _hideTimer?.cancel();
    final ttsSettings = Provider.of<TtsSettings>(context, listen: false);
    ttsSettings.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: 100.0, // Adjusted height to make the overlay more visible
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: GestureDetector(
          onTap: () {
            FlutterOverlayWindow.getOverlayPosition().then((value) {
              print("Overlay Position: $value");
            });
          },
          child: Stack(
            children: [
              Center(
                child: _showMessage
                    ? FutureBuilder<List<String>>(
                        future: DatabaseHelper().getMessages(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Text(
                              snapshot.data![_currentMessageIndex],
                              style: const TextStyle(
                                fontSize: 12.0,
                                color: primaryColor,
                              ),
                              textAlign: TextAlign.center,
                            );
                          }
                        },
                      )
                    : Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
