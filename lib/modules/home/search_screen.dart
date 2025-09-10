import 'package:flutter/material.dart';

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
    setState(() => isLoading = true);

    final res = await BibleLoader.search(query);

    setState(() {
      results = res;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("بحث في الكتاب المقدس"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.primary.withOpacity(0.05),
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: _search,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.textLight,
                hintText: "اكتب نص البحث هنا...",
                prefixIcon: const Icon(Icons.search, color: AppColors.accent),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.accent.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.accent.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.accent,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          if (isLoading) const LinearProgressIndicator(color: AppColors.accent),
          Expanded(
            child: results.isEmpty
                ? const Center(
                    child: Text(
                      "ابدأ البحث لعرض النتائج",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      final verseNumber =
                          int.tryParse(
                            item['verse']!.replaceAll(RegExp(r'^0+'), ''),
                          ) ??
                          0;

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 1,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.white,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
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
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['text'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "سفر ${item['book']}، الإصحاح ${item['chapter']}، الآية $verseNumber",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.secondary.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
