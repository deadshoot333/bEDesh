class Scholarship {
  final String id;
  final String name;
  final String universityName;
  final String type;
  final String weightage;
  final String degreeType;
  final String description;
  final String eligibility;
  final String deadline;
  final String applicationUrl;

  const Scholarship({
    required this.id,
    required this.name,
    required this.universityName,
    required this.type,
    required this.weightage,
    required this.degreeType,
    this.description = '',
    this.eligibility = '',
    this.deadline = '',
    this.applicationUrl = '',
  });

  factory Scholarship.fromJson(Map<String, dynamic> json) {
    return Scholarship(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      universityName: json['university_name'] ?? '',
      type: json['type'] ?? '',
      weightage: json['weightage'] ?? '',
      degreeType: json['degree_type'] ?? '',
      description: json['description'] ?? '',
      eligibility: json['eligibility'] ?? '',
      deadline: json['deadline'] ?? '',
      applicationUrl: json['url_scolarship'] ?? json['application_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'university_name': universityName,
      'type': type,
      'weightage': weightage,
      'degree_type': degreeType,
      'description': description,
      'eligibility': eligibility,
      'deadline': deadline,
      'url_scolarship': applicationUrl,
    };
  }

  bool get isFullFunding => weightage.toLowerCase().contains('full');
  bool get isPartialFunding => weightage.toLowerCase().contains('partial');
  bool get isInternational => type.toLowerCase().contains('international');
  bool get isMeritBased => type.toLowerCase().contains('merit');
}
