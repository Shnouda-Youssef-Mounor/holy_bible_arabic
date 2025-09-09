import 'dart:convert';
import 'package:flutter/services.dart';
import 'database_helper.dart';

class BibleLoader {
  static Map<String, dynamic>? _cache;
  static Map<String, dynamic>? _cacheNoDiacritics;
  static final Map<String, List<Map<String, String>>> searchIndex = {};

  static String removeDiacritics(String text) {
    final pattern = RegExp(r'[\u064B-\u0652]');
    return text.replaceAll(pattern, '');
  }

  static Future<Map<String, dynamic>> loadBible() async {
    if (_cache != null) return _cache!;

    try {
      print("📖 Start loading bible.json");
      final String response = await rootBundle.loadString(
        'assets/data/bible.json',
      );
      print("✅ bible.json loaded (${response.length} chars)");

      Map<String, dynamic> data;
      try {
        data = json.decode(response) as Map<String, dynamic>;
        print("✅ JSON decoded with ${data.keys.length} books");
      } catch (e, st) {
        print("❌ JSON decode error: $e");
        print(st);
        rethrow;
      }

      _cache = data;
      _cacheNoDiacritics = {};

      for (var book in data.keys) {
        try {
          final chapters = data[book] as Map<String, dynamic>;
          final chaptersNoDiacritics = <String, Map<String, String>>{};
          searchIndex[book] = [];

          // لتجميع الإصحاحات في batch
          final Map<String, String> chaptersForDb = {};

          for (var chapterKey in chapters.keys) {
            try {
              final verses = chapters[chapterKey] as Map<String, dynamic>;
              final versesNoDiacritics = <String, String>{};

              verses.forEach((verseNum, verseText) {
                final text = verseText.toString();
                versesNoDiacritics[verseNum] = removeDiacritics(text);

                // إضافة للبحث
                searchIndex[book]!.add({
                  'chapter': chapterKey,
                  'verse': verseNum,
                  'text': removeDiacritics(text),
                });
              });

              chaptersNoDiacritics[chapterKey] = versesNoDiacritics;

              // جهّز الكتاب كله عشان يتكتب مرة واحدة
              chaptersForDb[chapterKey] = json.encode(verses);
            } catch (e, st) {
              print("❌ Error processing chapter $chapterKey in $book: $e");
              print(st);
            }
          }

          // ✅ كتابة كل الإصحاحات دفعة واحدة بالـ batch
          try {
            await DatabaseHelper.setBookChaptersBatch(book, chaptersForDb);
          } catch (e, st) {
            print("❌ DB batch insert error in $book: $e");
            print(st);
          }

          _cacheNoDiacritics![book] = chaptersNoDiacritics;
          print("✅ Finished book $book with ${chapters.keys.length} chapters");
        } catch (e, st) {
          print("❌ Error processing book $book: $e");
          print(st);
        }
      }

      print("🎉 Finished loadBible()");
      return _cache!;
    } catch (e, st) {
      print("❌ Fatal error in loadBible: $e");
      print(st);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getChapters(String book) async {
    await loadBible();
    final chaptersMap = <String, dynamic>{};
    final chaptersKeys = (_cache![book] as Map<String, dynamic>).keys;
    for (var key in chaptersKeys) {
      final chapterJson = await DatabaseHelper.getChapter(book, key);
      if (chapterJson != null) {
        chaptersMap[key] = json.decode(chapterJson);
      }
    }
    return chaptersMap;
  }

  static Future<List<String>> getBooks() async {
    final bible = await loadBible();
    return bible.keys.toList().cast<String>();
  }

  static Future<void> saveLastPosition({
    required String book,
    required String chapter,
    required String verse,
  }) async {
    await DatabaseHelper.saveLastPosition({
      'book': book,
      'chapter': chapter,
      'verse': verse,
    });
  }

  static Future<Map<String, String>?> getLastPosition() async {
    return await DatabaseHelper.getLastPosition();
  }

  static Future<void> clearCache() async {
    _cache = null;
    _cacheNoDiacritics = null;
    searchIndex.clear();
    await DatabaseHelper.clearCache();
  }

  static Future<List<Map<String, String>>> search(String query) async {
    final q = removeDiacritics(query);
    final List<Map<String, String>> results = [];

    for (var book in searchIndex.keys) {
      for (var verse in searchIndex[book]!) {
        if (verse['text']!.contains(q)) {
          results.add({
            'book': book,
            'chapter': verse['chapter']!,
            'verse': verse['verse']!,
            'text': verse['text']!,
          });
        }
      }
    }
    return results;
  }
}
