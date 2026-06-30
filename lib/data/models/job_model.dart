// data/models/job_model.dart — v11
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
  final bool isFeatured;
  final int viewsCount;
  final int applicationsCount;
  final DateTime? expiresAt;
  final String? categoryName;
  final String? categoryColor;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  final String? contactEmail;

  const JobListing({
    required this.id,
    required this.title,
    required this.company,
    this.companyLogo,
    required this.location,
    required this.locationType,
    required this.employmentType,
    required this.experienceLevel,
    this.salaryMin,
    this.salaryMax,
    this.salaryCurrency = 'USD',
    required this.description,
    required this.requirements,
    required this.responsibilities,
    this.benefits,
    this.skillsRequired,
    this.isFeatured = false,
    this.viewsCount = 0,
    this.applicationsCount = 0,
    this.expiresAt,
    this.categoryName,
    this.categoryColor,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.contactEmail,
  });

  factory JobListing.fromJson(Map<String, dynamic> j) => JobListing(
    id:               _toInt(j['id']) ?? 0,
    title:            j['title'] as String? ?? '',
    company:          j['company'] as String? ?? '',
    companyLogo:      j['company_logo'] as String?,
    location:         j['location'] as String? ?? '',
    locationType:     j['location_type'] as String? ?? 'onsite',
    employmentType:   j['employment_type'] as String? ?? 'full_time',
    experienceLevel:  j['experience_level'] as String? ?? 'mid',
    salaryMin:        _toInt(j['salary_min']),
    salaryMax:        _toInt(j['salary_max']),
    salaryCurrency:   j['salary_currency'] as String? ?? 'USD',
    description:      j['description'] as String? ?? '',
    requirements:     j['requirements'] as String? ?? '',
    responsibilities: j['responsibilities'] as String? ?? '',
    benefits:         j['benefits'] as String?,
    skillsRequired:   _parseSkills(j['skills_required']),
    isFeatured:       (j['is_featured'] as num?)?.toInt() == 1 ||
                       j['is_featured'] == true,
    viewsCount:       _toInt(j['views_count']) ?? 0,
    applicationsCount:_toInt(j['applications_count']) ?? 0,
    expiresAt:        j['deadline'] != null
        ? DateTime.tryParse(j['deadline'] as String) : null,
    categoryName:     j['category_name'] as String?,
    categoryColor:    j['category_color'] as String?,
    createdAt:        DateTime.tryParse(
        j['created_at'] as String? ?? '') ?? DateTime.now(),
    latitude:         _toDouble(j['latitude']),
    longitude:        _toDouble(j['longitude']),
    contactEmail:     j['contact_email'] as String?,
  );

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static List<String>? _parseSkills(dynamic v) {
    if (v == null) return null;
    if (v is List) return List<String>.from(v);
    if (v is String) {
      if (v.trim().isEmpty) return null;
      return v.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'company': company,
    'location': location, 'location_type': locationType,
    'employment_type': employmentType, 'experience_level': experienceLevel,
    'salary_min': salaryMin, 'salary_max': salaryMax,
    'salary_currency': salaryCurrency,
  };

  // ── Boolean helpers ───────────────────────────────────────────
  bool get isRemote   => locationType.toLowerCase() == 'remote';
  bool get isHybrid   => locationType.toLowerCase() == 'hybrid';
  bool get isOnsite   => locationType.toLowerCase() == 'onsite';
  bool get isFullTime => employmentType.toLowerCase() == 'full_time';
  bool get isPartTime => employmentType.toLowerCase() == 'part_time';

  bool get hasLocation => latitude != null && longitude != null;
  bool get hasContact  => contactEmail != null && contactEmail!.isNotEmpty;
  bool get hasSalary   => salaryMin != null || salaryMax != null;

  // ── Display helpers ──────────────────────────────────────────
  String get salaryText {
    if (!hasSalary) return 'Salary not specified';
    String fmt(int v) {
      if (v >= 1000000) {
        return '${(v / 1000000).toStringAsFixed(1)}M';
      } else if (v >= 1000) {
        return '${(v / 1000).round()}K';
      }
      return '$v';
    }
    if (salaryMin != null && salaryMax != null) {
      return '$salaryCurrency ${fmt(salaryMin!)} - ${fmt(salaryMax!)}';
    } else if (salaryMin != null) {
      return '$salaryCurrency ${fmt(salaryMin!)}+';
    } else {
      return 'Up to $salaryCurrency ${fmt(salaryMax!)}';
    }
  }

  String get experienceLevelDisplay {
    switch (experienceLevel.toLowerCase()) {
      case 'entry':    return 'Entry Level';
      case 'mid':       return 'Mid Level';
      case 'senior':    return 'Senior Level';
      case 'lead':      return 'Lead';
      case 'executive': return 'Executive';
      default:          return _titleCase(experienceLevel);
    }
  }

  String get employmentTypeDisplay => _titleCase(employmentType);

  static String _titleCase(String s) => s
      .split('_')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');

  // ── Equality ─────────────────────────────────────────────────
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is JobListing && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'JobListing($id: $title @ $company)';
}

