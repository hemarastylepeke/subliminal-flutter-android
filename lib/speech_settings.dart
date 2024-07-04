import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import './database_helper.dart';

class TtsSettings extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  double _rate = 0.5;
  double _volume = 0.5;
  double _pitch = 1.0;
  String _language = "en-US";

  double get rate => _rate;
  double get volume => _volume;
  double get pitch => _pitch;
  String get language => _language;

  List<String> _languages = [];

  List<String> get languages => _languages;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  TtsSettings() {
    initSettings();
    _flutterTts.setLanguage(_language);
    _flutterTts.setSpeechRate(_rate);
    _flutterTts.setVolume(_volume);
    _flutterTts.setPitch(_pitch);
    _loadLanguages();
  }

  Future<void> initSettings() async {
    Map<String, dynamic> settings = await _dbHelper.getSpeechSettings();
    _volume = settings['volume'] ?? _volume;
    _rate = settings['rate'] ?? _rate;
    _pitch = settings['pitch'] ?? _pitch;
    _language = settings['language'] ?? _language;

    _applySettings();
    notifyListeners();
  }

  Future<void> saveSettings() async {
    await _dbHelper.updateSpeechSettings({
      'volume': _volume,
      'rate': _rate,
      'pitch': _pitch,
      'language': _language,
    });
    notifyListeners();
    notifyListeners();
  }

  void resetToDefaults() {
    _rate = 0.5;
    _volume = 0.5;
    _pitch = 1.0;
    _language = "en-US";
    _applySettings();
  }

  void _applySettings() {
    _flutterTts.setVolume(_volume);
    _flutterTts.setSpeechRate(_rate);
    _flutterTts.setPitch(_pitch);
    _flutterTts.setLanguage(_language);
    notifyListeners();
  }

  Future<void> _loadLanguages() async {
    _languages = List<String>.from(await _flutterTts.getLanguages);
    notifyListeners();
  }

  void setRate(double rate) {
    _rate = rate;
    _flutterTts.setSpeechRate(rate);
    notifyListeners();
  }

  void setVolume(double volume) {
    _volume = volume;
    _flutterTts.setVolume(volume);
    notifyListeners();
  }

  void setPitch(double pitch) {
    _pitch = pitch;
    _flutterTts.setPitch(pitch);
    notifyListeners();
  }

  void setLanguage(String language) {
    _language = language;
    _flutterTts.setLanguage(language);
    notifyListeners();
  }

  Future<void> speak(String message) async {
    await _flutterTts.speak(message);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
