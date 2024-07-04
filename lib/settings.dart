import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './speech_settings.dart';
import './database_helper.dart';
import 'dart:developer';

const primaryColor = Color(0xFF00DC82);

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
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
              const SizedBox(width: 220),
              const Text(
                'Settings',
                style: TextStyle(
                  color: primaryColor,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: primaryColor,
            labelColor: primaryColor,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: 'Overall Settings'),
              Tab(text: 'Manage Subliminals'),
            ],
          ),
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
            const TabBarView(
              children: [
                SoundSettings(), // Speech settings
                MessageSettings(), // Message settings
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// SECTION FOR THE OVERALL SETTINGS.
class SoundSettings extends StatelessWidget {
  const SoundSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ttsSettings = Provider.of<TtsSettings>(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Speech Rate',
                  style: TextStyle(color: Colors.white),
                ),
                Slider(
                  value: ttsSettings.rate,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  label: ttsSettings.rate.toString(),
                  onChanged: (value) {
                    ttsSettings.setRate(value);
                  },
                  activeColor: primaryColor,
                  inactiveColor: Colors.white,
                ),
                const Text(
                  'Volume',
                  style: TextStyle(color: Colors.white),
                ),
                Slider(
                  value: ttsSettings.volume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  label: ttsSettings.volume.toString(),
                  onChanged: (value) {
                    ttsSettings.setVolume(value);
                  },
                  activeColor: primaryColor,
                  inactiveColor: Colors.white,
                ),
                const Text(
                  'Pitch',
                  style: TextStyle(color: Colors.white),
                ),
                Slider(
                  value: ttsSettings.pitch,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  label: ttsSettings.pitch.toString(),
                  onChanged: (value) {
                    ttsSettings.setPitch(value);
                  },
                  activeColor: primaryColor,
                  inactiveColor: Colors.white,
                ),
                const Text(
                  'Language',
                  style: TextStyle(color: Colors.white),
                ),

                // Adding a SizedBox for the gap
                const SizedBox(height: 20.0),

                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0f172a),
                    border: Border.all(color: const Color(0xFF334155)),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      isExpanded:
                          true, // Expand to fill the width of the parent
                      value: ttsSettings.language,
                      items: ttsSettings.languages.map((lang) {
                        return DropdownMenuItem(
                          value: lang,
                          child: SizedBox(
                            width: double
                                .infinity, // Ensure the dropdown items take full width
                            child: Text(
                              lang,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          ttsSettings.setLanguage(value);
                        }
                      },
                      dropdownColor: Colors.black.withOpacity(
                          0.9), // Set the background color of the dropdown
                      elevation: 8, // Adjust elevation of the dropdown menu
                      itemHeight: 48, // Set the height of each dropdown item
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                // Adding a SizedBox for the gap
                const SizedBox(height: 20.0),
                const Text(
                  'Test message',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0f172a),
                          border: Border.all(color: const Color(0xFF334155)),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16.0),
                        child: const Text(
                          'This is a test message',
                          style: TextStyle(color: Color(0xFF00DC82)),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        ttsSettings.speak("This is a test message");
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            const Color.fromARGB(255, 9, 32, 2)),
                        side: WidgetStateProperty.all<BorderSide>(
                            const BorderSide(
                                color: Color.fromARGB(255, 1, 117, 21))),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        foregroundColor:
                            WidgetStateProperty.all<Color>(Colors.white),
                      ),
                      child: const Text('Speak Sample'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ttsSettings.stop();
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            const Color.fromARGB(255, 68, 3, 12)),
                        side: WidgetStateProperty.all<BorderSide>(
                            const BorderSide(
                                color: Color.fromARGB(255, 155, 2, 2))),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        foregroundColor:
                            WidgetStateProperty.all<Color>(Colors.white),
                      ),
                      child: const Text('Stop Sample'),
                    ),
                  ],
                ),
                // Adding a SizedBox for the gap
                const SizedBox(height: 20.0),
                const Text(
                  'Profile Setup',
                  style: TextStyle(color: Colors.white),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // Save settings to database
                        await ttsSettings.saveSettings();

                        // Show notification
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.withOpacity(
                                      0.8), // Border color with opacity
                                ),
                                borderRadius: BorderRadius.circular(
                                    8.0), // Optional: border radius
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Settings saved, restart app.',
                                  style: TextStyle(color: primaryColor),
                                ),
                              ),
                            ),
                            backgroundColor: Colors.black.withOpacity(0.8),
                            duration: const Duration(seconds: 3),
                          ),
                        );

                        // Retrieve settings from database to confirm
                        await ttsSettings.initSettings();

                        // Now you can print or verify the settings if needed
                        log('Updated Settings:');
                        log('Rate: ${ttsSettings.rate}');
                        log('Volume: ${ttsSettings.volume}');
                        log('Pitch: ${ttsSettings.pitch}');
                        log('Language: ${ttsSettings.language}');
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            const Color(0xFF0f172a)),
                        side: WidgetStateProperty.all<BorderSide>(
                            const BorderSide(color: Color(0xFF334155))),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        foregroundColor:
                            WidgetStateProperty.all<Color>(Colors.white),
                      ),
                      child: const Text('Save settings'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Reset settings to defaults
                        ttsSettings.resetToDefaults();

                        // Save settings to database
                        await ttsSettings.saveSettings();

                        // Show notification
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.withOpacity(
                                      0.8), // Border color with opacity
                                ),
                                borderRadius: BorderRadius.circular(
                                    8.0), // Optional: border radius
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Settings reset, restart app.',
                                  style: TextStyle(color: primaryColor),
                                ),
                              ),
                            ),
                            backgroundColor: Colors.black.withOpacity(0.8),
                            duration: const Duration(seconds: 3),
                          ),
                        );

                        // Now you can print or verify the settings if needed
                        log('Settings reset to:');
                        log('Rate: ${ttsSettings.rate}');
                        log('Volume: ${ttsSettings.volume}');
                        log('Pitch: ${ttsSettings.pitch}');
                        log('Language: ${ttsSettings.language}');
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            const Color.fromARGB(255, 68, 3, 12)),
                        side: WidgetStateProperty.all<BorderSide>(
                            const BorderSide(
                                color: Color.fromARGB(255, 155, 2, 2))),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        foregroundColor:
                            WidgetStateProperty.all<Color>(Colors.white),
                      ),
                      child: const Text('Reset settings'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// SECTION FOR MANAGING SUBLIMINALS.
class MessageSettings extends StatefulWidget {
  const MessageSettings({Key? key}) : super(key: key);

  @override
  _MessageSettingsState createState() => _MessageSettingsState();
}

class _MessageSettingsState extends State<MessageSettings> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _messages = [];

  // Controller for the text area in the edit modal
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    List<Map<String, dynamic>> messages = await _dbHelper.getMessagesWithIds();
    setState(() {
      _messages = messages;
    });
  }

  // Method to show edit modal
  Future<void> _editMessage(int messageId, String currentMessage) async {
    _messageController.text =
        currentMessage; // Set initial text in the text area

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            side: BorderSide(
              color: Color(0xFF00DC82), // Border color
              width: 1, // Border width
            ),
          ),
          title: const Text(
            'Click to edit message',
            style: TextStyle(
              color: Colors.white, // Text color
            ),
          ),
          content: TextField(
            controller: _messageController,
            maxLines: null,
            style: const TextStyle(
              color: Colors.white, // Text color
            ),
            decoration: const InputDecoration(
              hintText: 'Enter your message',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.red, // Change text color to red
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                String updatedMessage = _messageController.text.trim();
                if (updatedMessage.isNotEmpty) {
                  await _dbHelper.updateMessage(messageId, updatedMessage);
                  _loadMessages();
                }
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Method to show delete confirmation dialog
  Future<void> _confirmDelete(int messageId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            side: BorderSide(
              color: Color(0xFF00DC82), // Border color
              width: 1, // Border width
            ),
          ),
          title: const Text(
            'Are you sure you want to delete this message?',
            style: TextStyle(
              color: Colors.white, // Text color
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white, // Text color
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red, // Text color
                ),
              ),
              onPressed: () async {
                await _dbHelper.deleteMessage(messageId);
                _loadMessages();
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Method to add a new message
  Future<void> _addMessage() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            side: BorderSide(
              color: Color(0xFF00DC82), // Border color
              width: 1, // Border width
            ),
          ),
          title: const Text(
            'Add a new message',
            style: TextStyle(
              color: Colors.white, // Text color
            ),
          ),
          content: TextField(
            controller: _messageController,
            maxLines: null,
            style: const TextStyle(
              color: Colors.white, // Text color
            ),
            decoration: const InputDecoration(
              hintText: 'Enter your message',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.red, // Change text color to red
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                String newMessage = _messageController.text.trim();
                if (newMessage.isNotEmpty) {
                  await _dbHelper.insertMessage(newMessage, "General");
                  _messageController.clear(); // Clear text field after adding
                  _loadMessages(); // Reload messages from database
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _messages.isEmpty
        ? const Center(
            child: Text(
              'No messages available',
              style: TextStyle(color: Colors.white),
            ),
          )
        : Scaffold(
            backgroundColor:
                Colors.transparent, // Set background to transparent
            floatingActionButton: Padding(
              padding:
                  const EdgeInsets.only(bottom: 60.0), // Add bottom padding
              child: FloatingActionButton(
                onPressed: _addMessage,
                tooltip: 'Add Message',
                backgroundColor: primaryColor.withOpacity(0.4),
                child: const Icon(Icons.add_sharp),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation
                .endDocked, // Adjust location if needed
            body: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                String message = _messages[index]['message'];
                int id = _messages[index]['id'];

                return ListTile(
                  title: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white, // White color for messages
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit a message
                      IconButton(
                        icon: const Icon(Icons.edit),
                        color: Colors.lightBlue,
                        onPressed: () {
                          _editMessage(id, message); // Show edit modal
                        },
                      ),
                      // Delete a message
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () {
                          _confirmDelete(id); // Show delete confirmation dialog
                        },
                      ),
                      // Mark a message as favorite
                      IconButton(
                        icon: Icon(_messages[index]['is_favorite'] == 1
                            ? Icons.favorite
                            : Icons.favorite_outline),
                        color: Colors.purple,
                        onPressed: () async {
                          bool isFavorite =
                              _messages[index]['is_favorite'] == 1;
                          await _dbHelper.updateFavoriteStatus(id, !isFavorite);
                          _loadMessages();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