/// data/models/job_model.dart — v11
/// Mirrors the JSON returned by JobRepository.my_applications() in the
/// Flask backend (a.* columns joined with j.* columns from job_listings).
class JobApplication {
  final int id;
  final int jobId;
  final String status;
  final String? coverLetter;
  final int? aiScore;
  final DateTime? interviewDate;
  final DateTime appliedAt;

  // Joined job_listings fields
  final String jobTitle;
  final String company;
  final String location;
  final String employmentType;
  final int? salaryMin;
  final int? salaryMax;
  final String salaryCurrency;

  const JobApplication({
    required this.id,
    required this.jobId,
    required this.status,
    this.coverLetter,
    this.aiScore,
    this.interviewDate,
    required this.appliedAt,
    required this.jobTitle,
    required this.company,
    required this.location,
    required this.employmentType,
    this.salaryMin,
    this.salaryMax,
    this.salaryCurrency = 'USD',
  });

  factory JobApplication.fromJson(Map<String, dynamic> j) => JobApplication(
    id:             JobListing._toInt(j['id']) ?? 0,
    jobId:          JobListing._toInt(j['job_id']) ?? 0,
    status:         j['status'] as String? ?? 'pending',
    coverLetter:    j['cover_letter'] as String?,
    aiScore:        JobListing._toInt(j['ai_score']),
    interviewDate:  j['interview_date'] != null
        ? DateTime.tryParse(j['interview_date'] as String) : null,
    appliedAt:      DateTime.tryParse(
        j['applied_at'] as String? ?? '') ?? DateTime.now(),
    jobTitle:       j['title'] as String? ?? '',
    company:        j['company'] as String? ?? '',
    location:       j['location'] as String? ?? '',
    employmentType: j['employment_type'] as String? ?? 'full_time',
    salaryMin:      JobListing._toInt(j['salary_min']),
    salaryMax:      JobListing._toInt(j['salary_max']),
    salaryCurrency: j['salary_currency'] as String? ?? 'USD',
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'job_id': jobId, 'status': status,
    'cover_letter': coverLetter, 'ai_score': aiScore,
    'title': jobTitle, 'company': company, 'location': location,
    'employment_type': employmentType,
    'salary_min': salaryMin, 'salary_max': salaryMax,
    'salary_currency': salaryCurrency,
  };

  // ── Status helpers ──────────────────────────────────────────
  bool get isPending     => status == 'pending';
  bool get isReviewed    => status == 'reviewed';
  bool get isShortlisted => status == 'shortlisted';
  bool get isInterview   => status == 'interview';
  bool get isRejected    => status == 'rejected';
  bool get isHired       => status == 'hired';
  bool get isWithdrawn   => status == 'withdrawn';

  String get statusDisplay {
    switch (status) {
      case 'pending':     return 'Pending Review';
      case 'reviewed':    return 'Reviewed';
      case 'shortlisted': return 'Shortlisted';
      case 'interview':   return 'Interview Scheduled';
      case 'rejected':    return 'Not Selected';
      case 'hired':       return 'Hired';
      case 'withdrawn':   return 'Withdrawn';
      default:            return status;
    }
  }
}
