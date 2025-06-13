import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:madfu_demo/core/app_info.dart';
import 'package:madfu_demo/core/local_storage.dart';
import 'package:madfu_demo/provider/chat_provider.dart';
import 'package:provider/provider.dart';
import 'package:view360_chat/view360_chat.dart';

import '../login/login_screen.dart';
import 'widgets/chat_mini_container.dart';
import 'widgets/doc_piker.dart';

class ChatScreenController {
  static GlobalKey<ChatScreenState>? chatKey;
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
  });

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final ImagePicker _imagePicker = ImagePicker();

  List<PlatformFile> selectedFiles = [];

  bool _isSending = false;
  final chatService = ChatService(
    baseUrl: baseUrl,
    appId: appId,
  );
  final socketManager = SocketManager();

  @override
  void initState() {
    super.initState();
    AppLocalStore.getLogin().then((value) {
      if (value) {
        ChatScreenController.chatKey = GlobalKey<ChatScreenState>();
        socketManager.connect(
          baseUrl: baseUrl,
          onConnected: () {
            log('connected to socket server successfully');
          },
          onMessage: ({
            required content,
            required createdAt,
            filePaths,
            required response,
            required senderType,
          }) {
            Provider.of<MessageList>(context, listen: false).addMessage(
                message: content,
                files: filePaths ?? [],
                senderType: senderType);
            log('response: $response');
          },
        );
      }
    });

    ChatService(baseUrl: baseUrl, appId: appId).fetchMessages().then((value) {
      log('messages length: ${value.messages.length}');
      log('success: ${value.success}');
      log('error: ${value.error}');
      for (var element in value.messages) {
        Provider.of<MessageList>(context, listen: false).addMessage(
            message: element.content,
            files: element.files,
            senderType: element.senderType);
      }
    });
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
                Row(
                  children: [
                    Text(
                      'Madfu',
                      style: TextStyle(
                        fontSize: media.width * 0.10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        AppLocalStore.clear();
                        Provider.of<MessageList>(context, listen: false)
                            .clearMessages();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatRegisterPage(),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.logout,
                        size: media.height * 0.04,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: media.height * 0.02),
                Text(
                  'Hi',
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
            child: Consumer<MessageList>(
              builder: (context, value, child) {
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: value.messages.length,
                  itemBuilder: (context, index) {
                    final msg = value.messages[index];
                    return ChatMiniContainer(
                      isLocalFile: msg['filePath'] != null,
                      isSender: msg['isMe'],
                      documentList: msg['filePath'] ?? msg['files'],
                      message: msg['text'],
                    );
                  },
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
                        final List<String> filepaths = [];
                        if (selectedFiles.isNotEmpty) {
                          for (var item in selectedFiles) {
                            filepaths.add(item.path!);
                          }
                        }
                        final response =
                            await ChatService(appId: appId, baseUrl: baseUrl)
                                .sendChatMessage(
                          filePath: filepaths,
                          chatContent: _messageController.text.trim(),
                        );
                        log("error: ${response.error}");
                        log("status: ${response.status}");
                        log("message: ${response.message}");
                        log('outOfOffice: ${response.isOutOfOfficeTime}');
                        if (response.status) {
                          setState(() {
                            final List<String> filePath = [];
                            for (var item in selectedFiles) {
                              filePath.add(item.path!);
                            }

                            Provider.of<MessageList>(context, listen: false)
                                .addMessage(
                                    message: _messageController.text.trim(),
                                    files: filePath,
                                    senderType: 'customer');
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
