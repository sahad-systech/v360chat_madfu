import 'package:flutter/foundation.dart';

class MessageList with ChangeNotifier {
  final List<Map<String, dynamic>> messages = [];

  /// Adds a normal text message (user or system)
  void addMessage({
    required String time,
    required String message,
    required bool isLocal,
    required List<String> files,
    required String senderType,
    String type = 'text', // default message type
    Map<String, dynamic>? payload, // optional structured data
  }) {
    messages.add({
      'time':time,
      'isLocal': isLocal,
      'text': message,
      'isMe': senderType == 'user', // true if sent by the user
      'files': files,
      'type': type,
      'payload': payload,
    });
    notifyListeners();
  }

  /// Adds a structured bot message (with header, buttons, etc.)
  void addBotMessage(Map<String, dynamic> payload,String? content,String time) {
    messages.add({
      'time':time,
      'isLocal': false,
      'text': content ??  payload['message']?['content'],
      'isMe': false,
      'files': <String>[],
      'type': 'bot',
      'payload': payload,
    });
    notifyListeners();
  }

  /// Clears all messages (useful when starting a new chat session)
  void clearMessages() {
    messages.clear();
    notifyListeners();
  }
}
