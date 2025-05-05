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
  final int id;
  final String content;
  final String senderType;
  final List<String> files;
  final String createdAt;

  ChatMessage({
    required this.id,
    required this.content,
    required this.senderType,
    required this.files,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      content: json['content'] ?? '',
      senderType: json['senderType'],
      files: (json['file_path'] as List<dynamic>).cast<String>(),
      createdAt: json['createdAt'],
      id: json['id'],
    );
  }
}
