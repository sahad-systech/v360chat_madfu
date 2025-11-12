class ChatListResponse {
  final bool success;
  final List<ChatMessage> messages;
  final String? error;

  ChatListResponse({
    required this.success,
    required this.messages,
    this.error,
  });

  factory ChatListResponse.fromJson(Map<String, dynamic> json,bool botResponse) {
    return ChatListResponse(
      success: json['status'] == true || json['status'] == 'true',
      messages: (json['data'] as List<dynamic>)
          .map((e) => ChatMessage.fromJson(e,botResponse))
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
  final Map<String,dynamic>? botresponse;

  ChatMessage({
    required this.id,
    required this.content,
    required this.senderType,
    required this.files,
    required this.createdAt,
     this.botresponse,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json,bool botResponse) {
    final messageData = botResponse ? json['message'] : json;
    final Map<String,dynamic>? botflow = messageData['botNodeFlow'];
    return ChatMessage(
      botresponse: botflow,
      content: messageData['content'] ?? '',
      senderType: messageData['senderType']?.toString() ?? '',
      files: (messageData['file_path'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: messageData['createdAt'] ?? '',
      id: messageData['id'] ?? 0,
    );
  }
}
