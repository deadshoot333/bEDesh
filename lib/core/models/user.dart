class User {
  final String id;
  final String name;
  final String email;
  final String? image;
  final String? university;
  final String? city;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.image,
    this.university,
    this.city,
  });

  // Create a User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      image: json['image'] as String?,
      university: json['university'] as String?,
      city: json['city'] as String?,
    );
  }

  // Convert User to JSON (for storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'image': image,
      'university': university,
      'city': city,
    };
  }
}
