class ChatSentResponse {
  String? message;
  bool status;
  String? error;
  ChatSentResponse({this.message, required this.status, this.error});

  factory ChatSentResponse.fromJson(Map<String, dynamic> json) {
    return ChatSentResponse(
      message: json['message'],
      status: json['status'],
    );
  }

  factory ChatSentResponse.error(String error) {
    return ChatSentResponse(status: false, error: error);
  }
}
