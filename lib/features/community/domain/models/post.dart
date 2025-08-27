class Post {
  final String id;
  final String userId;
  final String userImage;
  final String userName;
  final String userLocation;
  final String timeAgo;
  final String content;
  int likes;
  final int comments;
  bool isLiked;
  final List<String> tags;
  final PostType postType;
  final List<String>? images;

  Post({
    required this.id,
    required this.userId,
    required this.userImage,
    required this.userName,
    required this.userLocation,
    required this.timeAgo,
    required this.content,
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.tags,
    required this.postType,
    this.images,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    // Backend may provide post_type as a string, map to PostType
    PostType parsePostType(String type) {
      switch (type.toLowerCase()) {
        case 'text':
          return PostType.text;
        case 'question':
          return PostType.question;
        case 'tips':
          return PostType.tips;
        default:
          return PostType.text;
      }
    }

    return Post(
      id: json['id'].toString(),
      userId: json['user_id']?.toString() ?? '',
      userImage: json['image'] ?? '',
      userName: json['name'] ?? '',
      userLocation: json['city'] ?? '',
      timeAgo: json['created_at'] != null
          ? _calculateTimeAgo(json['created_at'])
          : '',
      content: json['content'] ?? '',
      likes: json['likes'] ?? 0,
      comments: json['comments_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      postType: parsePostType(json['post_type'] ?? 'text'),
      images: (json['images'] is List)
          ? List<String>.from(json['images'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_image': userImage,
      'user_name': userName,
      'user_location': userLocation,
      'created_at': timeAgo, // If you want to send this, otherwise remove
      'content': content,
      'likes': likes,
      'comments_count': comments,
      'is_liked': isLiked,
      'tags': tags,
      'post_type': postType.name,
      'images': images ?? [],
    };
  }

  /// Optionally, implement your own timeAgo calculation based on created_at
  static String _calculateTimeAgo(dynamic createdAt) {
    // createdAt can be a String (ISO8601) or int (timestamp)
    DateTime date;
    if (createdAt is String) {
      date = DateTime.tryParse(createdAt) ?? DateTime.now();
    } else if (createdAt is int) {
      date = DateTime.fromMillisecondsSinceEpoch(createdAt);
    } else {
      date = DateTime.now();
    }
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

enum PostType { text, question, tips }