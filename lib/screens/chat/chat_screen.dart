import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:madfu_demo/core/app_info.dart';
import 'package:madfu_demo/core/local_storage.dart';
import 'package:madfu_demo/package/api_service.dart';
import 'package:madfu_demo/package/local_storage.dart';
import 'package:madfu_demo/package/socket_manager.dart';
import 'package:madfu_demo/provider/chat_provider.dart';
import 'package:madfu_demo/screens/chat/widgets/chat_mini_container.dart';
import 'package:provider/provider.dart';

import '../login/login_screen.dart';
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

  List<String> _selectedFilePaths() {
    final List<String> filepaths = [];
    if (selectedFiles.isNotEmpty) {
      for (var item in selectedFiles) {
        if (item.path != null) filepaths.add(item.path!);
      }
    }
    return filepaths;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setSelectedFiles(List<PlatformFile> files) {
    setState(() {
      selectedFiles
        ..clear()
        ..addAll(files);
    });
  }

  Future<void> _handleGalleryTap() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (!mounted) return;
    if (result != null && result.files.isNotEmpty) {
      _setSelectedFiles(result.files);
    }
  }

  Future<void> _handleDocumentTap() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );
    if (!mounted) return;
    if (result != null && result.files.isNotEmpty) {
      _setSelectedFiles(result.files);
    }
  }

  Future<void> _handleVideoTap() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );
    if (!mounted) return;
    if (result != null && result.files.isNotEmpty) {
      _setSelectedFiles(result.files);
    }
  }

  Future<void> _handleAudioTap() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );
    if (!mounted) return;
    if (result != null && result.files.isNotEmpty) {
      _setSelectedFiles(result.files);
    }
  }

  Future<void> _handleCameraTap() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
    if (!mounted) return;
    if (pickedFile != null) {
      final platformFile = await convertXFileToPlatformFile(pickedFile);
      if (!mounted) return;
      _setSelectedFiles([platformFile]);
    }
  }

  @override
  void initState() {
    super.initState();
    AppLocalStore.getLogin().then((value) {
      if (value) {
        ChatScreenController.chatKey = GlobalKey<ChatScreenState>();

        socketManager.connect(
          baseUrl: baseUrl,
          onConnected: () {},
          onMessage: ({
            required content,
            required createdAt,
            filePaths,
            required response,
            required senderType,
          }) {
            // Determine message content based on response type
            final messageType = response["type"];
            final updateContent = switch (messageType) {
              'end-message' => 'Message ended by agent',
              'assigned-agent' => 'Agent assigned',
              _ => content,
            };

            // Update message list
            Provider.of<MessageList>(context, listen: false).addMessage(
              time: createdAt,
              isLocal: false,
              message: updateContent,
              files: filePaths ?? [],
              senderType: senderType,
            );
          },
        );
      }

      View360ChatPrefs.isBotChat();
    });

    chatService.fetchMessages().then((value) {
      for (var element in value.messages) {
        if (element.botresponse != null) {
          Provider.of<MessageList>(context, listen: false).addBotMessage(
              element.botresponse!,
              element.content,
              _formatNowTime(isLocal: false, createdAt: element.createdAt));
        } else {
          Provider.of<MessageList>(context, listen: false).addMessage(
              time:
                  _formatNowTime(isLocal: false, createdAt: element.createdAt),
              isLocal: false,
              message: element.content,
              files: element.files,
              senderType: element.senderType);
        }
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
          await _handleGalleryTap();
        },
        onCameraTap: () async {
          Navigator.pop(context);
          await _handleCameraTap();
        },
        onDocumentTap: () async {
          Navigator.pop(context);
          await _handleDocumentTap();
        },
        onAudioTap: () async {
          Navigator.pop(context);
          await _handleAudioTap();
        },
        onVideoTap: () async {
          Navigator.pop(context);
          await _handleVideoTap();
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
                return Container(
                  color: Colors.white,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: value.messages.length,
                    itemBuilder: (context, index) {
                      final msg = value.messages[index];

                      // ✅ Skip rendering if message text is empty AND no files attached
                      final messageText = msg['text'];
                      final documentList = msg['filePath'] ?? msg['files'];
                      final hasText = messageText != null &&
                          (messageText as String).trim().isNotEmpty;
                      final hasFiles = documentList != null &&
                          (documentList as List).isNotEmpty;

                      if (!hasText && !hasFiles) {
                        return const SizedBox.shrink();
                      }

                      return ChatMiniContainer(
                        time: msg['time'],
                        onButtonTap: (btn) async {
                          if (_isSending) return;

                          _messageController.text = btn.title;
                          final btnId = btn.id.trim();
                          if (btnId.isEmpty) return;

                          setState(() => _isSending = true);

                          final contentToSend =
                              _messageController.text.trim().isNotEmpty
                                  ? _messageController.text.trim()
                                  : btnId;

                          final response = await chatService.sendChatMessage(
                            filePath: _selectedFilePaths(),
                            chatContent: contentToSend,
                          );

                          if (response.status) {
                            if (!mounted) return;
                            Provider.of<MessageList>(context, listen: false)
                                .addMessage(
                              time: _formatNowTime(isLocal: true),
                              isLocal: true,
                              message: _messageController.text.trim(),
                              files: _selectedFilePaths(),
                              senderType: 'customer',
                            );

                            _messageController.clear();
                            selectedFiles.clear();

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollToBottom();
                            });
                          }

                          // ✅ Handle bot response from API
                          final messageList =
                              Provider.of<MessageList>(context, listen: false);
                          final Map<String, dynamic>? apiResponse =
                              response.botResponse;

                          if (apiResponse != null) {
                            messageList.addBotMessage(
                              apiResponse,
                              null,
                              _formatNowTime(isLocal: true),
                            );
                          }

                          if (!mounted) return;
                          setState(() => _isSending = false);
                        },
                        isBot: msg['type'] == 'bot',
                        botPayload: msg['payload'],
                        isLocalFile: msg['isLocal'],
                        isSender: !msg['isMe'],
                        documentList: msg['filePath'] ?? msg['files'],
                        message:
                            (messageText is String ? messageText : '').trim(),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.white,
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
                  child: _isSending
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                            strokeWidth: .7,
                          ),
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                          onPressed: () async {
                            if (_isSending) return;
                            final trimmed = _messageController.text.trim();
                            final files = _selectedFilePaths();
                            // Allow sending when there is either text or files selected
                            if (trimmed.isEmpty && files.isEmpty) return;
                            setState(() => _isSending = true);
                            final response = await chatService.sendChatMessage(
                              filePath: files,
                              chatContent: trimmed.isNotEmpty ? trimmed : '',
                            );

                            if (response.status) {
                              if (!mounted) return;
                              setState(() {
                                Provider.of<MessageList>(context, listen: false)
                                    .addMessage(
                                        time: _formatNowTime(isLocal: true),
                                        isLocal: true,
                                        message: trimmed,
                                        files: _selectedFilePaths(),
                                        senderType: 'customer');
                                _messageController.clear();
                                selectedFiles.clear();
                              });

                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _scrollToBottom();
                              });
                            }
                            final messageList = Provider.of<MessageList>(
                                context,
                                listen: false);
                            // Suppose this is your API response
                            final Map<String, dynamic>? apiResponse =
                                response.botResponse;
                            // Add it as a bot message
                            if (apiResponse != null) {
                              messageList.addBotMessage(apiResponse, null,
                                  _formatNowTime(isLocal: true));
                            }
                            ///////////////////////////

                            if (!mounted) return;
                            setState(() => _isSending = false);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatNowTime({required bool isLocal, String? createdAt}) {
  final now = isLocal ? DateTime.now() : DateTime.parse(createdAt!);
  final int hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
  final String minute = now.minute.toString().padLeft(2, '0');
  final String period = now.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}
