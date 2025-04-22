import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../service/chat_api.dart';
import '../socket/socket.dart';

class ChatScreenController {
  static GlobalKey<ChatScreenState>? chatKey;
}

class ChatScreen extends StatefulWidget {
  final String customerId;
  final String socketId;
  final String customerName;
  final String? customerEmail;
  final String? customerphone;
  final String chatId;
  const ChatScreen({
    super.key,
    required this.customerId,
    required this.socketId,
    required this.customerName,
    this.customerEmail,
    this.customerphone,
    required this.chatId,
  });

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();

    ChatScreenController.chatKey = widget.key as GlobalKey<ChatScreenState>?;

    fetchMessage().then((value) {
      setState(() {
        _messages = value;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    });
  }

  @override
  void dispose() {
    SocketManager().disconnect();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void reciveMessage(String message) {
    setState(() {
      _messages.add({'text': message, 'isMe': false});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<List<Map<String, dynamic>>> fetchMessage() async {
    List<Map<String, dynamic>> chatList = [];
    final Uri url = Uri.parse(
        'https://webchat.systech.ae/widgetapi/messages/allMessages/${widget.customerId}');
    final header = {'app-id': '67c6a1e7ce56d3d6fa748ab6d9af3fd7'};

    try {
      final response = await http.get(url, headers: header);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        for (var element in data['data']) {
          chatList.add({
            "text": element['content'],
            "isMe": element['senderType'] == "user"
          });
        }
      } else {
        throw Exception('Error - status code ${response.statusCode}');
      }
    } catch (e) {
      log("Exception caught: $e");
      throw Exception("Exception: ${e.toString()}");
    }

    return chatList;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                vertical: media.height * 0.05, horizontal: media.width * 0.05),
            decoration: const BoxDecoration(
              color: Color(0xFFB2EBF2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Madfu',
                  style: TextStyle(
                    fontSize: media.width * 0.10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: media.height * 0.02),
                Text(
                  'Hi ${widget.customerName}',
                  style: TextStyle(
                    fontSize: media.width * 0.07,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: media.height * 0.01),
                Text(
                  'Fill in your information to start chatting with the first available agent',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: media.width * 0.04,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg['isMe']
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.06,
                    constraints: const BoxConstraints(maxWidth: 200),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: msg['isMe']
                          ? const Color.fromARGB(255, 33, 51, 243)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['text'],
                      style: TextStyle(
                        color: msg['isMe'] ? Colors.white : Colors.black,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.attach_file),
                  color: Colors.grey,
                ),
                CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 33, 40, 243),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                    onPressed: () async {
                      if (_messageController.text.isNotEmpty) {
                        final Map<String, String> status =
                            await ChatApi.sendChatMessageDataSource(
                          customerphone: widget.customerphone ?? '',
                          chatContent: _messageController.text,
                          chatId: widget.chatId,
                          messageUID:
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          socketId: widget.socketId,
                          customerName: widget.customerName,
                          customerEmail: widget.customerEmail ?? '',
                          createdAt: DateTime.now().toString(),
                        );
                        if (status['status'] == 'true') {
                          setState(() {
                            _messages.add({
                              'text': _messageController.text,
                              'isMe': true,
                            });
                            _messageController.clear();
                          });

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToBottom();
                          });
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }
}
