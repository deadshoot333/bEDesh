class Message {
  final String id;
  final String text;
  final bool isMe;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.text,
    required this.isMe,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json, String currentUserId) {
    return Message(
      id: json['id'],
      text: json['content'],
      isMe: json['sender_id'] == currentUserId,
      timestamp: DateTime.parse(json['created_at']),
    );
  }
}