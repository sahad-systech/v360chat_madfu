import 'package:flutter/foundation.dart';

class MessageList with ChangeNotifier {
  List<Map<String, dynamic>> messages = [];

  addMessage(
      {required String message,
      required List<String> files,
      required String senderType}) {
    messages.add({
      'text': message,
      'isMe': senderType == 'user' ? false : true,
      'files': files
    });
    notifyListeners();
  }

  clearMessages() {
    messages = [];
    notifyListeners();
  }
}
