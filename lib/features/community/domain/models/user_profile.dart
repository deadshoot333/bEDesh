class UserProfile {
  final String id;
  final String name;
  final String location;
  final String bio;
  final String joinedDate;
  int followersCount;
  final int followingCount;
  final int postsCount;
  final String university;
  final String course;
  final List<String> interests;
  final List<String> achievements;
  final List<String> languages;
  final String profileImageUrl;
  final String coverImageUrl;

  UserProfile({
    required this.id,
    required this.name,
    required this.location,
    required this.bio,
    required this.joinedDate,
    required this.followersCount,
    required this.followingCount,
    required this.postsCount,
    required this.university,
    required this.course,
    required this.interests,
    required this.achievements,
    required this.languages,
    required this.profileImageUrl,
    required this.coverImageUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      bio: json['bio'] ?? '',
      joinedDate: json['joinedDate'] ?? '',
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      postsCount: json['postsCount'] ?? 0,
      university: json['university'] ?? '',
      course: json['course'] ?? '',
      interests: List<String>.from(json['interests'] ?? []),
      achievements: List<String>.from(json['achievements'] ?? []),
      languages: List<String>.from(json['languages'] ?? []),
      profileImageUrl: json['profileImageUrl'] ?? '',
      coverImageUrl: json['coverImageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'bio': bio,
      'joinedDate': joinedDate,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'university': university,
      'course': course,
      'interests': interests,
      'achievements': achievements,
      'languages': languages,
      'profileImageUrl': profileImageUrl,
      'coverImageUrl': coverImageUrl,
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? location,
    String? bio,
    String? joinedDate,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    String? university,
    String? course,
    List<String>? interests,
    List<String>? achievements,
    List<String>? languages,
    String? profileImageUrl,
    String? coverImageUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      joinedDate: joinedDate ?? this.joinedDate,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      university: university ?? this.university,
      course: course ?? this.course,
      interests: interests ?? this.interests,
      achievements: achievements ?? this.achievements,
      languages: languages ?? this.languages,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
    );
  }
}