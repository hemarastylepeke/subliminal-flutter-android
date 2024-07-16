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

        // Create the Solfeggio frequencies table
        await _createSolfeggioFrequenciesTable(db);

        // Create the Bonus frequencies table
        await _createBonusFrequenciesTable(db);
      },
    );
  }

  // Function to create selfeggio table
  Future<void> _createSolfeggioFrequenciesTable(Database db) async {
    await db.execute('''
      CREATE TABLE solfeggio_frequencies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        path TEXT
      )
    ''');

    // Insert initial data
    await db.insert('solfeggio_frequencies', {
      'title': 'Physical pain relief & stress relief.',
      'description':
          '174 Hz frequency is helpful for pain relief and for reducing inflammation in the body. It helps to alleviate pain and promote healing.',
      'path': 'selfeggio_174_trimmed.wav',
    });

    await db.insert('solfeggio_frequencies', {
      'title': 'Guilt & Fear diminishment',
      'description':
          '396 Hz helps with liberation and freedom. It is thought to be helpful for releasing feelings of guilt and fear, and for bringing about a sense of change and transformation.',
      'path': 'selfeggio_396_trimmed.wav',
    });

    await db.insert('solfeggio_frequencies', {
      'title': 'Tissue restoration & Healing',
      'description':
          '285 Hz is helpful for tissue and cell regeneration and also said to promote healing, it has been associated with the power of transforming negative emotions and thoughts into positive ones.',
      'path': 'selfeggio_285_trimmed.wav',
    });

    await db.insert('solfeggio_frequencies', {
      'title': 'Trauma Healing',
      'description':
          '417 Hz frequency helps with facilitation and support. It is thought to be helpful for facilitating change and supporting the process of healing and self-improvement.',
      'path': 'selfeggio_285_trimmed.wav',
    });

    await db.insert('solfeggio_frequencies', {
      'title': 'Relaxation & Sleep improvement',
      'description':
          '528 Hz frequency is helpful for repairing DNA and bringing about a sense of transformation and miracles.',
      'path': 'selfeggio_528_trimmed.wav',
    });

    await db.insert('solfeggio_frequencies', {
      'title': 'Improvement in mental balance',
      'description':
          '639 Hz frequency sound helps with connection and relationships. It is thought to be helpful for bringing about a sense of harmony and balance in personal relationships.',
      'path': 'selfeggio_639_trimmed.wav',
    });

    await db.insert('solfeggio_frequencies', {
      'title': 'Detoxification of body & mind',
      'description':
          '741 Hz frequency is helpful for awakening intuition and inner wisdom. It is believed to be helpful for enhancing problem-solving and decision-making abilities.',
      'path': 'selfeggio_741_trimmed.wav',
    });

    await db.insert('solfeggio_frequencies', {
      'title': 'Nervousness & Anxiety relief.',
      'description':
          '852 Hz frequency helps with returning to spiritual order. Specifically with bringing about a sense of connection to a higher power and for opening up spiritual communication.',
      'path': 'selfeggio_852_trimmed.wav',
    });

    await db.insert('solfeggio_frequencies', {
      'title': 'Increased positive energy & clarity.',
      'description':
          'The 963 Hz frequency, also known as the “god frequency,” can help to stimulate a connection with the Crown Chakra, which can help you understand yourself and the world around you on a deeper level.',
      'path': 'selfeggio_963_trimmed.wav',
    });
  }

  // Function to create Bonus frequencies table
  Future<void> _createBonusFrequenciesTable(Database db) async {
    await db.execute('''
      CREATE TABLE bonus_frequencies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        path TEXT
      )
    ''');

    // Insert initial data
    await db.insert('bonus_frequencies', {
      'title': 'Expand consciousness & reduce stress',
      'description':
          'The 432 Hz frequency is more than just a harmonic pitch. It is a tool that can help reduce stress, promote relaxation, expand consciousness and create a deeper connection to nature and the universe.',
      'path': 'bonus_432Hz_trimmed.mp3',
    });
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

  Future<List<Map<String, dynamic>>> getSolfeggioFrequencies() async {
    final db = await database;
    return await db.query('solfeggio_frequencies');
  }

  Future<List<Map<String, dynamic>>> getBonusFrequencies() async {
    final db = await database;
    return await db.query('bonus_frequencies');
  }
}
