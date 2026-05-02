abstract class BaseUser {
  final int id;
  final String email;
  final String? fullName;
  final String? profilePictureUrl;
  final String role;
  final bool isVerified;
  final bool isActive;

  BaseUser({
    required this.id,
    required this.email,
    this.fullName,
    this.profilePictureUrl,
    required this.role,
    required this.isVerified,
    required this.isActive,
  });

  Map<String, dynamic> toJson();

  String get displayName => fullName ?? email.split('@').first;
  String get initials => _getInitials(displayName);

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
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
    if (isCurrent) {
      return '$startYear - Present';
    }
    if (endYear != null) {
      return '$startYear - $endYear';
    }
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
    if (isCurrent) {
      return '$startDate - Present';
    }
    if (endDate != null && endDate!.isNotEmpty) {
      return '$startDate - $endDate';
    }
    return startDate;
  }

  String get employmentTypeDisplay =>
      employmentType.replaceAll('_', ' ').toUpperCase();
}

class JobSeeker extends BaseUser {
  final String? headline;
  final String? bio;
  final String? phone;
  final String? location;
  final int? yearsOfExperience;
  final String? currentJobTitle;
  final String? desiredJobTitle;
  final List<String>? skills;
  final String? availability;
  final bool openToRemote;
  final List<Education> education;
  final List<WorkExperience> workExperience;

  JobSeeker({
    required super.id,
    required super.email,
    super.fullName,
    super.profilePictureUrl,
    required super.role,
    required super.isVerified,
    required super.isActive,
    this.headline,
    this.bio,
    this.phone,
    this.location,
    this.yearsOfExperience,
    this.currentJobTitle,
    this.desiredJobTitle,
    this.skills,
    this.availability,
    this.openToRemote = true,
    this.education = const [],
    this.workExperience = const [],
  });

  factory JobSeeker.fromJson(Map<String, dynamic> json) => JobSeeker(
    id: json['id'] as int,
    email: json['email'] as String,
    fullName: json['full_name'] as String?,
    profilePictureUrl: json['profile_picture_url'] as String?,
    role: json['role'] as String? ?? 'job_seeker',
    isVerified: json['is_verified'] == 1,
    isActive: json['is_active'] == 1,
    headline: json['headline'] as String?,
    bio: json['bio'] as String?,
    phone: json['phone'] as String?,
    location: json['location'] as String?,
    yearsOfExperience: json['years_of_experience'] as int?,
    currentJobTitle: json['current_job_title'] as String?,
    desiredJobTitle: json['desired_job_title'] as String?,
    skills: json['skills'] != null ? List<String>.from(json['skills']) : null,
    availability: json['availability'] as String?,
    openToRemote: json['open_to_remote'] == 1,
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
  );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'profile_picture_url': profilePictureUrl,
    'role': role,
    'is_verified': isVerified ? 1 : 0,
    'is_active': isActive ? 1 : 0,
    'headline': headline,
    'bio': bio,
    'phone': phone,
    'location': location,
    'years_of_experience': yearsOfExperience,
    'current_job_title': currentJobTitle,
    'desired_job_title': desiredJobTitle,
    'skills': skills,
    'availability': availability,
    'open_to_remote': openToRemote ? 1 : 0,
  };
}

class Mentor extends BaseUser {
  final String? headline;
  final String? bio;
  final String? phone;
  final String? location;
  final int? yearsOfExperience;
  final String? currentCompany;
  final String? currentJobTitle;
  final List<String>? expertiseAreas;
  final List<String>? industries;
  final String? mentoringStyle;
  final double? sessionPrice;
  final String? currency;
  final bool isAcceptingMentees;
  final double? rating;
  final int? totalSessions;
  final List<Education> education;
  final List<WorkExperience> workExperience;

