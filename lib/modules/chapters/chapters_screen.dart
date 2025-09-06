import 'package:arabic_holy_bible/shared/colors/app_colors.dart';
import 'package:arabic_holy_bible/shared/data/bible_loader.dart';
import 'package:arabic_holy_bible/shared/data/database_helper.dart';
import 'package:arabic_holy_bible/shared/widgets/share_verse_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ChaptersScreen extends StatefulWidget {
  final String title;
  final Function callBack;
  final String selectedChapter;

  const ChaptersScreen({
    super.key,
    required this.callBack,
    required this.title,
    required this.selectedChapter,
  });

  @override
  State<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  String? selectedChapter;
  Map<String, dynamic> data = {};
  List<String> getChapters = [];
  final ScrollController _scrollController = ScrollController();
  Map<String, String> highlighted = {}; // book_chapter_verse -> color
  List<Map<String, dynamic>> reflections = []; // قائمة التأملات للفصل الحالي

  double verseFontSize = 16;
  double lineHeight = 1.6;

  Future<void> loadHighlightedVerses() async {
    if (selectedChapter == null) return;
    final results = await DatabaseHelper.getHighlightedVerses(
      widget.title,
      selectedChapter!,
    );

    setState(() {
      highlighted = {
        for (var row in results)
          "${widget.title}_${selectedChapter}_${row['verse_number']}":
              row['color'].toString(),
      };
    });
  }

  Future<void> loadReflections() async {
    if (selectedChapter == null) return;
    final results = await DatabaseHelper.getReflections(
      widget.title,
      selectedChapter!,
    );
    setState(() {
      reflections = results;
    });
  }

  Future<void> getData() async {
    try {
      if (widget.title == "المزامير") {
        if (selectedChapter == "1" || selectedChapter == "01") {
          selectedChapter = "001";
        }
      } else {
        if (selectedChapter == "1") {
          selectedChapter = "01";
        }
      }
      setState(() {});
      await loadHighlightedVerses();
      await loadReflections();
    } catch (e) {
      debugPrint("Error get chapter data : $e");
    }
  }

  Future<void> loadData() async {
    try {
      final chapterData = await BibleLoader.getChapters(widget.title);
      final chaptersResult = chapterData != null
          ? (chapterData.keys.toList()
              ..sort((a, b) => int.parse(a).compareTo(int.parse(b))))
          : <String>[];

      setState(() {
        getChapters = chaptersResult;
        data = chapterData ?? {};
        selectedChapter = widget.selectedChapter;
      });
      await getData();
    } catch (e) {
      setState(() {
        getChapters = [];
        data = {};
      });
      debugPrint("Error loading chapters: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Color _colorFromString(String color) {
    switch (color) {
      case 'yellow':
        return Colors.yellow.shade200;
      case 'red':
        return Colors.red.shade200;
      case 'green':
        return Colors.green.shade200;
      default:
        return AppColors.textLight;
    }
  }

  Future<void> addReflection(
    String verseNumbers,
    String title,
    String description,
  ) async {
    if (selectedChapter == null) return;
    await DatabaseHelper.addReflection(
      widget.title,
      selectedChapter!,
      verseNumbers,
      title,
      description,
    );
    await loadReflections();
  }

  Future<void> deleteReflection(int id) async {
    await DatabaseHelper.deleteReflection(id);
    await loadReflections();
  }

  @override
  Widget build(BuildContext context) {
    final chapterData = selectedChapter != null
        ? data[selectedChapter] as Map<String, dynamic>?
        : null;
    final verses = chapterData != null
        ? chapterData.entries
              .toList()
              .asMap()
              .entries
              .where((entry) => entry.key >= 2)
              .toList()
        : [];

    return WillPopScope(
      onWillPop: () async {
        widget.callBack();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.background,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              widget.callBack();
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            SizedBox(
              height: 50,
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: getChapters.map((element) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ChoiceChip(
                          label: Text(
                            element,
                            style: GoogleFonts.cairo(
                              color: selectedChapter == element
                                  ? AppColors.textLight
                                  : AppColors.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: selectedChapter == element,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.textLight,
                          checkmarkColor: AppColors.background,
                          onSelected: (_) async {
                            await BibleLoader.saveLastPosition(
                              book: widget.title,
                              chapter: element.toString(),
                              verse: "1",
                            );
                            setState(() {
                              selectedChapter = element;
                            });
                            await getData();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            if (selectedChapter != null) ...[
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: verses.length + reflections.length,
                  itemBuilder: (context, index) {
                    // أول نعرض الآيات
                    if (index < verses.length) {
                      final entry = verses[index];
                      final verseNumber = entry.key - 1;
                      final verseText = "$verseNumber. ${entry.value.value}";
                      final verseKey =
                          "${widget.title}_${selectedChapter}_$verseNumber";

                      Color verseBgColor = highlighted.containsKey(verseKey)
                          ? _colorFromString(highlighted[verseKey]!)
                          : AppColors.textLight;
                      final isHighlighted = highlighted.containsKey(verseKey);

                      return GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            backgroundColor: AppColors.textLight,
                            builder: (context) {
                              return SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 5,
                                        margin: const EdgeInsets.only(
                                          bottom: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(
                                            0.3,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        leading: Icon(
                                          Icons.save,
                                          color: AppColors.primary,
                                        ),
                                        title: Text(
                                          "احفظ تقدمي",
                                          style: GoogleFonts.cairo(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        onTap: () async {
                                          final match = RegExp(
                                            r'^(\d+)\.',
                                          ).firstMatch(verseText);
                                          if (match != null) {
                                            String number = match.group(1)!;
                                            await BibleLoader.saveLastPosition(
                                              book: widget.title,
                                              chapter: selectedChapter ?? "01",
                                              verse: number,
                                            );
                                          }
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text("تم حفظ التقدم"),
                                            ),
                                          );
                                        },
                                      ),
                                      Divider(
                                        color: AppColors.accent.withOpacity(
                                          0.3,
                                        ),
                                      ),
                                      ListTile(
                                        leading: Icon(
                                          Icons.copy,
                                          color: AppColors.primary,
                                        ),
                                        title: Text(
                                          "نسخ الآية",
                                          style: GoogleFonts.cairo(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        onTap: () {
                                          Clipboard.setData(
                                            ClipboardData(text: verseText),
                                          );
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text("تم نسخ الآية"),
                                            ),
                                          );
                                        },
                                      ),
                                      Divider(
                                        color: AppColors.accent.withOpacity(
                                          0.3,
                                        ),
                                      ),
                                      ListTile(
                                        leading: Icon(
                                          Icons.favorite,
                                          color: AppColors.primary,
                                        ),
                                        title: Text(
                                          "إضافة للمفضلة",
                                          style: GoogleFonts.cairo(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        onTap: () async {
                                          await DatabaseHelper.setFav(
                                            widget.title,
                                            selectedChapter!,
                                            verseText,
                                          );
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "تمت إضافة الآية للمفضلة",
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      Divider(
                                        color: AppColors.accent.withOpacity(
                                          0.3,
                                        ),
                                      ),
                                      ListTile(
                                        leading: Icon(
                                          isHighlighted
                                              ? Icons.highlight_remove
                                              : Icons.highlight,
                                          color: AppColors.primary,
                                        ),
                                        title: Text(
                                          isHighlighted
                                              ? "إزالة التمييز"
                                              : "تمييز الآية",
                                          style: GoogleFonts.cairo(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        onTap: () async {
                                          if (isHighlighted) {
                                            await DatabaseHelper.removeHighlight(
                                              widget.title,
                                              selectedChapter!,
                                              verseNumber,
                                            );
                                            highlighted.remove(verseKey);
                                          } else {
                                            await DatabaseHelper.highlightVerse(
                                              widget.title,
                                              selectedChapter!,
                                              verseNumber,
                                              'yellow',
                                            );
                                            highlighted[verseKey] = 'yellow';
                                          }
                                          setState(() {});
                                          Navigator.pop(context);
                                        },
                                      ),
                                      Divider(
                                        color: AppColors.accent.withOpacity(
                                          0.3,
                                        ),
                                      ),
                                      ListTile(
                                        leading: Icon(
                                          Icons.share,
                                          color: AppColors.primary,
                                        ),
                                        title: Text(
                                          "مشاركة الآية",
                                          style: GoogleFonts.cairo(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.of(context).push(
                                            ModalBottomSheetRoute(
                                              builder: (context) =>
                                                  ShareVerseWidget(
                                                    book: widget.title,
                                                    chapter:
                                                        selectedChapter ?? "1",
                                                    verse: verseNumber
                                                        .toString(),
                                                    verseText: verseText,
                                                  ),
                                              isScrollControlled: false,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: verseBgColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withOpacity(0.2),
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            verseText,
                            style: GoogleFonts.tajawal(
                              fontSize: verseFontSize,
                              height: lineHeight,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      );
                    } else {
                      final reflection = reflections[index - verses.length];
                      return Card(
                        color: AppColors.textLight,
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
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
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        deleteReflection(reflection['id']),
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
                              const SizedBox(height: 8),
                              Text("الاعداد ${reflection['verse_numbers']}"),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
            const SizedBox(height: 80),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          child: const Icon(Icons.add),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                final titleController = TextEditingController();
                final descController = TextEditingController();
                final verseController = TextEditingController();
                return AlertDialog(
                  backgroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    "إضافة تأمل",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        TextField(
                          controller: verseController,
                          decoration: InputDecoration(
                            labelText:
                                "رقم الآية أو مجموعة الآيات (مثلاً 1 أو 1-3)",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: "العنوان",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: descController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: "الوصف",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actionsAlignment: MainAxisAlignment.spaceEvenly,
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("إلغاء"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        addReflection(
                          verseController.text,
                          titleController.text,
                          descController.text,
                        );
                        Navigator.pop(context);
                      },
                      child: const Text("حفظ"),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
