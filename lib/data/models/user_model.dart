class User {
  final int id;
  final String email;
  final String? fullName;
  final String? profilePictureUrl;
  final String role;
  final bool isVerified;
  final String? phone;
  final String? location;
  final String? headline;
  final String? bio;
  final String? currentJobTitle;
  final String? desiredJobTitle;
  final int? yearsOfExperience;
  final String? availability;
  final List<Education> education;
  final List<WorkExperience> workExperience;

  // Mentor specific
  final String? currentCompany;
  final List<String>? expertiseAreas;
  final double? sessionPrice;
  final bool isAcceptingMentees;
  final double? rating;
  final int? totalSessions;

  User({
    required this.id,
    required this.email,
    this.fullName,
    this.profilePictureUrl,
    required this.role,
    required this.isVerified,
    this.phone,
    this.location,
    this.headline,
    this.bio,
    this.currentJobTitle,
    this.desiredJobTitle,
    this.yearsOfExperience,
    this.availability,
    this.education = const [],
    this.workExperience = const [],
    this.currentCompany,
    this.expertiseAreas,
    this.sessionPrice,
    this.isAcceptingMentees = true,
    this.rating,
    this.totalSessions,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final mentorProfile = json['mentor_profile'] as Map<String, dynamic>? ?? {};

    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      role: json['role'] as String? ?? 'job_seeker',
      isVerified: json['is_verified'] == 1,
      phone: json['phone'] as String? ?? mentorProfile['phone'],
      location: json['location'] as String? ?? mentorProfile['location'],
      headline: json['headline'] as String? ?? mentorProfile['headline'],
      bio: json['bio'] as String? ?? mentorProfile['bio'],
      currentJobTitle:
          json['current_job_title'] as String? ??
          mentorProfile['current_job_title'],
      desiredJobTitle: json['desired_job_title'] as String?,
      yearsOfExperience:
          (json['years_of_experience'] ?? mentorProfile['years_of_experience'])
              as int?,
      availability: json['availability'] as String?,
      education:
          (json['education'] as List?)
              ?.map((e) => Education.fromJson(e))
              .toList() ??
          [],
      workExperience:
          (json['work_experience'] as List?)
              ?.map((w) => WorkExperience.fromJson(w))
              .toList() ??
          [],
      currentCompany: mentorProfile['current_company'],
      expertiseAreas: mentorProfile['expertise_areas'] != null
          ? List<String>.from(mentorProfile['expertise_areas'])
          : null,
      sessionPrice: mentorProfile['session_price'] != null
          ? double.tryParse(mentorProfile['session_price'].toString())
          : null,
      isAcceptingMentees: mentorProfile['is_accepting_mentees'] == 1,
      rating: mentorProfile['rating'] != null
          ? double.tryParse(mentorProfile['rating'].toString())
          : null,
      totalSessions: mentorProfile['total_sessions'] as int?,
    );
  }

  String get displayName => fullName ?? email.split('@').first;
  String get initials {
    if (displayName.isEmpty) return '?';
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return displayName[0].toUpperCase();
  }
}

class Education {
  final int? id;
  final String institution;
  final String degree;
  final String fieldOfStudy;
  final int startYear;
  final int? endYear;
  final bool isCurrent;
  final String? description;

  Education({
    this.id,
    required this.institution,
    required this.degree,
    required this.fieldOfStudy,
    required this.startYear,
    this.endYear,
    this.isCurrent = false,
    this.description,
  });

  factory Education.fromJson(Map<String, dynamic> json) => Education(
    id: json['id'] as int?,
    institution: json['institution'] as String? ?? '',
    degree: json['degree'] as String? ?? '',
    fieldOfStudy: json['field_of_study'] as String? ?? '',
    startYear: json['start_year'] as int? ?? 0,
    endYear: json['end_year'] as int?,
    isCurrent: json['is_current'] == 1,
    description: json['description'] as String?,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'institution': institution,
    'degree': degree,
    'field_of_study': fieldOfStudy,
    'start_year': startYear,
    if (endYear != null) 'end_year': endYear,
    'is_current': isCurrent ? 1 : 0,
    if (description != null) 'description': description,
  };

  String get yearsRange {
    if (isCurrent) return '$startYear - Present';
    if (endYear != null) return '$startYear - $endYear';
    return startYear.toString();
  }
}

class WorkExperience {
  final int? id;
  final String company;
  final String jobTitle;
  final String employmentType;
  final String? location;
  final String startDate;
  final String? endDate;
  final bool isCurrent;
  final String? description;

  WorkExperience({
    this.id,
    required this.company,
    required this.jobTitle,
    this.employmentType = 'full_time',
    this.location,
    required this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.description,
  });

  factory WorkExperience.fromJson(Map<String, dynamic> json) => WorkExperience(
    id: json['id'] as int?,
    company: json['company'] as String? ?? '',
    jobTitle: json['job_title'] as String? ?? '',
    employmentType: json['employment_type'] as String? ?? 'full_time',
    location: json['location'] as String?,
    startDate: json['start_date']?.toString() ?? '',
    endDate: json['end_date']?.toString(),
    isCurrent: json['is_current'] == 1,
    description: json['description'] as String?,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'company': company,
    'job_title': jobTitle,
    'employment_type': employmentType,
    if (location != null) 'location': location,
    'start_date': startDate,
    if (endDate != null) 'end_date': endDate,
    'is_current': isCurrent ? 1 : 0,
    if (description != null) 'description': description,
  };

  String get dateRange {
    if (isCurrent) return '$startDate - Present';
    if (endDate != null && endDate!.isNotEmpty) return '$startDate - $endDate';
    return startDate;
  }

  String get employmentTypeDisplay =>
      employmentType.replaceAll('_', ' ').toUpperCase();
}
