import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:madfu_demo/package/functions.dart';
import 'package:madfu_demo/package/local_storage.dart';
import 'package:madfu_demo/package/models/chat_list_response.dart';
import 'package:madfu_demo/package/models/chat_register_response.dart';
import 'package:madfu_demo/package/models/chat_send_response.dart';
import 'package:madfu_demo/package/models/view360chatprefs.dart';
import 'package:madfu_demo/package/socket_manager.dart';



class ChatService {
  final String baseUrl;
  final String appId;

  ChatService({required this.baseUrl, required this.appId});

  socketEmitIsWorking(String customerId) {
    SocketManager().socket.emit("joinRoom", "customer-$customerId");
  }

  Future<ChatRegisterResponse> createChatSession({
    required String chatContent,
    required String customerName,
    String? customerEmail,
    String? customerPhone,
    String? languageInstance,
  }) async {
    final String updatedBaseUrl = baseUrl.replaceAll('https://', '');
    final String chatId = generateUniqueId();
    final String socketId = SocketManager().socket.id!;
    try {
      final uri =
          Uri.https(updatedBaseUrl, "/widgetapi/messages/customerMessage");

      final request = http.MultipartRequest('POST', uri)
        ..headers['app-id'] = appId
        ..fields.addAll({
          'content': chatContent,
          'ChatId': chatId,
          'messageId': '${DateTime.now().millisecondsSinceEpoch}',
          'senderType': 'customer',
          'customerId': '',
          'socketId': socketId,
          'status': 'pending',
          'lang': languageInstance ?? 'en',
          'createdAt': DateTime.now().toString(),
          'customerInfo[name]': customerName,
          'customerInfo[email]': customerEmail ?? '',
          'customerInfo[mobile]': customerPhone ?? '',
        });
      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 304) {
        final json = jsonDecode(responseString);
        final topLevelStatus =
            json['status'] == true || json['status'] == 'true';
        final contentStatus = json['content']?['status'];
        final bool isQuieue = json['is_queue'] ?? false;
        final bool isBot = json['content']?['message'] == 'Bot Response';
        final String? botId = json['content']?['payload']?['botChatId']?.toString();
        final contentId = json['chatId']?.toString();
        
        final customerId = json['customerId']?.toString();
        socketEmitIsWorking(customerId ?? '');
        await View360ChatPrefs.saveString(
           botIdValue:botId ?? '0000',
            isBotValue: isBot,
            isInQueueValue: isQuieue,
            customerCondentIdValue: contentId ?? '',
            chatIdKeyValue: chatId,
            customerIdKeyValue: !topLevelStatus ||
                    contentStatus == false ||
                    contentStatus == 'false'
                ? json['customerId']?.toString() ?? ''
                : customerId ?? '',
            customerNameKeyValue: customerName,
            customerEmailKeyValue: customerEmail ?? '',
            customerPhoneKeyValue: customerPhone ?? '');
        getFCMToken(
            userId: customerId.toString(), baseUrl: baseUrl, appId: appId);

         

        return ChatRegisterResponse.fromJson(json);
      } else {
        return ChatRegisterResponse.error(
          'Failed with status ${response.statusCode}: $responseString',
        );
      }
    } on SocketException {
      return ChatRegisterResponse.error('No Internet connection');
    } on TimeoutException {
      return ChatRegisterResponse.error('Request timed out');
    } on HttpException {
      return ChatRegisterResponse.error('HTTP error occurred');
    } on FormatException {
      return ChatRegisterResponse.error('Invalid response format');
    } catch (e) {
      debugPrint('Exception in createChatSession: $e');
      return ChatRegisterResponse.error(e.toString());
    }
  }

  Future<ChatSentResponse> sendChatMessage({
    List<String>? filePath,
    required String chatContent,
  }) async {
    final String updatedBaseUrl = baseUrl.replaceAll('https://', '');
    final String socketId = SocketManager().socket.id!;
    const allowedExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.pdf',
      '.gif',
      '.mp4',
      '.xlsx',
      '.csv',
    ];

    try {
      final uri =
          Uri.https(updatedBaseUrl, "/widgetapi/messages/customerMessage");
      final View360ChatPrefsModel localstorage =
          await View360ChatPrefs.getString();

      final request = http.MultipartRequest('POST', uri)
        ..headers['app-id'] = appId;
      request.fields.addAll({
        'ChatId': localstorage.chatId,
        'content': chatContent,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'customerInfo[name]': localstorage.customerName,
        'customerInfo[mobile]': localstorage.customerPhone,
        'customerInfo[email]': localstorage.customerEmail,
        'messageId': '${DateTime.now().millisecondsSinceEpoch}',
        'senderType': 'customer',
        'socketId': socketId,
        'status': 'pending',
      });

      if (filePath != null && filePath.isNotEmpty) {
        for (var file in filePath) {
          String ext = '.${file.split('.').last.toLowerCase()}';
          if (!allowedExtensions.contains(ext)) {
            return ChatSentResponse.error('Unsupported file extension: $ext');
          }
          String fileName = file.split('/').last;
          final mimeType = getMimeType(file);
          final parts = mimeType.split('/');
          final contentType = MediaType(parts[0], parts[1]);
          request.files.add(await http.MultipartFile.fromPath(
            'files',
            file,
            filename: fileName,
            contentType: contentType,
          ));
        }
      }

      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 304) {
        final json = jsonDecode(responseString);
        log(json.toString());
         final bool isQuieue = json['is_queue'] ?? false;
         final customerId = json['customerId']?.toString();
        await View360ChatPrefs.saveIsBotValue(json['content']['message'] == 'Bot Response');
        await View360ChatPrefs.changeQueueStatus(isQuieue);
        await View360ChatPrefs.saveCustomerId(customerId ?? '000');
        return ChatSentResponse.fromJson(json);
      } else {
        return ChatSentResponse.error(
          'Failed with status ${response.statusCode}: $responseString',
        );
      }
    } on SocketException {
      return ChatSentResponse.error('No Internet connection');
    } on TimeoutException {
      return ChatSentResponse.error('Request timed out');
    } on HttpException {
      return ChatSentResponse.error('HTTP error occurred');
    } on FormatException {
      return ChatSentResponse.error('Invalid response format');
    } catch (e) {
      return ChatSentResponse.error(e.toString());
    }
  }

  Future<ChatListResponse> fetchMessages() async {
    final View360ChatPrefsModel localstorage =
        await View360ChatPrefs.getString();
    final String contentId = localstorage.customerContentId;
    final bool? isBot = await View360ChatPrefs.getIsSBot(); 
    final String? botId = await View360ChatPrefs.getBotId(); 
    final bool isInQueue = localstorage.isInQueue;
    Uri url;
    if (isBot ?? false) {
      url = Uri.parse('$baseUrl/widgetapi/messages/bot-chat/messages/$botId');
    } else {
         if (isInQueue) {
      final String customerId = localstorage.customerId;
      final String chatId = localstorage.chatId;
      url = Uri.parse(
          '$baseUrl/widgetapi/messages/chatQueueMessages?customerId=$customerId&channelChatId=$chatId');
    } else {
      url = Uri.parse('$baseUrl/widgetapi/messages/allMessages/$contentId');
    }
    log('content id : $contentId');
    log('fetch url : ${url.toString()}');
    log('isBot : $isBot');
    }
 
    final headers = {'app-id': appId};

    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 20)); // Optional: set timeout

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChatListResponse.fromJson(data,isBot?? false);
      } else {
        return ChatListResponse.error(
            'HTTP error - status code ${response.statusCode}');
      }
    } on SocketException {
      return ChatListResponse.error('No Internet connection');
    } on TimeoutException {
      return ChatListResponse.error('Request timed out');
    } on HttpException {
      return ChatListResponse.error('HTTP error occurred');
    } on FormatException {
      return ChatListResponse.error('Invalid response format');
    } catch (e) {
      return ChatListResponse.error('Unexpected error: ${e.toString()}');
    }
  }

  Future<void> notificationToken(
      {required String token, required String userId}) async {
    try {
      var headers = {'app-id': appId, 'Content-Type': 'application/json'};
      var request = http.Request(
          'POST', Uri.parse('$baseUrl/widgetapi/messages/updateFCM'));
      request.body = jsonEncode({"customerId": userId, "fcmToken": token});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        debugPrint("FCM token updated successfully");
      } else {
        // final errorBody = await response.stream.bytesToString();
        debugPrint('Failed to update FCM token');
      }
    } catch (e) {
      debugPrint('Failed to updating FCM token');
    }
  }
}
