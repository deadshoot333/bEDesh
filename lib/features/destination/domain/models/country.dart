class Country {
  final String name;
  final String internationalStudent;
  final String happinessRanking;
  final String employmentRate;
  final String imgUrl;
  final String flagUrl;
  final String countryDescription;

  Country({
    required this.name,
    required this.internationalStudent,
    required this.happinessRanking,
    required this.employmentRate,
    required this.imgUrl,
    required this.flagUrl,
    required this.countryDescription,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'] ?? '',
      internationalStudent: json['international_student'] ?? '',
      happinessRanking: json['happiness_ranking'] ?? '',
      employmentRate: json['employment_rate'] ?? '',
      imgUrl: json['img_url'] ?? '',
      flagUrl: json['flag_url'] ?? '',
      countryDescription: json['country_description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'international_student': internationalStudent,
      'happiness_ranking': happinessRanking,
      'employment_rate': employmentRate,
      'img_url': imgUrl,
      'flag_url': flagUrl,
      'country_description': countryDescription,
    };
  }
}
