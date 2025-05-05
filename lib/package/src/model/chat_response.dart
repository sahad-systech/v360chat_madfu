class ChateRegisterResponse {
  final bool success;
  final String? customerId;
  final String? error;
  final bool isInQueue;

  ChateRegisterResponse({
    required this.success,
    this.customerId,
    this.error,
    required this.isInQueue,
  });

  factory ChateRegisterResponse.fromJson(Map<String, dynamic> json) {
    final topLevelStatus = json['status'] == true || json['status'] == 'true';
    final contentStatus = json['content']?['status'];
    final customerId = json['content']?['id']?.toString();

    if (!topLevelStatus || contentStatus == false || contentStatus == 'false') {
      return ChateRegisterResponse(
        success: true,
        customerId: json['customerId']?.toString(),
        error: json['content']?['message'] ?? 'Agent not available',
        isInQueue: true,
      );
    }

    return ChateRegisterResponse(
      success: true,
      customerId: customerId,
      isInQueue: false,
    );
  }

  factory ChateRegisterResponse.error(String errorMessage) {
    return ChateRegisterResponse(
      success: false,
      error: errorMessage,
      isInQueue: false,
    );
  }
}
