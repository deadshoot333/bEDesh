class Course {
  final String id;
  final String name;
  final String level;
  final String fieldOfStudy;
  final String duration;
  final String intake;
  final String annualFee;
  final String university;
  final String url;
  final String description;

  const Course({
    required this.id,
    required this.name,
    required this.level,
    required this.fieldOfStudy,
    required this.duration,
    required this.intake,
    required this.annualFee,
    required this.university,
    this.url = '',
    this.description = '',
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      level: json['level'] ?? '',
      fieldOfStudy: json['field_of_study'] ?? '',
      duration: json['duration'] ?? '',
      intake: json['intake'] ?? '',
      annualFee: json['annual_fee']?.toString() ?? '',
      university: json['university'] ?? '',
      url: json['url'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'field_of_study': fieldOfStudy,
      'duration': duration,
      'intake': intake,
      'annual_fee': annualFee,
      'university': university,
      'url': url,
      'description': description,
    };
  }

  bool get isUndergraduate => level.toLowerCase().contains('undergraduate') || level.toLowerCase().contains('bachelor');
  bool get isPostgraduate => level.toLowerCase().contains('masters') || level.toLowerCase().contains('phd') || level.toLowerCase().contains('doctorate');
}
