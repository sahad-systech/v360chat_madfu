import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:madfu_demo/package/src/api/api_service.dart';

String getMimeType(String path) {
  final extension = path.split('.').last.toLowerCase();

  switch (extension) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'gif':
      return 'image/gif';
    case 'pdf':
      return 'application/pdf';
    case 'mp4':
      return 'video/mp4';
    case 'xlsx':
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    case 'csv':
      return 'text/csv';
    default:
      return 'application/octet-stream'; // Fallback for unknown types
  }
}

String generateUniqueId() {
  final random = Random();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final randomInt = random.nextInt(100000);
  return '$timestamp$randomInt';
}

Future<String?> getFCMToken(
    {required String userId,
    required String baseUrl,
    required String appId}) async {
  try {
    final token = await FirebaseMessaging.instance.getToken();
    print('FCM Token from package: $token');
    await ChatService(baseUrl: baseUrl, appId: appId)
        .notificationToken(token: token!, userId: userId);
    return token;
  } catch (e) {
    print('Error getting FCM token from package: $e');
    return null;
  }
}
