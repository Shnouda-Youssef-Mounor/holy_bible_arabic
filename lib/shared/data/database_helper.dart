import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await databaseFactory.getDatabasesPath();
    final path = join(dbPath, 'bible_cache.db');

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          // جدول الكاش الأساسي
          await db.execute('''
            CREATE TABLE cache (
              book TEXT,
              chapter TEXT,
              value TEXT,
              PRIMARY KEY (book, chapter)
            )
          ''');

          // آخر موضع قراءة
          await db.execute('''
            CREATE TABLE last_position (
              book TEXT,
              chapter TEXT,
              verse TEXT
            )
          ''');

          // المفضلة
          await db.execute('''
            CREATE TABLE fav (
              book TEXT,
              chapter TEXT,
              verse TEXT
            )
          ''');

          // جدول الآيات الملونة
          await db.execute('''
            CREATE TABLE highlighted_verses (
              book TEXT,
              chapter TEXT,
              verse_number INTEGER,
              color TEXT,
              PRIMARY KEY (book, chapter, verse_number)
            )
          ''');

          // جدول التأملات
          await db.execute('''
            CREATE TABLE reflections (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              book TEXT,
              chapter TEXT,
              verse_numbers TEXT,
              title TEXT,
              description TEXT
            )
          ''');

          // جدول الملاحظات الصوتية
          await db.execute('''
            CREATE TABLE voice_notes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              book TEXT,
              chapter TEXT,
              verse_number INTEGER,
              file_path TEXT
            )
          ''');
        },
      ),
    );
  }

  // ====== عمليات الكاش ======
  static Future<void> setChapter(
      String book,
      String chapter,
      String value,
      ) async {
    final db = await database;
    await db.insert('cache', {
      'book': book,
      'chapter': chapter,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  static Future<void> setBookChaptersBatch(
      String book,
      Map<String, String> chapters,
      ) async {
    final db = await database;
    final batch = db.batch();

    chapters.forEach((chapter, value) {
      batch.insert(
        'cache',
        {
          'book': book,
          'chapter': chapter,
          'value': value,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });

    await batch.commit(noResult: true);
  }
  static Future<String?> getChapter(String book, String chapter) async {
    final db = await database;
    final result = await db.query(
      'cache',
      where: 'book = ? AND chapter = ?',
      whereArgs: [book, chapter],
    );
    return result.isNotEmpty ? result.first['value'] as String : null;
  }

  // ====== المفضلة ======
  static Future<void> setFav(String book, String chapter, String verse) async {
    final db = await database;
    await db.insert('fav', {
      'book': book,
      'chapter': chapter,
      'verse': verse,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getFav() async {
    final db = await database;
    final result = await db.query('fav');
    return result;
  }

  static Future<void> deleteFav(
    String book,
    String chapter,
    String verse,
  ) async {
    final db = await database;
    await db.delete(
      'fav',
      where: 'book = ? AND chapter = ? AND verse = ?',
      whereArgs: [book, chapter, verse],
    );
  }

  // ====== الآيات الملونة ======
  static Future<void> highlightVerse(
    String book,
    String chapter,
    int verseNumber,
    String color,
  ) async {
    final db = await database;
    await db.insert('highlighted_verses', {
      'book': book,
      'chapter': chapter,
      'verse_number': verseNumber,
      'color': color,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getHighlightedVerses(
    String book,
    String chapter,
  ) async {
    final db = await database;
    return await db.query(
      'highlighted_verses',
      where: 'book = ? AND chapter = ?',
      whereArgs: [book, chapter],
    );
  }

  static Future<void> removeHighlight(
    String book,
    String chapter,
    int verseNumber,
  ) async {
    final db = await database;
    await db.delete(
      'highlighted_verses',
      where: 'book = ? AND chapter = ? AND verse_number = ?',
      whereArgs: [book, chapter, verseNumber],
    );
  }

  // ====== التأملات ======
  static Future<int> addReflection(
    String book,
    String chapter,
    String verseNumbers,
    String title,
    String description,
  ) async {
    final db = await database;
    return await db.insert('reflections', {
      'book': book,
      'chapter': chapter,
      'verse_numbers': verseNumbers,
      'title': title,
      'description': description,
    });
  }

  static Future<List<Map<String, dynamic>>> getReflections(
    String book,
    String chapter,
  ) async {
    final db = await database;
    return await db.query(
      'reflections',
      where: 'book = ? AND chapter = ?',
      whereArgs: [book, chapter],
    );
  }

  static Future<List<Map<String, dynamic>>> getAllReflections() async {
    final db = await database;
    return await db.query('reflections');
  }

  static Future<void> updateReflection(
    int id,
    String title,
    String description,
  ) async {
    final db = await database;
    await db.update(
      'reflections',
      {'title': title, 'description': description},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteReflection(int id) async {
    final db = await database;
    await db.delete('reflections', where: 'id = ?', whereArgs: [id]);
  }

  // ====== الملاحظات الصوتية ======
  static Future<int> addVoiceNote(
    String book,
    String chapter,
    int verseNumber,
    String filePath,
  ) async {
    final db = await database;
    return await db.insert('voice_notes', {
      'book': book,
      'chapter': chapter,
      'verse_number': verseNumber,
      'file_path': filePath,
    });
  }

  static Future<List<Map<String, dynamic>>> getVoiceNotes(
    String book,
    String chapter,
  ) async {
    final db = await database;
    return await db.query(
      'voice_notes',
      where: 'book = ? AND chapter = ?',
      whereArgs: [book, chapter],
    );
  }

  static Future<void> deleteVoiceNote(int id) async {
    final db = await database;
    await db.delete('voice_notes', where: 'id = ?', whereArgs: [id]);
  }

  // ====== آخر موضع قراءة ======
  static Future<void> saveLastPosition(Map<String, String> position) async {
    final db = await database;
    await db.delete('last_position');
    await db.insert('last_position', position);
  }

  static Future<Map<String, String>?> getLastPosition() async {
    final db = await database;
    final result = await db.query('last_position');
    if (result.isNotEmpty) {
      return {
        'book': result.first['book'] as String,
        'chapter': result.first['chapter'] as String,
        'verse': result.first['verse'] as String,
      };
    }
    return null;
  }

  // ====== مسح كل البيانات ======
  static Future<void> clearCache() async {
    final db = await database;
    await db.delete('cache');
    await db.delete('last_position');
    await db.delete('fav');
    await db.delete('highlighted_verses');
    await db.delete('reflections');
    await db.delete('voice_notes');
  }

  // إضافة تمييز للآية
  static Future<void> addHighlight(
    String book,
    String chapter,
    int verseNumber, {
    String color = "yellow",
  }) async {
    await highlightVerse(book, chapter, verseNumber, color);
  }

  // إزالة تمييز الآية
  static Future<void> removeHighlightVerse(
    String book,
    String chapter,
    int verseNumber,
  ) async {
    await removeHighlight(book, chapter, verseNumber);
  }

  static Future<void> resetDatabase() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bible_cache.db');
    if (await databaseExists(path)) {
      await deleteDatabase(path);
      print("Database deleted successfully.");
    }
    _db = null;
  }
}
