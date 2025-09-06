import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../shared/colors/app_colors.dart';
import '../../shared/data/bible_loader.dart';
import '../chapters/chapters_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> results = [];
  bool isLoading = false;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      isLoading = true;
    });

    final res = await BibleLoader.search(query);

    setState(() {
      results = res;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("بحث في الكتاب المقدس", style: GoogleFonts.cairo()),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: _search,
              decoration: InputDecoration(
                hintText: "اكتب نص البحث هنا...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          if (isLoading) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final item = results[index];
                final verseNumber =
                    int.tryParse(
                      item['verse']!.replaceAll(RegExp(r'^0+'), ''),
                    ) ??
                    0;
                final displayVerse = (verseNumber - 2)
                    .clamp(0, double.infinity)
                    .toInt();

                return ListTile(
                  title: Text(item['text']!, style: GoogleFonts.cairo()),
                  subtitle: Text(
                    "سفر ${item['book']}، الإصحاح ${item['chapter']}, الآية $displayVerse",
                    style: GoogleFonts.cairo(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChaptersScreen(
                          title: item['book']!,
                          selectedChapter: item['chapter']!,
                          callBack: () {},
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
