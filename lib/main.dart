import 'dart:io';
import 'package:arabic_holy_bible/modules/home/home_screen.dart';
import 'package:arabic_holy_bible/modules/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Platform.isAndroid && !Platform.isIOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arabic Holy Bible',
      theme: ThemeData(fontFamily: 'Arial'),
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      locale: const Locale('ar', ''),
      supportedLocales: const [
        Locale('ar', ''), // Arabic
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routes: {
        "/": (context) => const WelcomeScreen(),
        "/home": (context) => const HomeScreen(),
      },
    );
  }
}
