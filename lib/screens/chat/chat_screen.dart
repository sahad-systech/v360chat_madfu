import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:view360_chat/screens/chat/widgets/chat_mini_container.dart';

import '../../service/chat_api.dart';
import '../../socket/socket.dart';
import 'widgets/doc_piker.dart';

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

  final ImagePicker _imagePicker = ImagePicker();

  List<Map<String, dynamic>> _messages = [];

  List<PlatformFile> selectedFiles = [];

  bool _isSending = false;

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

  void reciveMessage(String message, List<String> files) {
    setState(() {
      _messages.add({'text': message, 'isMe': false, 'files': files});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<PlatformFile> convertXFileToPlatformFile(XFile xfile) async {
    final bytes = await xfile.readAsBytes();
    final file = File(xfile.path);
    return PlatformFile(
      name: file.uri.pathSegments.last,
      size: bytes.length,
      path: file.path,
      bytes: bytes,
    );
  }

  void showChatBottomSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      context: context,
      builder: (context) => ChatBottomSheet(
        onGalleryTap: () async {
          Navigator.pop(context);
          final result = await FilePicker.platform.pickFiles(
            type: FileType.image,
            allowMultiple: true,
          );
          if (result != null && result.files.isNotEmpty) {
            selectedFiles.clear();
            setState(() {
              selectedFiles = result.files;
            });
            for (var file in selectedFiles) {
              log("Picked gallery file: ${file.name}");
            }
          }
        },
        onCameraTap: () async {
          Navigator.pop(context);
          final pickedFile =
              await _imagePicker.pickImage(source: ImageSource.camera);
          if (pickedFile != null) {
            selectedFiles.clear();
            setState(() async {
              selectedFiles.add(await convertXFileToPlatformFile(pickedFile));
            });
          }
        },
        onDocumentTap: () async {
          Navigator.pop(context);
          final result = await FilePicker.platform.pickFiles(
            type: FileType.any,
            allowMultiple: true,
          );
          if (result != null && result.files.isNotEmpty) {
            selectedFiles.clear();
            setState(() {
              selectedFiles = result.files;
            });
            for (var file in selectedFiles) {
              log("Picked document: ${file.name}");
            }
          }
        },
        onAudioTap: () async {
          Navigator.pop(context);
          final result = await FilePicker.platform.pickFiles(
            type: FileType.any,
            allowMultiple: true,
          );
          if (result != null && result.files.isNotEmpty) {
            selectedFiles.clear();
            setState(() {
              selectedFiles = result.files;
            });
            for (var file in selectedFiles) {
              log("Picked audio file: ${file.name}");
            }
          }
        },
      ),
    );
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
            "isMe": element['senderType'] != "user"
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
    log(_imagePicker.toString());
    log(selectedFiles.toString());
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
                return ChatMiniContainer(
                    isSender: msg['isMe'],
                    documentList: msg['files'],
                    message: msg['text']);
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
                if (selectedFiles.isNotEmpty)
                  Material(
                      color: Colors.transparent,
                      child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedFiles.clear();
                            });
                          },
                          child: Icon(Icons.insert_drive_file_sharp,
                              color: Colors.grey))),
                IconButton(
                  onPressed: () => showChatBottomSheet(
                    context,
                  ),
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
                      if (_isSending) return;

                      if (_messageController.text.isNotEmpty &&
                          _messageController.text.trim() != '') {
                        setState(() => _isSending = true);

                        final Map<String, String> status =
                            await ChatService.sendChatMessageDataSource(
                          selectedFiles:
                              selectedFiles.isEmpty ? null : selectedFiles,
                          customerphone: widget.customerphone ?? '',
                          chatContent: _messageController.text.trim(),
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
                              'text': _messageController.text.trim(),
                              'isMe': true,
                            });
                            _messageController.clear();
                            selectedFiles.clear();
                          });

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToBottom();
                          });
                        }

                        setState(() => _isSending = false);
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
