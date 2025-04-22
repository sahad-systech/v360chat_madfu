import 'package:flutter/material.dart';

import 'screens/chat/chat_screen.dart';
import 'screens/login/login_screen.dart';

void main() {
  runApp(const MyApp());
}

final GlobalKey<ChatScreenState> chatScreenKey = GlobalKey<ChatScreenState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ChatRegisterPage(),
      // home: ChatRegisterPage(),
    );
  }
}
