import 'package:arabic_holy_bible/shared/colors/app_colors.dart';
import 'package:arabic_holy_bible/shared/data/bible_loader.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _loading = false;

  Future<void> _startApp() async {
    setState(() {
      _loading = true;
    });

    await BibleLoader.loadBible();

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 32),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/icon/holyBible.png",
                  height: 150,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 30),
                Text(
                  "الكتاب المقدس",
                  style: GoogleFonts.cairo(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "مرحباً بك في تطبيق الكتاب المقدس\nنسخة عربية أوفلاين",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 40),
                _loading
                    ? CircularProgressIndicator(
                        backgroundColor: AppColors.background,
                        color: AppColors.primary,
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _startApp,
                        child: Text(
                          "ابدأ الآن",
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                /* IconButton(
                  onPressed: () async {
                    await DatabaseHelper.resetDatabase();
                  },
                  icon: Icon(Icons.refresh),
                ),*/
              ],
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                "Developed by Shino",
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppColors.textDark.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
