import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Central SQLite helper. Creates Folders and Cards tables with foreign key
/// and ON DELETE CASCADE so deleting a folder removes its cards.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('card_organizer.db');
    return _database!;
  }

  static const int _version = 1;

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folder_name TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_name TEXT NOT NULL,
        suit TEXT NOT NULL,
        image_url TEXT,
        folder_id INTEGER NOT NULL,
        FOREIGN KEY (folder_id) REFERENCES folders(id) ON DELETE CASCADE
      )
    ''');

    await _prepopulateFoldersAndCards(db);
  }

  /// Prepopulate 4 suits (Hearts, Spades, Diamonds, Clubs) and 13 cards per suit (52 cards).
  Future<void> _prepopulateFoldersAndCards(Database db) async {
    const suits = [
      ('Hearts', 'H'),
      ('Spades', 'S'),
      ('Diamonds', 'D'),
      ('Clubs', 'C'),
    ];
    const cardValues = [
      ('Ace', 'A'),
      ('2', '2'),
      ('3', '3'),
      ('4', '4'),
      ('5', '5'),
      ('6', '6'),
      ('7', '7'),
      ('8', '8'),
      ('9', '9'),
      ('10', '0'),
      ('Jack', 'J'),
      ('Queen', 'Q'),
      ('King', 'K'),
    ];
    const baseUrl = 'https://deckofcardsapi.com/static/img';

    final now = DateTime.now().toIso8601String();

    for (final (suitName, suitCode) in suits) {
      final folderId = await db.insert('folders', {
        'folder_name': suitName,
        'timestamp': now,
      });

      for (final (cardName, valueCode) in cardValues) {
        final code = '$valueCode$suitCode';
        await db.insert('cards', {
          'card_name': cardName,
          'suit': suitName,
          'image_url': '$baseUrl/$code.png',
          'folder_id': folderId,
        });
      }
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
