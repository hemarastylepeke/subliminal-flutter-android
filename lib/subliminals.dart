import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

const primaryColor = Color(0xFF00DC82);

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _kPortNameHome = 'UI';
  final _receivePort = ReceivePort();
  SendPort? homePort;
  String? latestMessageFromOverlay;
  final _random = Random();
  final List<OverlayPosition> _positions = [
    const OverlayPosition(0, 0),
    const OverlayPosition(0, -200),
    const OverlayPosition(1, -230),
    const OverlayPosition(0, -259),
    const OverlayPosition(0, 200),
    const OverlayPosition(1, 230),
    const OverlayPosition(0, 259)
  ];

  late StreamController<int> _streamController;
  late Stream<int> _stream;
  late StreamSubscription<int> _streamSubscription;

  bool _isOverlayActive = false;

  @override
  void initState() {
    super.initState();
    if (homePort != null) return;
    IsolateNameServer.registerPortWithName(
      _receivePort.sendPort,
      _kPortNameHome,
    );

    _receivePort.listen((message) {
      setState(() {
        latestMessageFromOverlay = 'Latest Message From Overlay: $message';
      });
    });

    _streamController = StreamController<int>();
    _stream = _streamController.stream;
    _streamSubscription = _stream.listen((_) {
      _moveOverlayRandomly();
    });

    _startStream();
    _initializeOverlayStatus();
  }

  Future<void> _initializeOverlayStatus() async {
    final status = await FlutterOverlayWindow.isActive();
    setState(() {
      _isOverlayActive = status;
    });
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    _streamController.close();
    super.dispose();
  }

  void _startStream() {
    Timer.periodic(const Duration(seconds: 5), (_) {
      _streamController.add(0);
    });
  }

  void _moveOverlayRandomly() {
    final position = _positions[_random.nextInt(_positions.length)];
    FlutterOverlayWindow.moveOverlay(position);
  }

  Future<void> _checkPermissionAndShowModal() async {
    bool isPermissionGranted = await FlutterOverlayWindow.isPermissionGranted();
    if (!isPermissionGranted) {
      await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text(
            "Permission Required",
            style: TextStyle(color: Colors.white), // Text color for title
          ),
          content: const Text(
            "Please grant overlay permission to continue.",
            style: TextStyle(color: Colors.white), // Text color for content
          ),
          backgroundColor: Colors.black, // Background color of the dialog
          shape: const RoundedRectangleBorder(
            side: BorderSide(
                color: Color(0xFF00DC82), width: 1), // Border color and width
            borderRadius:
                BorderRadius.all(Radius.circular(10.0)), // Border radius
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final bool? res =
                    await FlutterOverlayWindow.requestPermission();
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all<Color>(const Color(0xFF0f172a)),
                side: WidgetStateProperty.all<BorderSide>(
                    const BorderSide(color: Color(0xFF334155))),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                ),
                foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
              ),
              child: const Text(
                "Grant Permission",
                style: TextStyle(color: Colors.white), // Text color for button
              ),
            ),
          ],
        ),
      );
    }
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
              'Subliminals',
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
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 110.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder<bool>(
                    future: FlutterOverlayWindow.isPermissionGranted(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data == true) {
                        return _buildOverlayButtons();
                      } else {
                        // Request permission button.
                        return ElevatedButton(
                          onPressed: () async {
                            await _checkPermissionAndShowModal();
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor.withOpacity(0.1),
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(5),
                          ),
                          child: const Icon(Icons.app_settings_alt,
                              size: 40, color: primaryColor),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayButtons() {
    return _isOverlayActive
        ? GestureDetector(
            onTap: () {
              FlutterOverlayWindow.closeOverlay().then((value) {
                setState(() {
                  _isOverlayActive = false;
                });
              });
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pause_rounded,
                  size: 40, color: primaryColor),
            ),
          )
        : GestureDetector(
            onTap: () async {
              if (await FlutterOverlayWindow.isActive()) return;
              await FlutterOverlayWindow.showOverlay(
                enableDrag: true,
                overlayTitle: "X-SLAYER",
                overlayContent: 'Overlay Enabled',
                flag: OverlayFlag.defaultFlag,
                visibility: NotificationVisibility.visibilityPublic,
                positionGravity: PositionGravity.auto,
                height: (MediaQuery.of(context).size.height * 0.6).toInt(),
                width: WindowSize.matchParent,
                startPosition: const OverlayPosition(0, -259),
              );
              setState(() {
                _isOverlayActive = true;
              });
            },
            // Play messages button
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.play_arrow, size: 40, color: primaryColor),
            ),
          );
  }
}
