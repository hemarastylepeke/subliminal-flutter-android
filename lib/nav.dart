import 'package:flutter/material.dart';
import 'package:flutter_overlay_window_example/subliminals.dart';
import 'package:flutter_overlay_window_example/settings.dart';
import 'package:flutter_overlay_window_example/music.dart';

class Nav extends StatefulWidget {
  const Nav({Key? key}) : super(key: key);

  @override
  State<Nav> createState() => _NavState();
}

class _NavState extends State<Nav> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const Settings(),
    const Music(),
  ];

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Make the background transparent
      body: Stack(
        children: [
          _widgetOptions.elementAt(_selectedIndex),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavigationBar(
              backgroundColor:
                  Colors.transparent, // Make the navigation bar transparent
              elevation: 0, // Remove the shadow
              selectedItemColor:
                  const Color(0xFF00DC82), // Custom color for the selected item
              unselectedItemColor: Colors.white,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.format_list_bulleted_outlined),
                  label: 'Subliminals',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_suggest_outlined),
                  label: 'Settings',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.headset),
                  label: 'Music',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTap,
            ),
          ),
        ],
      ),
    );
  }
}
