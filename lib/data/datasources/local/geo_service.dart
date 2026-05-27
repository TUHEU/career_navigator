// data/datasources/local/geo_service.dart
// Auto-detects user city via IP geolocation — no GPS plugin needed.
// Uses free ip-api.com (no API key required).
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GeoService {
  GeoService._();
  static final GeoService instance = GeoService._();

  /// Returns "City, Country" string, or null if failed.
  Future<String?> getCurrentCity() async {
    try {
      final res = await http.get(
        Uri.parse('http://ip-api.com/json/?fields=city,country,lat,lon'),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final data    = jsonDecode(res.body) as Map<String, dynamic>;
        final city    = data['city']    as String?;
        final country = data['country'] as String?;
        if (city != null) {
          return country != null ? '$city, $country' : city;
        }
      }
    } catch (_) {}
    return null;
  }

  static void showDetected(BuildContext context, String city) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.my_location, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Text('Location detected: $city'),
      ]),
      backgroundColor: const Color(0xFF00B8D4),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}
