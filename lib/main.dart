
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/language_provider.dart';
import 'screens/loading_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => LanguageProvider(),
      child: const ZEReader(),
    ),
  );
}

class ZEReader extends StatelessWidget {
  const ZEReader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          title: 'ZEreader',
          locale: languageProvider.locale,
          theme: ThemeData(
            scaffoldBackgroundColor: const Color(0xFFE0F7FA), // Light Cyan Background
            primaryColor: const Color(0xFF0077B6), // Ocean Blue
            colorScheme: ColorScheme.fromSwatch().copyWith(
              secondary: const Color(0xFF00B4D8), // Sky Blue
            ),
            textTheme: GoogleFonts.latoTextTheme(textTheme).copyWith(
              headlineMedium: GoogleFonts.lato(
                textStyle: const TextStyle(
                  color: Color(0xFF0077B6), // Ocean Blue
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              bodyMedium: GoogleFonts.lato(
                textStyle: const TextStyle(
                  color: Color(0xFF4F4F4F), // Dark Gray
                  fontSize: 16,
                ),
              ),
              titleLarge: GoogleFonts.lato(
                textStyle: const TextStyle(
                  color: Color(0xFF0077B6), // Ocean Blue
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFE0F7FA), // Light Cyan Background
              elevation: 0,
              iconTheme: IconThemeData(color: Color(0xFF0077B6)), // Ocean Blue
              titleTextStyle: TextStyle(
                color: Color(0xFF0077B6), // Ocean Blue
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
          ),
          home: const LoadingScreen(),
        );
      },
    );
  }
}
