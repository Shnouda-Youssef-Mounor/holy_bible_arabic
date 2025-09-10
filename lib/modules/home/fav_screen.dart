import 'package:arabic_holy_bible/shared/colors/app_colors.dart';
import 'package:arabic_holy_bible/shared/data/database_helper.dart';
import 'package:arabic_holy_bible/shared/widgets/share_verse_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FavScreen extends StatefulWidget {
  const FavScreen({super.key});

  @override
  State<FavScreen> createState() => _FavScreenState();
}

class _FavScreenState extends State<FavScreen> {
  List<Map<String, dynamic>> data = [];

  Future<void> getFavData() async {
    try {
      final fav = await DatabaseHelper.getFav();
      setState(() {
        data = fav;
      });
    } catch (e) {
      debugPrint("Error in get fav Data : $e");
    }
  }

  Future<void> removeFav(String book, String chapter, String verse) async {
    final db = await DatabaseHelper.database;
    await db.delete(
      'fav',
      where: 'book = ? AND chapter = ? AND verse = ?',
      whereArgs: [book, chapter, verse],
    );
    getFavData(); // تحديث القائمة بعد الحذف
  }

  @override
  void initState() {
    super.initState();
    getFavData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("المفضلة"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
      ),
      body: data.isEmpty
          ? Center(
              child: Text(
                "لا توجد آيات محفوظة",
                style: TextStyle(fontSize: 18, color: AppColors.textDark),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final fav = data[index];
                return Card(
                  elevation: 6,
                  shadowColor: AppColors.accent.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          AppColors.accent.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // العنوان (الكتاب + الإصحاح)
                        Row(
                          children: [
                            const Icon(
                              Icons.menu_book,
                              color: AppColors.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "${fav['book']} - الإصحاح ${fav['chapter']}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // نص الآية
                        Text(
                          fav['verse'],
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // الأزرار (نسخ + حذف)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Tooltip(
                              message: "نسخ الآية",
                              child: IconButton(
                                icon: const Icon(
                                  Icons.copy,
                                  color: AppColors.primary,
                                ),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: fav['verse']),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("تم نسخ الآية"),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Tooltip(
                              message: "مشاركة الآية",
                              child: IconButton(
                                icon: const Icon(
                                  Icons.share,
                                  color: AppColors.primary,
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    ModalBottomSheetRoute(
                                      builder: (context) => ShareVerseWidget(
                                        book: fav['book'] ?? "",
                                        chapter: fav['chapter'] ?? "",
                                        verse: fav['verse']
                                            .toString()
                                            .split('.')
                                            .first
                                            .trim(),
                                        verseText: fav['verse'] ?? "",
                                      ),
                                      isScrollControlled: false,
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("تم نسخ الآية"),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Tooltip(
                              message: "إزالة من المفضلة",
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  await removeFav(
                                    fav['book'],
                                    fav['chapter'],
                                    fav['verse'],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
