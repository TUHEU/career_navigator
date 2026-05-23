// PyMySQL can return numeric columns as String — this helper handles both.
int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString());
}

class MentorModel {
  final int id;
  final String fullName;
  final String? profilePictureUrl;
  final String? headline;
  final String? currentJobTitle;
  final String? currentCompany;
  final List<String> expertiseAreas;
  final double? sessionPrice;
  final double? rating;
  final int totalSessions;
  final bool isAcceptingMentees;

  MentorModel({
    required this.id,
    required this.fullName,
    this.profilePictureUrl,
    this.headline,
    this.currentJobTitle,
    this.currentCompany,
    this.expertiseAreas = const [],
    this.sessionPrice,
    this.rating,
    this.totalSessions = 0,
    this.isAcceptingMentees = true,
  });

  factory MentorModel.fromJson(Map<String, dynamic> json) {
    List<String> expertise = [];
    final raw = json['expertise_areas'];
    if (raw is List) {
      expertise = List<String>.from(raw);
    } else if (raw is String && raw.isNotEmpty) {
      expertise = [raw];
    }

    return MentorModel(
      id: _toInt(json['id']) ?? 0,
      fullName: json['full_name'] as String? ?? 'Unknown',
      profilePictureUrl: json['profile_picture_url'] as String?,
      headline: json['headline'] as String?,
      currentJobTitle: json['current_job_title'] as String?,
      currentCompany: json['current_company'] as String?,
      expertiseAreas: expertise,
      sessionPrice: json['session_price'] != null
          ? double.tryParse(json['session_price'].toString())
          : null,
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      totalSessions: _toInt(json['total_sessions']) ?? 0,
      isAcceptingMentees:
          json['is_accepting_mentees'] == 1 ||
          json['is_accepting_mentees'] == true,
    );
  }

  String get initials {
    if (fullName.isEmpty) return '?';
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName[0].toUpperCase();
  }

  String get sessionPriceText {
    if (sessionPrice == null || sessionPrice == 0) return 'Free';
    return '\$${sessionPrice!.toStringAsFixed(0)}/session';
  }

  String get ratingText {
    if (rating == null) return 'No rating';
    return rating!.toStringAsFixed(1);
  }
}
