import 'package:arabic_holy_bible/shared/colors/app_colors.dart';
import 'package:arabic_holy_bible/shared/data/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReflectionsScreen extends StatefulWidget {
  const ReflectionsScreen({super.key});

  @override
  State<ReflectionsScreen> createState() => _ReflectionsScreenState();
}

class _ReflectionsScreenState extends State<ReflectionsScreen> {
  List<Map<String, dynamic>> data = [];

  Future<void> getReflections() async {
    final refData = await DatabaseHelper.getAllReflections();
    setState(() {
      data = refData;
    });
  }

  @override
  void initState() {
    super.initState();
    getReflections();
  }

  Future<void> deleteReflection(int id) async {
    await DatabaseHelper.deleteReflection(id);
    await getReflections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "التأملات",
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        foregroundColor: AppColors.background,
        backgroundColor: AppColors.primary,
        elevation: 2,
      ),
      backgroundColor: AppColors.background,
      body: data.isEmpty
          ? Center(
              child: Text(
                "لا توجد تأملات بعد",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  color: AppColors.textDark.withOpacity(0.7),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final reflection = data[index];
                return Card(
                  color: AppColors.textLight,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  shadowColor: AppColors.accent.withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                reflection['title'] ?? '',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  deleteReflection(reflection['id']),
                              tooltip: "حذف التأمل",
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          reflection['description'] ?? '',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            height: 1.5,
                            color: AppColors.textDark.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "سفر ${reflection['book']} | الإصحاح ${reflection['chapter']} | آيات ${reflection['verse_numbers']}",
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: AppColors.textDark.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
