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

    final String response = await rootBundle.loadString(
      'assets/data/bible.json',
    );
    final data = json.decode(response) as Map<String, dynamic>;
    _cache = data;
    _cacheNoDiacritics = {};

    for (var book in data.keys) {
      final chapters = data[book] as Map<String, dynamic>;
      final chaptersNoDiacritics = <String, Map<String, String>>{};

      searchIndex[book] = [];

      for (var chapterKey in chapters.keys) {
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

        // حفظ في DB كل إصحاح
        await DatabaseHelper.setChapter(book, chapterKey, json.encode(verses));
      }

      _cacheNoDiacritics![book] = chaptersNoDiacritics;
    }

    return _cache!;
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
