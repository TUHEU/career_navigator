class QuestionnaireModel {
  final String userId;
  final String educationLevel;
  final String fieldOfStudy;
  final String graduationYear;
  final List<String> careerInterests;
  final List<String> skills;
  final String jobType;
  final String workMode;
  final String preferredLocation;
  final DateTime submittedAt;

  QuestionnaireModel({
    required this.userId,
    required this.educationLevel,
    required this.fieldOfStudy,
    required this.graduationYear,
    required this.careerInterests,
    required this.skills,
    required this.jobType,
    required this.workMode,
    required this.preferredLocation,
    required this.submittedAt,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'education_level': educationLevel,
    'field_of_study': fieldOfStudy,
    'graduation_year': graduationYear,
    'career_interests': careerInterests,
    'skills': skills,
    'job_type': jobType,
    'work_mode': workMode,
    'preferred_location': preferredLocation,
    'submitted_at': submittedAt.toIso8601String(),
  };

  factory QuestionnaireModel.fromJson(Map<String, dynamic> json) =>
      QuestionnaireModel(
        userId: json['user_id'],
        educationLevel: json['education_level'],
        fieldOfStudy: json['field_of_study'],
        graduationYear: json['graduation_year'],
        careerInterests: List<String>.from(json['career_interests']),
        skills: List<String>.from(json['skills']),
        jobType: json['job_type'],
        workMode: json['work_mode'],
        preferredLocation: json['preferred_location'],
        submittedAt: DateTime.parse(json['submitted_at']),
      );
}
