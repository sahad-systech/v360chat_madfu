import 'dart:convert';

import 'package:http/http.dart' as http;

class ChatApi {
  static Future<Map<String, String>> sendChatMessageDataSource({
    required String chatContent,
    required String chatId,
    required String messageUID,
    required String socketId,
    required String customerName,
    required String customerEmail,
    required String createdAt,
    required String customerphone,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://webchat.systech.ae/widgetapi/messages/customerMessage'),
      );

      request.headers.addAll({
        'app-id': '67c6a1e7ce56d3d6fa748ab6d9af3fd7',
      });

      request.fields['content'] = chatContent;
      request.fields['ChatId'] = chatId;
      request.fields['messageId'] = messageUID;
      request.fields['senderType'] = 'customer';
      request.fields['socketId'] = socketId;
      request.fields['status'] = 'pending';
      request.fields['createdAt'] = createdAt;
      request.fields['customerInfo[name]'] = customerName;
      request.fields['customerInfo[email]'] = customerEmail;
      request.fields['customerInfo[mobile]'] = customerphone;

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 304) {
        final responseString = await response.stream.bytesToString();
        final responseData = jsonDecode(responseString);

        return {
          "status": responseData['status'].toString(),
          "id": responseData['content']['id'].toString(),
        };
      } else {
        return {
          "status": 'false',
          "id": "0",
        };
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
