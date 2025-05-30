import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:madfu_demo/core/local_storage.dart';
import 'package:madfu_demo/provider/chat_provider.dart';
import 'package:madfu_demo/screens/login/login_screen.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/chat/chat_screen.dart';
import 'services/firebase_messaging_service.dart';
import 'services/local_notification_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final localNotificationsService = LocalNotificationsService.instance();
  await localNotificationsService.init();

  final firebaseMessagingService = FirebaseMessagingService.instance();
  await firebaseMessagingService.init(
      localNotificationsService: localNotificationsService);

  runApp(
    ChangeNotifierProvider(
      create: (context) => MessageList(),
      child: const MyApp(),
    ),
  );
}

final GlobalKey<ChatScreenState> chatScreenKey = GlobalKey<ChatScreenState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? isLogined;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    final loginStatus = await AppLocalStore.getLogin();
    setState(() {
      isLogined = loginStatus;
    });
    log('Login status: $isLogined');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: isLogined == null
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : isLogined!
              ? const ChatScreen()
              : const ChatRegisterPage(),
    );
  }
}
