// data/models/feedback_model.dart
// FIX: replaced bare 'as int' casts with _toInt() — PyMySQL returns int columns
// as strings in some MySQL/MariaDB versions.
int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString());
}

class FeedbackModel {
  final int id;
  final int userId;
  final String subject;
  final String message;
  final String category;
  final int? rating;
  final String status;
  final DateTime createdAt;
  final String? userName;
  final String? userEmail;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.subject,
    required this.message,
    this.category = 'General',
    this.rating,
    this.status = 'pending',
    required this.createdAt,
    this.userName,
    this.userEmail,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id:        _toInt(json['id'])      ?? 0,
      userId:    _toInt(json['user_id']) ?? 0,
      subject:   json['subject']  as String? ?? '',
      message:   json['message']  as String? ?? '',
      category:  json['category'] as String? ?? 'General',
      rating:    _toInt(json['rating']),
      status:    json['status']   as String? ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      userName:  json['full_name'] as String?,
      userEmail: json['email']     as String?,
    );
  }

  String get ratingText => rating != null ? '⭐' * rating! : 'No rating';
  bool get isPending  => status == 'pending';
  bool get isReviewed => status == 'reviewed';
  bool get isResolved => status == 'resolved';
}
