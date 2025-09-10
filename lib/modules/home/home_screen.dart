import 'package:arabic_holy_bible/modules/chapters/chapters_screen.dart';
import 'package:arabic_holy_bible/modules/home/fav_screen.dart';
import 'package:arabic_holy_bible/modules/home/reflections_screen.dart';
import 'package:arabic_holy_bible/modules/home/search_screen.dart';
import 'package:arabic_holy_bible/shared/colors/app_colors.dart';
import 'package:flutter/material.dart';

import '../../shared/data/bible_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<String> books = [
    // العهد القديم
    "التكوين",
    "الخروج",
    "اللاويين",
    "العدد",
    "التثنية",
    "يشوع",
    "القضاة",
    "راعوث",
    "صموئيل الأول",
    "صموئيل الثاني",
    "الملوك الأول",
    "الملوك الثاني",
    "أخبار الأيام الأول",
    "أخبار الأيام الثاني",
    "عزرا",
    "نحميا",
    "أستير",
    "أيوب",
    "المزامير",
    "الأمثال",
    "الجامعة",
    "نشيد الأنشاد",
    "إشعياء",
    "إرميا",
    "مراثي إرميا",
    "حزقيال",
    "دانيال",
    "هوشع",
    "يوئيل",
    "عاموس",
    "عوبديا",
    "يونان",
    "ميخا",
    "ناحوم",
    "حبقوق",
    "صفنيا",
    "حجي",
    "زكريا",
    "ملاخي",

    // العهد الجديد
    "متى",
    "مرقس",
    "لوقا",
    "يوحنا",
    "أعمال الرسل",
    "رومية",
    "كورنثوس الأولى",
    "كورنثوس الثانية",
    "غلاطية",
    "أفسس",
    "فيلبي",
    "كولوسي",
    "تسالونيكي الأولى",
    "تسالونيكي الثانية",
    "تيموثاوس الأولى",
    "تيموثاوس الثانية",
    "تيطس",
    "فليمون",
    "العبرانيين",
    "يعقوب",
    "بطرس الأولى",
    "بطرس الثانية",
    "يوحنا الأولى",
    "يوحنا الثانية",
    "يوحنا الثالثة",
    "يهوذا",
    "الرؤيا",
  ];

  String? lastRead;
  Map<String, dynamic>? lastReadData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final position = await BibleLoader.getLastPosition();

    setState(() {
      if (position != null) {
        lastReadData = {
          "book": position['book'] ?? "التكوين",
          "chapter": position['chapter'] ?? "01",
          "verse": position["verse"] ?? "1",
        };
        final book = position['book'] ?? '';
        final chapter = position['chapter'] ?? '';
        final verse = position['verse'] ?? '';
        lastRead =
            "متابعة القراءة في سفر $book الإصحاح $chapter الآية رقم $verse";
      } else {
        lastRead = null;
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          "الكتاب المقدس",
          style: TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textLight),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (lastRead != null)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChaptersScreen(
                              selectedChapter: lastReadData?['chapter'] ?? "01",
                              title: lastReadData?['book'] ?? "التكوين",
                              callBack: () => _loadData(),
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        shadowColor: AppColors.accent.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: AppColors.secondary,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.history,
                                color: AppColors.textLight,
                                size: 26,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  lastRead ?? "",
                                  style: const TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_back_ios,
                                color: AppColors.textLight,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1.5,
                          color: AppColors.primary.withOpacity(0.4),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "الأسفار",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1.5,
                          color: AppColors.primary.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      itemCount: books.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 3 / 2,
                            mainAxisExtent: 120,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () async {
                            await BibleLoader.saveLastPosition(
                              book: books[index],
                              chapter: "1",
                              verse: "1",
                            );
                            _loadData();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ChaptersScreen(
                                  selectedChapter: "01",
                                  title: books[index],
                                  callBack: () => _loadData(),
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 2,
                            shadowColor: AppColors.accent.withOpacity(0.2),
                            color: AppColors.textLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                books[index],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.primary,
        selectedItemColor: AppColors.textLight,
        unselectedItemColor: AppColors.textLight.withOpacity(0.6),
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/icon/holyBible.png",
              height: 20,
              color: AppColors.background,
            ),
            label: "الأسفار",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "بحث"),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: "التأملات",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "المفضلة"),
        ],
        onTap: (index) {
          if (index == currentIndex) return;

          setState(() {
            currentIndex = index;
          });

          Widget page;
          switch (index) {
            case 0:
              page = const HomeScreen();
              break;
            case 1:
              page = const SearchScreen();
              break;
            case 2:
              page = const ReflectionsScreen();
              break;
            case 3:
              page = const FavScreen();
              break;
            default:
              return;
          }

          Navigator.push(context, MaterialPageRoute(builder: (_) => page)).then(
            (_) {
              // عند العودة للصفحة الرئيسية
              setState(() {
                currentIndex = 0;
              });
            },
          );
        },
      ),
    );
  }
}
