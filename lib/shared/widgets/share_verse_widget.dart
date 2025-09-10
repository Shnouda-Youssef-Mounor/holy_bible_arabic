import 'dart:io';
import 'dart:ui';

import 'package:arabic_holy_bible/shared/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareVerseWidget extends StatefulWidget {
  final String verseText;
  final String chapter;
  final String book;
  final String verse;
  const ShareVerseWidget({
    super.key,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.verseText,
  });

  @override
  State<ShareVerseWidget> createState() => _ShareVerseWidgetState();
}

class _ShareVerseWidgetState extends State<ShareVerseWidget> {
  final GlobalKey _globalKey = GlobalKey();

  Future<void> _shareVerseAsImage() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/verse.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)], text: widget.verseText);
    } catch (e) {
      print("Error sharing verse image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RepaintBoundary(
          key: _globalKey,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.verseText,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: AppColors.background,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "(${widget.book} ${widget.chapter} - ${widget.verse})",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.background,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _shareVerseAsImage,
          icon: Icon(Icons.share, color: AppColors.background),
          label: Text(
            "مشاركة الآية كصورة",
            style: TextStyle(color: AppColors.background),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: TextStyle(
              fontSize: 18,
              color: AppColors.background,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
