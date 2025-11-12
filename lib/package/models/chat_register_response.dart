class ChatRegisterResponse {
  final bool success;
  final String? message;
  final bool isInQueue;
  final bool isOutOfOfficeTime;
  final Map<String,dynamic>? botResponse;

  ChatRegisterResponse({
    required this.success,
    this.message,
    required this.isInQueue,
    required this.isOutOfOfficeTime,
     this.botResponse,
  });

  factory ChatRegisterResponse.fromJson(Map<String, dynamic> json) {
    final topLevelStatus = json['status'] == true || json['status'] == 'true';
    final contentStatus = json['content']?['status'];
    final isOutOfOfficeTime = json["out_off_hour"];
    if(json['content']?['message'] != null && json['content']?['message'] ==  "Bot Response" ){
    return ChatRegisterResponse(
      success: true,
      isInQueue: false,
      isOutOfOfficeTime: false,
      botResponse: json['content']?['payload'] ?? {},
    );
    }
    if (isOutOfOfficeTime) {
      return ChatRegisterResponse(
        success: true,
        message: json['content']?['message'] ?? 'Out of office time',
        isInQueue: true,
        isOutOfOfficeTime: true,
      );
    }
    if (!topLevelStatus || contentStatus == false || contentStatus == 'false') {
      return ChatRegisterResponse(
        success: true,
        message: json['content']?['message'] ?? 'Agent not available',
        isInQueue: true,
        isOutOfOfficeTime: false,
      );
    }
    return ChatRegisterResponse(
      success: true,
      isInQueue: false,
      isOutOfOfficeTime: false,
    );
  }

  factory ChatRegisterResponse.error(String errorMessage) {
    return ChatRegisterResponse(
      success: false,
      message: errorMessage,
      isInQueue: false,
      isOutOfOfficeTime: false,
    );
  }
}
