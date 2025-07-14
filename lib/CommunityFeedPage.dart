import 'package:flutter/material.dart';

class CommunityFeedPage extends StatefulWidget {
  const CommunityFeedPage({super.key});

  @override
  State<CommunityFeedPage> createState() => _CommunityFeedPageState();
}

class _CommunityFeedPageState extends State<CommunityFeedPage> {
  final List<Post> posts = [
    Post(
      id: '1',
      userImage: 'assets/user1.jpg',
      userName: 'Rahul Sharma',
      userLocation: 'Mumbai, India',
      timeAgo: '2h ago',
      content:
          'Just received my acceptance letter from University of Manchester! 🎉 The journey was tough but totally worth it. Happy to share my experience with anyone planning to apply.',
      likes: 24,
      comments: 8,
      isLiked: false,
      tags: ['UK', 'Masters', 'Manchester'],
      postType: PostType.text,
    ),
    Post(
      id: '2',
      userImage: 'assets/user2.jpg',
      userName: 'Priya Patel',
      userLocation: 'Delhi, India',
      timeAgo: '4h ago',
      content:
          'Can anyone help me with SOP writing for Canadian universities? I\'m struggling with the structure and would love some guidance.',
      likes: 15,
      comments: 12,
      isLiked: true,
      tags: ['Canada', 'SOP', 'Help'],
      postType: PostType.question,
    ),
    Post(
      id: '3',
      userImage: 'assets/user3.jpg',
      userName: 'Ahmed Khan',
      userLocation: 'Dhaka, Bangladesh',
      timeAgo: '6h ago',
      content:
          'Finally landed in Melbourne! First week at university has been amazing. The campus is beautiful and people are so welcoming. Missing home food though 😅',
      likes: 31,
      comments: 6,
      isLiked: false,
      tags: ['Australia', 'Melbourne', 'Experience'],
      postType: PostType.text,
      images: ['assets/melbourne_campus.jpg'],
    ),
    Post(
      id: '4',
      userImage: 'assets/user4.jpg',
      userName: 'Sarah Johnson',
      userLocation: 'Toronto, Canada',
      timeAgo: '8h ago',
      content:
          'Top 5 mistakes to avoid while applying to US universities:\n1. Not researching properly\n2. Generic essays\n3. Missing deadlines\n4. Not preparing for interviews\n5. Ignoring financial planning',
      likes: 67,
      comments: 23,
      isLiked: true,
      tags: ['USA', 'Tips', 'Application'],
      postType: PostType.tips,
    ),
    Post(
      id: '5',
      userImage: 'assets/user5.jpg',
      userName: 'Michael Chen',
      userLocation: 'London, UK',
      timeAgo: '12h ago',
      content:
          'Anyone else struggling with accommodation costs in London? Looking for shared apartments near Imperial College. Budget is £800-1000/month.',
      likes: 18,
      comments: 15,
      isLiked: false,
      tags: ['UK', 'London', 'Accommodation'],
      postType: PostType.question,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Community',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // Search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {
              // Notifications
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Actions Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/user_avatar.jpg'),
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _showCreatePostDialog(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Text(
                        'Share your experience or ask a question...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter Tabs
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildFilterChip('All', true),
                  _buildFilterChip('Questions', false),
                  _buildFilterChip('Experiences', false),
                  _buildFilterChip('Tips', false),
                  _buildFilterChip('USA', false),
                  _buildFilterChip('UK', false),
                  _buildFilterChip('Canada', false),
                ],
              ),
            ),
          ),

          // Posts Feed
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostCard(
                  post: posts[index],
                  onLike: () {
                    setState(() {
                      posts[index].isLiked = !posts[index].isLiked;
                      if (posts[index].isLiked) {
                        posts[index].likes++;
                      } else {
                        posts[index].likes--;
                      }
                    });
                  },
                  onComment: () {
                    _showCommentsDialog(context, posts[index]);
                  },
                  onShare: () {
                    // Share functionality
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreatePostDialog(context);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          // Filter logic
        },
        backgroundColor: Colors.grey.shade100,
        selectedColor: Colors.blue.shade100,
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue : Colors.grey.shade700,
        ),
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CreatePostDialog(),
    );
  }

  void _showCommentsDialog(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CommentsDialog(post: post),
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(post.userImage),
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${post.userLocation} • ${post.timeAgo}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _getPostTypeIcon(post.postType),
                  color: _getPostTypeColor(post.postType),
                  size: 16,
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(post.content, style: const TextStyle(fontSize: 14)),
          ),

          // Images (if any)
          if (post.images != null && post.images!.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                itemCount: post.images!.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 250,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage(post.images![index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // Tags
          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 6,
                children:
                    post.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],

          // Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onLike,
                  child: Row(
                    children: [
                      Icon(
                        post.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: post.isLiked ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likes}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: onComment,
                  child: Row(
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.comments}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onShare,
                  child: Icon(
                    Icons.share_outlined,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPostTypeIcon(PostType type) {
    switch (type) {
      case PostType.question:
        return Icons.help_outline;
      case PostType.tips:
        return Icons.lightbulb_outline;
      case PostType.text:
      default:
        return Icons.article_outlined;
    }
  }

  Color _getPostTypeColor(PostType type) {
    switch (type) {
      case PostType.question:
        return Colors.orange;
      case PostType.tips:
        return Colors.green;
      case PostType.text:
      default:
        return Colors.blue;
    }
  }
}

class CreatePostDialog extends StatefulWidget {
  const CreatePostDialog({super.key});

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final TextEditingController _contentController = TextEditingController();
  PostType _selectedType = PostType.text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Create Post',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Post'),
                ),
              ],
            ),
          ),

          // Post Type Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildPostTypeChip('Share', PostType.text),
                _buildPostTypeChip('Ask', PostType.question),
                _buildPostTypeChip('Tips', PostType.tips),
              ],
            ),
          ),

          // Content Input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _contentController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: _getHintText(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Additional Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    // Add photo
                  },
                  icon: const Icon(Icons.photo_camera_outlined),
                ),
                IconButton(
                  onPressed: () {
                    // Add tags
                  },
                  icon: const Icon(Icons.tag_outlined),
                ),
                IconButton(
                  onPressed: () {
                    // Add location
                  },
                  icon: const Icon(Icons.location_on_outlined),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPostTypeChip(String label, PostType type) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String _getHintText() {
    switch (_selectedType) {
      case PostType.question:
        return 'Ask your question about studying abroad...';
      case PostType.tips:
        return 'Share your tips and advice...';
      case PostType.text:
      default:
        return 'Share your experience or thoughts...';
    }
  }
}

class CommentsDialog extends StatelessWidget {
  final Post post;

  const CommentsDialog({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Comments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Comments List
          Expanded(
            child: ListView.builder(
              itemCount: 3, // Sample comments
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(
                          'assets/user${index + 1}.jpg',
                        ),
                        radius: 16,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'User ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'This is a sample comment for the post. Very helpful information!',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '2h ago',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Comment Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Send comment
                  },
                  icon: const Icon(Icons.send, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Data Models
class Post {
  final String id;
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
