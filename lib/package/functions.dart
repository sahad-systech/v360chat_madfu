import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:madfu_demo/package/api_service.dart';

/// Utility functions for the chat package

/// Used to correctly identify file types when uploading
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

/// Generates a unique ID combining timestamp and random number
String generateUniqueId() {
  final random = Random();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final randomInt = random.nextInt(100000);
  return '$timestamp$randomInt';
}

/// Retrieves the FCM token from Firebase and updates it on the backend
Future<void> getFCMToken(
    {required String userId,
    required String baseUrl,
    required String appId}) async {
  try {
    final token = await FirebaseMessaging.instance.getToken();
    await ChatService(baseUrl: baseUrl, appId: appId)
        .notificationToken(token: token!, userId: userId);
  } catch (e) {
    debugPrint('Error getting FCM token from package: $e');
  }
}
