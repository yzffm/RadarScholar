/// User profile data model for RadarScholar.
///
/// Contains all profile fields from Technical Docs §4:
/// academic, experience, and interests.
///
/// CPMK 4: Model layer — domain/API data representation.
library;

/// Academic degree levels.
enum DegreeLevel {
  d3('D3'),
  d4('D4'),
  s1('S1'),
  s2('S2'),
  s3('S3');

  final String value;
  const DegreeLevel(this.value);

  static DegreeLevel? fromString(String? value) {
    if (value == null) return null;
    return DegreeLevel.values.cast<DegreeLevel?>().firstWhere(
          (e) => e!.value == value,
          orElse: () => null,
        );
  }
}

/// User profile data class.
class UserProfile {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;

  // Academic
  final String? university;
  final String? faculty;
  final String? major;
  final DegreeLevel? degreeLevel;
  final int? semester;
  final double? gpa;

  // Experience
  final List<String> organizations;
  final List<String> achievements;
  final List<String> competitions;
  final List<String> volunteering;
  final List<String> internships;
  final List<String> certifications;
  final List<String> skills;

  // Interests
  final List<String> careerInterests;
  final List<String> fieldsOfInterest;
  final String? goals;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.university,
    this.faculty,
    this.major,
    this.degreeLevel,
    this.semester,
    this.gpa,
    this.organizations = const [],
    this.achievements = const [],
    this.competitions = const [],
    this.volunteering = const [],
    this.internships = const [],
    this.certifications = const [],
    this.skills = const [],
    this.careerInterests = const [],
    this.fieldsOfInterest = const [],
    this.goals,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      university: json['university'] as String?,
      faculty: json['faculty'] as String?,
      major: json['major'] as String?,
      degreeLevel: DegreeLevel.fromString(json['degree_level'] as String?),
      semester: json['semester'] as int?,
      gpa: (json['gpa'] as num?)?.toDouble(),
      organizations: _stringList(json['organizations']),
      achievements: _stringList(json['achievements']),
      competitions: _stringList(json['competitions']),
      volunteering: _stringList(json['volunteering']),
      internships: _stringList(json['internships']),
      certifications: _stringList(json['certifications']),
      skills: _stringList(json['skills']),
      careerInterests: _stringList(json['career_interests']),
      fieldsOfInterest: _stringList(json['fields_of_interest']),
      goals: json['goals'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName,
      'university': university,
      'faculty': faculty,
      'major': major,
      'degree_level': degreeLevel?.value,
      'semester': semester,
      'gpa': gpa,
      'organizations': organizations,
      'achievements': achievements,
      'competitions': competitions,
      'volunteering': volunteering,
      'internships': internships,
      'certifications': certifications,
      'skills': skills,
      'career_interests': careerInterests,
      'fields_of_interest': fieldsOfInterest,
      'goals': goals,
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? avatarUrl,
    String? university,
    String? faculty,
    String? major,
    DegreeLevel? degreeLevel,
    int? semester,
    double? gpa,
    List<String>? organizations,
    List<String>? achievements,
    List<String>? competitions,
    List<String>? volunteering,
    List<String>? internships,
    List<String>? certifications,
    List<String>? skills,
    List<String>? careerInterests,
    List<String>? fieldsOfInterest,
    String? goals,
  }) {
    return UserProfile(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      university: university ?? this.university,
      faculty: faculty ?? this.faculty,
      major: major ?? this.major,
      degreeLevel: degreeLevel ?? this.degreeLevel,
      semester: semester ?? this.semester,
      gpa: gpa ?? this.gpa,
      organizations: organizations ?? this.organizations,
      achievements: achievements ?? this.achievements,
      competitions: competitions ?? this.competitions,
      volunteering: volunteering ?? this.volunteering,
      internships: internships ?? this.internships,
      certifications: certifications ?? this.certifications,
      skills: skills ?? this.skills,
      careerInterests: careerInterests ?? this.careerInterests,
      fieldsOfInterest: fieldsOfInterest ?? this.fieldsOfInterest,
      goals: goals ?? this.goals,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.cast<String>();
    return [];
  }
}
