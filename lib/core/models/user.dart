class User {
  final String id;
  final String email;
  final String? mobile;

  User({
    required this.id,
    required this.email,
    this.mobile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'] as String,
      mobile: json['mobile'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'mobile': mobile,
    };
  }
}
