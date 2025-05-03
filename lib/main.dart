import 'package:flutter/material.dart';
import 'package:madfu_demo/screens/login/login_screen.dart';

import 'screens/chat/chat_screen.dart';

void main() {
  runApp(const MyApp());
}

final GlobalKey<ChatScreenState> chatScreenKey = GlobalKey<ChatScreenState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ChatRegisterPage(),
    );
  }
}
