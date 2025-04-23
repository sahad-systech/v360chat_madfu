// import 'dart:convert';
// import 'dart:developer';

// import 'package:file_picker/file_picker.dart';
// import 'package:http/http.dart' as http;

// class ChatApi {
//   static Future<Map<String, String>> sendChatMessageDataSource({
//     List<PlatformFile>? selectedFiles,
//     required String chatContent,
//     required String chatId,
//     required String messageUID,
//     required String socketId,
//     required String customerName,
//     required String customerEmail,
//     required String createdAt,
//     required String customerphone,
//   }) async {
//     try {
//       var uri = Uri.parse(
//           'https://webchat.systech.ae/widgetapi/messages/customerMessage');

//       var request = http.MultipartRequest('POST', uri)
//         ..headers.addAll({
//           'app-id': '67c6a1e7ce56d3d6fa748ab6d9af3fd7',
//         })
//         ..fields.addAll({
//           'content': chatContent,
//           'ChatId': chatId,
//           'messageId': messageUID,
//           'senderType': 'customer',
//           'socketId': socketId,
//           'status': 'pending',
//           'createdAt': createdAt,
//           'customerInfo[name]': customerName,
//           'customerInfo[email]': customerEmail,
//           'customerInfo[mobile]': customerphone,
//         });

//       if (selectedFiles == null || selectedFiles.isEmpty) {
//         log("No files selected");
//       } else {
//         try {
//           for (var file in selectedFiles) {
//             if (file.path != null) {
//               // request.files.add(
//               //   await http.MultipartFile.fromPath(
//               //     'files',
//               //     file.path!,
//               //     filename: file.name,
//               //   ),
//               // );
//               request.files
//                   .add(await http.MultipartFile.fromPath('files', file.path!));
//             } else {
//               throw Exception('File path is null for: ${file.path}');
//             }
//           }
//         } catch (e) {
//           log("File upload failed, continuing without files: $e");
//         }
//       }

//       log("Sending chat message with files: ${selectedFiles?.map((e) => e.name).toList()}");

//       final response = await request.send();

//       final responseString = await response.stream.bytesToString();

//       if (response.statusCode == 200 || response.statusCode == 304) {
//         final responseData = jsonDecode(responseString);
//         log("Response data: $responseData");
//         return {
//           "status": responseData['status'].toString(),
//           "id": responseData['content']['id'].toString(),
//         };
//       } else {
//         log("Failed with status: ${response.statusCode}, body: $responseString");
//         return {
//           "status": 'false',
//           "id": "0",
//         };
//       }
//     } catch (e) {
//       log("Exception in sendChatMessageDataSource: $e");
//       return {
//         "status": 'false',
//         "id": "0",
//       };
//     }
//   }
// }
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:file_picker/file_picker.dart';

class ChatService {
  static Future<Map<String, String>> sendChatMessageDataSource({
    List<PlatformFile>? selectedFiles,
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
      var uri = Uri.parse(
          'https://webchat.systech.ae/widgetapi/messages/customerMessage');

      var request = http.MultipartRequest('POST', uri)
        ..headers.addAll({
          'app-id': '67c6a1e7ce56d3d6fa748ab6d9af3fd7',
        })
        ..fields.addAll({
          'content': chatContent,
          'ChatId': chatId,
          'messageId': messageUID,
          'senderType': 'customer',
          'socketId': socketId,
          'status': 'pending',
          'createdAt': createdAt,
          'customerInfo[name]': customerName,
          'customerInfo[email]': customerEmail,
          'customerInfo[mobile]': customerphone,
        });

      if (selectedFiles != null && selectedFiles.isNotEmpty) {
        for (var file in selectedFiles) {
          if (file.path != null) {
            final mimeType = lookupMimeType(file.path!);
            final contentType = mimeType != null
                ? MediaType.parse(mimeType)
                : MediaType('application', 'octet-stream');

            request.files.add(
              await http.MultipartFile.fromPath(
                'files',
                file.path!,
                filename: file.name,
                contentType: contentType,
              ),
            );
          } else {
            throw Exception('File path is null for: ${file.name}');
          }
        }
      } else {
        log("No files selected");
      }

      log("Sending chat message with files: ${selectedFiles?.map((e) => e.name).toList()}");

      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 304) {
        final responseData = jsonDecode(responseString);
        log("Response data: $responseData");
        return {
          "status": responseData['status'].toString(),
          "id": responseData['content']['id'].toString(),
        };
      } else {
        log("Failed with status: ${response.statusCode}, body: $responseString");
        return {
          "status": 'false',
          "id": "0",
        };
      }
    } catch (e) {
      log("Exception in sendChatMessageDataSource: $e");
      return {
        "status": 'false',
        "id": "0",
      };
    }
  }
}
