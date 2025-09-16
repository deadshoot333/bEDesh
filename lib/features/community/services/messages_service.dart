import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/messages.dart';
import '../../../core/constants/api_constants.dart';

class MessageService {
  static const String baseUrl = ApiConstants.baseUrl;

  static Future<List<Message>> getMessages(String userId, String peerId) async {
    final response = await http.get(Uri.parse("$baseUrl/api/message/$userId/$peerId"));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Message.fromJson(e, userId)).toList();
    } else {
      throw Exception("Failed to load messages");
    }
  }

  static Future<Message> sendMessage(
    String senderId,
    String receiverId,
    String content,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/message"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "senderId": senderId,
        "receiverId": receiverId,
        "content": content,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Message.fromJson(data, senderId);
    } else {
      throw Exception("Failed to send message");
    }
  }
}
