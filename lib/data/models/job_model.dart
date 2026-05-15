import 'package:flutter/material.dart';

// ============================================================
// JOB LISTING
// ============================================================
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
  final int? postedBy;
  final bool isActive;
  final int viewsCount;
  final int applicationsCount;
  final DateTime? expiresAt;
  final DateTime createdAt;

  const JobListing({
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
    this.postedBy,
    this.isActive = true,
    this.viewsCount = 0,
    this.applicationsCount = 0,
    this.expiresAt,
    required this.createdAt,
  });

  factory JobListing.fromJson(Map<String, dynamic> json) {
    List<String>? skills;
    final raw = json['skills_required'];
    if (raw != null) {
      try {
        if (raw is List) {
          skills = List<String>.from(raw);
        } else if (raw is String && raw.isNotEmpty) {
          skills = raw.split(',').map((s) => s.trim()).toList();
        }
      } catch (_) {}
    }
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
      skillsRequired: skills,
      postedBy: json['posted_by'] as int?,
      isActive: (json['is_active'] as int?) == 1,
      viewsCount: json['views_count'] as int? ?? 0,
      applicationsCount: json['applications_count'] as int? ?? 0,
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'company': company,
    'company_logo': companyLogo,
    'location': location,
    'location_type': locationType,
    'employment_type': employmentType,
    'experience_level': experienceLevel,
    'salary_min': salaryMin,
    'salary_max': salaryMax,
    'salary_currency': salaryCurrency,
    'description': description,
    'requirements': requirements,
    'responsibilities': responsibilities,
    'benefits': benefits,
    'skills_required': skillsRequired,
    'posted_by': postedBy,
    'is_active': isActive ? 1 : 0,
    'views_count': viewsCount,
    'applications_count': applicationsCount,
    'expires_at': expiresAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };

  JobListing copyWith({
    String? title,
    String? company,
    String? location,
    String? locationType,
    String? employmentType,
    String? experienceLevel,
    int? salaryMin,
    int? salaryMax,
    String? description,
    bool? isActive,
  }) => JobListing(
    id: id,
    title: title ?? this.title,
    company: company ?? this.company,
    companyLogo: companyLogo,
    location: location ?? this.location,
    locationType: locationType ?? this.locationType,
    employmentType: employmentType ?? this.employmentType,
    experienceLevel: experienceLevel ?? this.experienceLevel,
    salaryMin: salaryMin ?? this.salaryMin,
    salaryMax: salaryMax ?? this.salaryMax,
    salaryCurrency: salaryCurrency,
    description: description ?? this.description,
    requirements: requirements,
    responsibilities: responsibilities,
    benefits: benefits,
    skillsRequired: skillsRequired,
    postedBy: postedBy,
    isActive: isActive ?? this.isActive,
    viewsCount: viewsCount,
    applicationsCount: applicationsCount,
    expiresAt: expiresAt,
    createdAt: createdAt,
  );

  // ── Display helpers ───────────────────────────────────────
  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toString();
  }

  String get salaryText {
    if (salaryMin == null && salaryMax == null) return 'Salary not specified';
    if (salaryMin != null && salaryMax != null)
      return '$salaryCurrency ${_fmt(salaryMin!)} – ${_fmt(salaryMax!)}';
    if (salaryMin != null) return '$salaryCurrency ${_fmt(salaryMin!)}+';
    return 'Up to $salaryCurrency ${_fmt(salaryMax!)}';
  }

  String get employmentTypeDisplay => employmentType
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');

  String get locationTypeDisplay =>
      locationType[0].toUpperCase() + locationType.substring(1);

  String get experienceLevelDisplay {
    const m = {
      'entry': 'Entry Level',
      'mid': 'Mid Level',
      'senior': 'Senior Level',
      'lead': 'Lead',
      'executive': 'Executive',
    };
    return m[experienceLevel] ?? experienceLevel;
  }

  Color get locationTypeColor {
    switch (locationType) {
      case 'remote':
        return Colors.green;
      case 'hybrid':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Color get employmentTypeColor {
    switch (employmentType) {
      case 'full_time':
        return Colors.blue;
      case 'part_time':
        return Colors.purple;
      case 'contract':
        return Colors.orange;
      case 'internship':
        return Colors.teal;
      case 'freelance':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get hasSalary => salaryMin != null || salaryMax != null;
  bool get isRemote => locationType == 'remote';
  bool get isHybrid => locationType == 'hybrid';
  bool get isFullTime => employmentType == 'full_time';

  @override
  bool operator ==(Object other) => other is JobListing && other.id == id;
  @override
  int get hashCode => id.hashCode;
  @override
  String toString() => 'JobListing($id: $title @ $company)';
}

// ============================================================
// JOB APPLICATION
// ============================================================
class JobApplication {
  final int id;
  final int jobId;
  final String status;
  final String? coverLetter;
  final DateTime appliedAt;
  final String title;
  final String company;
  final String? location;
  final String? employmentType;
  final int? salaryMin;
  final int? salaryMax;
  final String? salaryCurrency;

  const JobApplication({
    required this.id,
    required this.jobId,
    required this.status,
    this.coverLetter,
    required this.appliedAt,
    required this.title,
    required this.company,
    this.location,
    this.employmentType,
    this.salaryMin,
    this.salaryMax,
    this.salaryCurrency,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) => JobApplication(
    id: json['id'] as int? ?? 0,
    jobId: json['job_id'] as int? ?? 0,
    status: json['status'] as String? ?? 'pending',
    coverLetter: json['cover_letter'] as String?,
    appliedAt:
        DateTime.tryParse(json['applied_at'] as String? ?? '') ??
        DateTime.now(),
    title: json['title'] as String? ?? '',
    company: json['company'] as String? ?? '',
    location: json['location'] as String?,
    employmentType: json['employment_type'] as String?,
    salaryMin: json['salary_min'] as int?,
    salaryMax: json['salary_max'] as int?,
    salaryCurrency: json['salary_currency'] as String?,
  );

  String get statusDisplay {
    const m = {
      'pending': 'Pending Review',
      'reviewed': 'Under Review',
      'shortlisted': 'Shortlisted ⭐',
      'rejected': 'Not Selected',
      'hired': 'Hired! 🎉',
      'withdrawn': 'Withdrawn',
    };
    return m[status] ?? status;
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'reviewed':
        return Colors.blue;
      case 'shortlisted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'hired':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'reviewed':
        return Icons.visibility;
      case 'shortlisted':
        return Icons.star;
      case 'rejected':
        return Icons.close;
      case 'hired':
        return Icons.celebration;
      default:
        return Icons.help_outline;
    }
  }

  bool get isPending => status == 'pending';
  bool get isShortlisted => status == 'shortlisted';
  bool get isHired => status == 'hired';
  bool get isRejected => status == 'rejected';

  @override
  String toString() => 'JobApplication($id: $title @ $company [$status])';
}
