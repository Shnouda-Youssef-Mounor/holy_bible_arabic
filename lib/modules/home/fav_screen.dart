import 'package:arabic_holy_bible/shared/colors/app_colors.dart';
import 'package:arabic_holy_bible/shared/data/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  color: AppColors.textDark,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final fav = data[index];
                return Card(
                  elevation: 4,
                  shadowColor: AppColors.accent.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // عنوان الكتاب والإصحاح
                        Text(
                          "${fav['book']} - الإصحاح ${fav['chapter']}",
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // نص الآية
                        Text(
                          fav['verse'],
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // زر نسخ النص
                            IconButton(
                              icon: const Icon(
                                Icons.copy,
                                color: AppColors.primary,
                              ),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: fav['verse']),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("تم نسخ الآية")),
                                );
                              },
                            ),
                            // زر الحذف من المفضلة
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await removeFav(
                                  fav['book'],
                                  fav['chapter'],
                                  fav['verse'],
                                );
                              },
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
