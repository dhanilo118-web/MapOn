import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_layout.dart';

class MapOn extends StatelessWidget {
  const MapOn({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MapOn',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212), // background-dark
        primaryColor: const Color(0xFFEA2A33), // primary
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFEA2A33),
          surface: Color(0xFF1E1E1E), // surface-dark
          onSurface: Color(0xFFE0E0E0),
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFF3C3C3C)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFF3C3C3C)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFFEA2A33), width: 2),
          ),
          hintStyle: const TextStyle(color: Color(0xFFA0A0A0)),
        ),
      ),
      home: const MainLayout(),
    );
  }
}
