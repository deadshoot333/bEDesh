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
}

enum PostType { text, question, tips }
