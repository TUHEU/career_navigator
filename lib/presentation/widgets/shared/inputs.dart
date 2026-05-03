import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final int maxLines;
  final bool enabled;
  final bool isDark;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.icon,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      enabled: enabled,
      style: TextStyle(color: isDark ? Colors.white : Colors.grey.shade800),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primaryCyan),
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white.withOpacity(0.6) : Colors.grey.shade600,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.15)
                : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primaryCyan),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;
  final VoidCallback? onClear;
  final bool isDark;

  const SearchField({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.onClear,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(color: isDark ? Colors.white : Colors.grey.shade800),
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: 'Search...',
        hintStyle: TextStyle(
          color: isDark ? Colors.white.withOpacity(0.35) : Colors.grey.shade500,
        ),
        prefixIcon: const Icon(Icons.search, color: AppColors.primaryCyan),
        suffixIcon: controller.text.isNotEmpty && onClear != null
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: isDark
                      ? Colors.white.withOpacity(0.5)
                      : Colors.grey.shade500,
                ),
                onPressed: onClear,
              )
            : null,
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryCyan),
        ),
      ),
    );
  }
}
