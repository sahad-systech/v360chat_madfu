class ChatListResponse {
  final bool success;
  final List<ChatMessage> messages;
  final String? error;

  ChatListResponse({
    required this.success,
    required this.messages,
    this.error,
  });

  factory ChatListResponse.fromJson(Map<String, dynamic> json) {
    return ChatListResponse(
      success: json['status'] == true || json['status'] == 'true',
      messages: (json['data'] as List<dynamic>)
          .map((e) => ChatMessage.fromJson(e))
          .toList(),
    );
  }

  factory ChatListResponse.error(String errorMessage) {
    return ChatListResponse(
      success: false,
      messages: [],
      error: errorMessage,
    );
  }
}

class ChatMessage {
  final String text;
  final bool isMe;

  ChatMessage({
    required this.text,
    required this.isMe,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['content'] ?? '',
      isMe: json['senderType'] != "user",
    );
  }
}
