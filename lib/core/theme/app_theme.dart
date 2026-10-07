import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      scaffoldBackgroundColor: const Color(0xFF1C382B),
      textTheme: GoogleFonts.tajawalTextTheme(),
    );
  }
}
