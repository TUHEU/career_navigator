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
      id: json['id'] as int,
      userId: json['user_id'] as int,
      subject: json['subject'] as String? ?? '',
      message: json['message'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      rating: json['rating'] as int?,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      userName: json['full_name'] as String?,
      userEmail: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'subject': subject,
      'message': message,
      'category': category,
      'rating': rating,
      'status': status,
    };
  }

  String get ratingText {
    if (rating == null) return 'No rating';
    return '⭐' * rating!;
  }

  bool get isPending => status == 'pending';
  bool get isReviewed => status == 'reviewed';
  bool get isResolved => status == 'resolved';
}
