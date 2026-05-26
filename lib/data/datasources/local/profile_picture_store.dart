// data/datasources/local/profile_picture_store.dart
// Stores profile picture locally as base64 in SharedPreferences.
// This is the FIX for "profile picture disappears after registration".
// Priority: local storage → Cloudinary URL → initials fallback

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePictureStore {
  static const _key = 'local_profile_picture_v2';

  /// Save a File locally
  static Future<void> saveFile(File file) async {
    final bytes  = await file.readAsBytes();
    final b64    = base64Encode(bytes);
    final prefs  = await SharedPreferences.getInstance();
    await prefs.setString(_key, b64);
  }

  /// Save raw bytes locally
  static Future<void> saveBytes(List<int> bytes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, base64Encode(bytes));
  }

  /// Get as ImageProvider (null if not saved)
  static Future<ImageProvider?> getLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final b64   = prefs.getString(_key);
    if (b64 == null || b64.isEmpty) return null;
    try {
      return MemoryImage(base64Decode(b64));
    } catch (_) { return null; }
  }

  /// Clear local picture
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// Smart avatar widget:
  /// 1. Shows local picture if saved
  /// 2. Falls back to remote Cloudinary URL
  /// 3. Falls back to initials
  static Widget avatar({
    required String? remoteUrl,
    required String? name,
    double radius       = 40,
    double fontSize     = 0,
    Color bgColor       = const Color(0xFF00B8D4),
  }) {
    final fSize = fontSize > 0 ? fontSize : radius * 0.5;
    return FutureBuilder<ImageProvider?>(
      future: getLocal(),
      builder: (_, snap) {
        ImageProvider? provider;
        if (snap.hasData && snap.data != null) {
          provider = snap.data;
        } else if (remoteUrl != null && remoteUrl.isNotEmpty &&
            (remoteUrl.startsWith('http'))) {
          provider = NetworkImage(remoteUrl);
        }

        if (provider != null) {
          return CircleAvatar(
            radius: radius,
            backgroundImage: provider,
            backgroundColor: bgColor.withOpacity(0.15),
            onBackgroundImageError: (_, __) {},
          );
        }

        // Initials fallback
        return CircleAvatar(
          radius: radius,
          backgroundColor: bgColor.withOpacity(0.18),
          child: Text(
            _initials(name),
            style: TextStyle(
              color: bgColor,
              fontSize: fSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  static String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
