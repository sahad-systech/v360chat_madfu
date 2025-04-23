import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:file_picker/file_picker.dart';

import '../model/chat_list_response.dart';
import '../model/chat_response.dart';

class ChatService {
  static const String _baseUrl = 'webchat.systech.ae';
  static const String _appId = '67c6a1e7ce56d3d6fa748ab6d9af3fd7';

  static Future<ChatMessageResponse> sendChatMessage({
    List<PlatformFile>? selectedFiles,
    required String chatContent,
    required String chatId,
    required String socketId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
  }) async {
    try {
      final uri = Uri.https(_baseUrl, "/widgetapi/messages/customerMessage");

      final request = http.MultipartRequest('POST', uri)
        ..headers['app-id'] = _appId
        ..fields.addAll({
          'content': chatContent,
          'ChatId': chatId,
          'messageId': '${DateTime.now().millisecondsSinceEpoch}',
          'senderType': 'customer',
          'socketId': socketId,
          'status': 'pending',
          'createdAt': DateTime.now().toString(),
          'customerInfo[name]': customerName,
          'customerInfo[email]': customerEmail,
          'customerInfo[mobile]': customerPhone,
        });

      if (selectedFiles != null && selectedFiles.isNotEmpty) {
        for (final file in selectedFiles) {
          if (file.path != null) {
            final mimeType =
                lookupMimeType(file.path!) ?? 'application/octet-stream';
            final parts = mimeType.split('/');
            final contentType = MediaType(parts[0], parts[1]);

            request.files.add(await http.MultipartFile.fromPath(
              'files',
              file.path!,
              filename: file.name,
              contentType: contentType,
            ));
          } else {
            log('⚠️ Skipped file with null path: ${file.name}');
          }
        }
      }

      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 304) {
        final json = jsonDecode(responseString);
        return ChatMessageResponse.fromJson(json);
      } else {
        return ChatMessageResponse.error(
          'Failed with status ${response.statusCode}: $responseString',
        );
      }
    } catch (e, stack) {
      log('❗ Exception in sendChatMessage: $e', stackTrace: stack);
      return ChatMessageResponse.error(e.toString());
    }
  }

  static Future<ChatListResponse> fetchMessages({
    required String customerId,
    String baseUrl = 'https://webchat.systech.ae',
    String appId = '67c6a1e7ce56d3d6fa748ab6d9af3fd7',
  }) async {
    final Uri url =
        Uri.parse('$baseUrl/widgetapi/messages/allMessages/$customerId');
    final headers = {'app-id': appId};

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChatListResponse.fromJson(data);
      } else {
        return ChatListResponse.error(
            'HTTP error - status code ${response.statusCode}');
      }
    } catch (e) {
      return ChatListResponse.error('Exception: ${e.toString()}');
    }
  }
}
