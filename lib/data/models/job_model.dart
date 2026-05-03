class JobListing {
  final int id;
  final String title;
  final String company;
  final String? companyLogo;
  final String location;
  final String locationType;
  final String employmentType;
  final String experienceLevel;
  final int? salaryMin;
  final int? salaryMax;
  final String salaryCurrency;
  final String description;
  final String requirements;
  final String responsibilities;
  final String? benefits;
  final List<String>? skillsRequired;
  final bool isActive;
  final DateTime? expiresAt;
  final DateTime createdAt;

  JobListing({
    required this.id,
    required this.title,
    required this.company,
    this.companyLogo,
    required this.location,
    this.locationType = 'onsite',
    this.employmentType = 'full_time',
    this.experienceLevel = 'mid',
    this.salaryMin,
    this.salaryMax,
    this.salaryCurrency = 'USD',
    required this.description,
    required this.requirements,
    required this.responsibilities,
    this.benefits,
    this.skillsRequired,
    this.isActive = true,
    this.expiresAt,
    required this.createdAt,
  });

  factory JobListing.fromJson(Map<String, dynamic> json) {
    return JobListing(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      company: json['company'] as String? ?? '',
      companyLogo: json['company_logo'] as String?,
      location: json['location'] as String? ?? '',
      locationType: json['location_type'] as String? ?? 'onsite',
      employmentType: json['employment_type'] as String? ?? 'full_time',
      experienceLevel: json['experience_level'] as String? ?? 'mid',
      salaryMin: json['salary_min'] as int?,
      salaryMax: json['salary_max'] as int?,
      salaryCurrency: json['salary_currency'] as String? ?? 'USD',
      description: json['description'] as String? ?? '',
      requirements: json['requirements'] as String? ?? '',
      responsibilities: json['responsibilities'] as String? ?? '',
      benefits: json['benefits'] as String?,
      skillsRequired: json['skills_required'] != null
          ? List<String>.from(json['skills_required'])
          : null,
      isActive: json['is_active'] == 1,
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'])
          : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  String get salaryText {
    if (salaryMin == null && salaryMax == null) return 'Salary not specified';
    if (salaryMin != null && salaryMax != null) {
      return '$salaryCurrency ${salaryMin.toString()} - ${salaryMax.toString()}';
    }
    if (salaryMin != null) return '$salaryCurrency ${salaryMin.toString()}+';
    return 'Up to $salaryCurrency ${salaryMax.toString()}';
  }

  String get employmentTypeDisplay =>
      employmentType.replaceAll('_', ' ').toUpperCase();
}

class JobApplication {
  final int id;
  final int jobId;
  final String status;
  final DateTime appliedAt;
  final String title;
  final String company;

  JobApplication({
    required this.id,
    required this.jobId,
    required this.status,
    required this.appliedAt,
    required this.title,
    required this.company,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'] as int,
      jobId: json['job_id'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      appliedAt: DateTime.tryParse(json['applied_at'] ?? '') ?? DateTime.now(),
      title: json['title'] as String? ?? '',
      company: json['company'] as String? ?? '',
    );
  }
}
