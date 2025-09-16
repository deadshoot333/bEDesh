class University {
  final String id;
  final String name;
  final String description;
  final String location;
  final String country;
  final String imageUrl;
  final int worldRanking;
  final int totalStudents;
  final double internationalPercentage;
  final String establishedYear;
  final String websiteUrl;
  final List<String> highlights;

  const University({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.country,
    required this.imageUrl,
    required this.worldRanking,
    required this.totalStudents,
    required this.internationalPercentage,
    required this.establishedYear,
    required this.websiteUrl,
    this.highlights = const [],
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      id: json['id'] ?? json['name'] ?? '',
      name: json['name'] ?? json['university'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '${json['name'] ?? ''}, ${json['country'] ?? ''}',
      country: json['country'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      worldRanking: int.tryParse(json['Rank']?.toString() ?? '') ?? json['world_ranking'] ?? json['worldRanking'] ?? 1,
      totalStudents: json['total_students'] ?? json['totalStudents'] ?? 20000,
      internationalPercentage: (json['international_percentage'] ?? json['internationalPercentage'] ?? 30.0).toDouble(),
      establishedYear: json['established_year'] ?? json['establishedYear'] ?? '1000',
      websiteUrl: json['url'] ?? json['website_url'] ?? json['websiteUrl'] ?? '',
      highlights: List<String>.from(json['highlights'] ?? ['World-class education', 'Research excellence', 'Historic institution']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'university': name,
      'description': description,
      'location': location,
      'country': country,
      'image_url': imageUrl,
      'world_ranking': worldRanking,
      'total_students': totalStudents,
      'international_percentage': internationalPercentage,
      'established_year': establishedYear,
      'website_url': websiteUrl,
      'highlights': highlights,
    };
  }
}
