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
  // Enhanced fields for better sorting
  final double? tuitionFeeUSD;
  final double? acceptanceRate;

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
    this.tuitionFeeUSD,
    this.acceptanceRate,
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
      // Enhanced fields with defaults for sorting
      tuitionFeeUSD: _parseDouble(json['tuition_fee_usd'] ?? json['tuitionFeeUSD']) ?? _estimateTuitionByRanking(json['world_ranking'] ?? json['worldRanking'] ?? 1),
      acceptanceRate: _parseDouble(json['acceptance_rate'] ?? json['acceptanceRate']) ?? _estimateAcceptanceByRanking(json['world_ranking'] ?? json['worldRanking'] ?? 1),
    );
  }

  // Helper method to parse double values safely
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // Estimate tuition based on ranking for sorting purposes
  static double _estimateTuitionByRanking(int ranking) {
    if (ranking <= 10) return 50000.0; // Top 10: ~$50k
    if (ranking <= 50) return 40000.0; // Top 50: ~$40k
    if (ranking <= 100) return 30000.0; // Top 100: ~$30k
    if (ranking <= 500) return 25000.0; // Top 500: ~$25k
    return 20000.0; // Others: ~$20k
  }

  // Estimate acceptance rate based on ranking for sorting purposes
  static double _estimateAcceptanceByRanking(int ranking) {
    if (ranking <= 10) return 8.0; // Top 10: ~8%
    if (ranking <= 50) return 15.0; // Top 50: ~15%
    if (ranking <= 100) return 25.0; // Top 100: ~25%
    if (ranking <= 500) return 40.0; // Top 500: ~40%
    return 60.0; // Others: ~60%
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
      'tuition_fee_usd': tuitionFeeUSD,
      'acceptance_rate': acceptanceRate,
    };
  }
}
