import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color darkBackground = Color(0xFF0A192F);
}

InputDecoration buildInputDecoration({
  required IconData icon,
  required String label,
  Widget? suffix,
  Color primaryCyan = const Color(0xFF00E5FF),
}) =>
    InputDecoration(
      prefixIcon: Icon(icon, color: primaryCyan),
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primaryCyan),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      suffixIcon: suffix,
    );
