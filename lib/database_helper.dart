import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'messages.db');
    return await openDatabase(
      path,
      // Since the database schema version is 1, we can increment the version number in order to migrate the new changes for instance if we create a new column.
      version: 1,
      onCreate: (db, version) async {
        // Create message categories database
        await db.execute(
          "CREATE TABLE categories(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)",
        );

        // Create the messages table
        await db.execute(
          "CREATE TABLE messages(id INTEGER PRIMARY KEY AUTOINCREMENT, message TEXT, category_id INTEGER, is_favorite BOOLEAN NOT NULL CHECK (is_favorite IN (0, 1)) DEFAULT 0, FOREIGN KEY(category_id) REFERENCES categories(id))",
        );

        // Create thee speech settings table
        await db.execute(
          "CREATE TABLE speech_settings(id INTEGER PRIMARY KEY, volume REAL, rate REAL, pitch REAL, language TEXT)",
        );

        // Insert default values
        await db.rawInsert(
          "INSERT INTO speech_settings (volume, rate, pitch, language) VALUES (?, ?, ?, ?)",
          [0.5, 0.5, 1.0, 'en-US'],
        );
      },
    );
  }

  Future<void> insertCategory(String name) async {
    final db = await database;
    await db.insert(
      'categories',
      {'name': name},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int?> getCategoryID(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'name = ?',
      whereArgs: [name],
    );
    if (maps.isNotEmpty) {
      return maps.first['id'];
    }
    return null;
  }

  Future<void> insertMessage(String message, String categoryName) async {
    final db = await database;
    int? categoryId = await getCategoryID(categoryName);
    if (categoryId != null) {
      await db.insert(
        'messages',
        {'message': message, 'category_id': categoryId},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<String>> getMessages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('messages');
    return List.generate(maps.length, (i) {
      return maps[i]['message'];
    });
  }

  Future<List<Map<String, dynamic>>> getMessagesWithIds() async {
    final db = await database;
    return await db.query('messages');
  }

  Future<void> deleteMessage(int id) async {
    final db = await database;
    await db.delete(
      'messages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateFavoriteStatus(int id, bool isFavorite) async {
    final db = await database;
    await db.update(
      'messages',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateMessage(int id, String message) async {
    final db = await database;
    await db.update(
      'messages',
      {'message': message},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>> getSpeechSettings() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query('speech_settings');
    return result.isNotEmpty ? result.first : {};
  }

  Future<void> updateSpeechSettings(Map<String, dynamic> settings) async {
    final db = await database;
    await db.update(
      'speech_settings',
      settings,
      where: 'id = 1',
    );
  }
}
