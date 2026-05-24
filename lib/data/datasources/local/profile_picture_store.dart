// data/datasources/local/profile_picture_store.dart
// Stores profile picture locally using shared_preferences (base64).
// Fallback when Cloudinary upload fails or image URL is unreachable.
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePictureStore {
  static const String _key = 'local_profile_picture';

  /// Save image file as base64 locally
  static Future<void> save(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64 = base64Encode(bytes);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, base64);
  }

  /// Save raw bytes locally
  static Future<void> saveBytes(List<int> bytes) async {
    final base64 = base64Encode(bytes);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, base64);
  }

  /// Get local picture as ImageProvider (null if none saved)
  static Future<ImageProvider?> get() async {
    final prefs = await SharedPreferences.getInstance();
    final base64 = prefs.getString(_key);
    if (base64 == null || base64.isEmpty) return null;
    try {
      return MemoryImage(base64Decode(base64));
    } catch (_) {
      return null;
    }
  }

  /// Get as base64 string
  static Future<String?> getBase64() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  /// Clear local picture
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// Widget that shows local picture, falls back to URL, then initials
  static Widget avatar({
    required String? remoteUrl,
    required String? name,
    double radius = 40,
    Color backgroundColor = const Color(0xFF00B8D4),
  }) {
    return FutureBuilder<ImageProvider?>(
      future: get(),
      builder: (context, snap) {
        ImageProvider? provider;

        // Priority: local > remote URL
        if (snap.hasData && snap.data != null) {
          provider = snap.data;
        } else if (remoteUrl != null && remoteUrl.isNotEmpty) {
          provider = NetworkImage(remoteUrl);
        }

        if (provider != null) {
          return CircleAvatar(
            radius: radius,
            backgroundImage: provider,
            backgroundColor: backgroundColor,
          );
        }

        // Fallback: initials
        final initials = _initials(name);
        return CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor.withValues(alpha: 0.2),
          child: Text(
            initials,
            style: TextStyle(
              color: backgroundColor,
              fontSize: radius * 0.6,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  static String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
