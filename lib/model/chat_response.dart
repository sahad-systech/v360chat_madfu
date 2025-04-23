class ChatMessageResponse {
  final bool success;
  final String? messageId;
  final String? error;

  ChatMessageResponse({
    required this.success,
    this.messageId,
    this.error,
  });

  factory ChatMessageResponse.fromJson(Map<String, dynamic> json) {
    final topLevelStatus = json['status'] == true || json['status'] == 'true';
    final contentStatus = json['content']?['status'];
    final messageId = json['content']?['id']?.toString();

    if (!topLevelStatus || contentStatus == false || contentStatus == 'false') {
      return ChatMessageResponse(
        success: true,
        error: json['content']?['message'] ?? 'Unknown error occurred.',
      );
    }

    return ChatMessageResponse(
      success: true,
      messageId: messageId,
    );
  }

  factory ChatMessageResponse.error(String errorMessage) {
    return ChatMessageResponse(
      success: false,
      error: errorMessage,
    );
  }
}
