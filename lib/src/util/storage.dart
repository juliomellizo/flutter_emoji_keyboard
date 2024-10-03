import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'emoji.dart';

class Storage {
  static const _dbName = "emoji_keyboard.db";

  static final Storage _instance = Storage._internal();

  static Database? _database; // Cambia 'based' a '_database' y hazla estática

  factory Storage() {
    return _instance;
  }

  Storage._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _dbName);
    print('Database path: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    print('Creating table Emojis');
    await db.execute('''
      CREATE TABLE Emojis (
        id INTEGER PRIMARY KEY,
        emoji TEXT,
        amount INTEGER,
        UNIQUE(emoji) ON CONFLICT REPLACE
      );
    ''');
  }

  Future<List<Emoji>> fetchAllEmojis() async {
    Database database = await this.database;
    String query = "SELECT * FROM Emojis ORDER BY amount DESC";
    List<Map<String, dynamic>> emojis = await database.rawQuery(query);
    print('Fetched ${emojis.length} emojis from database');
    if (emojis.isNotEmpty) {
      return emojis.map((map) => Emoji.fromDbMap(map)).toList();
    }
    return [];
  }

  Future<int> addEmoji(Emoji emoji) async {
    try {
      Database database = await this.database;
      int id = await database.insert(
        'Emojis',
        emoji.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Inserted emoji: ${emoji.emoji} with id: $id');
      return id;
    } catch (e) {
      print('Error adding emoji: $e');
      return -1;
    }
  }

  Future<int> updateEmoji(Emoji emoji) async {
    try {
      Database database = await this.database;
      int count = await database.update(
        'Emojis',
        emoji.toDbMap(),
        where: 'emoji = ?',
        whereArgs: [emoji.emoji],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Updated emoji: ${emoji.emoji}, rows affected: $count');
      return count;
    } catch (e) {
      print('Error updating emoji: $e');
      return -1;
    }
  }
}