  Mentor({
    required super.id,
    required super.email,
    super.fullName,
    super.profilePictureUrl,
    required super.role,
    required super.isVerified,
    required super.isActive,
    this.headline,
    this.bio,
    this.phone,
    this.location,
    this.yearsOfExperience,
    this.currentCompany,
    this.currentJobTitle,
    this.expertiseAreas,
    this.industries,
    this.mentoringStyle,
    this.sessionPrice,
    this.currency,
    this.isAcceptingMentees = true,
    this.rating,
    this.totalSessions,
    this.education = const [],
    this.workExperience = const [],
  });

  factory Mentor.fromJson(Map<String, dynamic> json) {
    final mentorProfile = json['mentor_profile'] as Map<String, dynamic>? ?? {};
    return Mentor(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      role: json['role'] as String? ?? 'mentor',
      isVerified: json['is_verified'] == 1,
      isActive: json['is_active'] == 1,
      headline: mentorProfile['headline'] as String?,
      bio: mentorProfile['bio'] as String?,
      phone: mentorProfile['phone'] as String?,
      location: mentorProfile['location'] as String?,
      yearsOfExperience: mentorProfile['years_of_experience'] as int?,
      currentCompany: mentorProfile['current_company'] as String?,
      currentJobTitle: mentorProfile['current_job_title'] as String?,
      expertiseAreas: mentorProfile['expertise_areas'] != null
          ? List<String>.from(mentorProfile['expertise_areas'])
          : null,
      industries: mentorProfile['industries'] != null
          ? List<String>.from(mentorProfile['industries'])
          : null,
      mentoringStyle: mentorProfile['mentoring_style'] as String?,
      sessionPrice: mentorProfile['session_price'] != null
          ? double.parse(mentorProfile['session_price'].toString())
          : null,
      currency: mentorProfile['currency'] as String?,
      isAcceptingMentees: mentorProfile['is_accepting_mentees'] == 1,
      rating: mentorProfile['rating'] != null
          ? double.parse(mentorProfile['rating'].toString())
          : null,
      totalSessions: mentorProfile['total_sessions'] as int?,
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
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'profile_picture_url': profilePictureUrl,
    'role': role,
    'is_verified': isVerified ? 1 : 0,
    'is_active': isActive ? 1 : 0,
    'mentor_profile': {
      'headline': headline,
      'bio': bio,
      'phone': phone,
      'location': location,
      'years_of_experience': yearsOfExperience,
      'current_company': currentCompany,
      'current_job_title': currentJobTitle,
      'expertise_areas': expertiseAreas,
      'industries': industries,
      'mentoring_style': mentoringStyle,
      'session_price': sessionPrice,
      'currency': currency,
      'is_accepting_mentees': isAcceptingMentees ? 1 : 0,
    },
  };

  String get sessionPriceText {
    if (sessionPrice == null || sessionPrice == 0) {
      return 'Free';
    }
    return '${currency ?? 'USD'} ${sessionPrice!.toStringAsFixed(2)}';
  }

  String get ratingText {
    if (rating == null) return 'New';
    return rating!.toStringAsFixed(1);
  }
}

class Admin extends BaseUser {
  Admin({
    required super.id,
    required super.email,
    super.fullName,
    super.profilePictureUrl,
    required super.role,
    required super.isVerified,
    required super.isActive,
  });

  factory Admin.fromJson(Map<String, dynamic> json) => Admin(
    id: json['id'] as int,
    email: json['email'] as String,
    fullName: json['full_name'] as String?,
    profilePictureUrl: json['profile_picture_url'] as String?,
    role: json['role'] as String? ?? 'admin',
    isVerified: json['is_verified'] == 1,
    isActive: json['is_active'] == 1,
  );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'profile_picture_url': profilePictureUrl,
    'role': role,
    'is_verified': isVerified ? 1 : 0,
    'is_active': isActive ? 1 : 0,
  };
}

class UserFactory {
  static BaseUser createUser(Map<String, dynamic> json) {
    final role = json['role'] as String? ?? 'job_seeker';
    switch (role) {
      case 'mentor':
        return Mentor.fromJson(json);
      case 'admin':
        return Admin.fromJson(json);
      default:
        return JobSeeker.fromJson(json);
    }
  }
}
