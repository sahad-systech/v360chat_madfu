import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:madfu_demo/core/app_info.dart';
import 'package:madfu_demo/core/local_storage.dart';
import 'package:madfu_demo/package/api_service.dart';
import 'package:madfu_demo/package/socket_manager.dart';
import 'package:provider/provider.dart';
// import 'package:view360_chat/view360_chat.dart';

import '../../main.dart';
import '../../provider/chat_provider.dart';
import '../chat/chat_screen.dart';

class ChatRegisterPage extends StatefulWidget {
  const ChatRegisterPage({super.key});

  @override
  State<ChatRegisterPage> createState() => _ChatRegisterPageState();
}

class _ChatRegisterPageState extends State<ChatRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _descController = TextEditingController();
  String? _phoneNumber;
  String? _phoneNumberValidation;

  final socketManager = SocketManager();
  final _emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
  bool _isSubmitting = false;
  final ChatService _chatService = ChatService(baseUrl: baseUrl, appId: appId);

  @override
  void initState() {
    log('inistate ChatRegisterPage');
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
          time: createdAt,
          isLocal: false,
            message: content, files: filePaths ?? [], senderType: senderType);
        log('response from login page: $response'); 
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _descController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  vertical: media.height * 0.05,
                  horizontal: media.width * 0.05),
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
                    'Register to Chat',
                    style: TextStyle(
                      fontSize: media.width * 0.06,
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

            // Form
            Padding(
              padding: EdgeInsets.all(media.width * 0.05),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Full Name
                    _buildTextField(
                      label: 'Full Name',
                      controller: _nameController,
                      media: media,
                      validator: (value) =>
                          value!.isEmpty ? 'Name is required' : null,
                    ),
                    SizedBox(height: media.height * 0.02),

                    // Phone Field
                    IntlPhoneField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: media.height * 0.02,
                          horizontal: media.width * 0.04,
                        ),
                        counter: const SizedBox.shrink(),
                        labelText: 'Contact Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      initialCountryCode: 'SA',
                      onChanged: (phone) {
                        _phoneNumber = phone.completeNumber;
                        _phoneNumberValidation = phone.number;
                      },
                    ),
                    SizedBox(height: media.height * 0.02),

                    // Email
                    _buildTextField(
                      label: 'Email',
                      controller: _emailController,
                      media: media,
                      validator: (value) {
                        if ((value ?? '').isNotEmpty) {
                          if (!_emailRegex.hasMatch(value!.trim())) {
                            return 'Enter a valid email';
                          }
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: media.height * 0.02),

                    // Issue Description
                    _buildTextField(
                      label: 'Please describe the Issue',
                      controller: _descController,
                      media: media,
                      maxLines: 4,
                      validator: (value) =>
                          value!.isEmpty ? 'Description is required' : null,
                    ),
                    SizedBox(height: media.height * 0.04), // Send Button
                    SizedBox(
                      width: double.infinity,
                      height: media.height * 0.07,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (_isSubmitting) return;
                          final isValid = _formKey.currentState?.validate() ?? false;

                          final phone = (_phoneNumber ?? '').trim();
                          final phonevalid = (_phoneNumberValidation ?? '').trim();
                          final email = _emailController.text.trim();
                          final description = _descController.text.trim();
                          final name = _nameController.text.trim();

                          if (!isValid) return;

                          if (phonevalid.isEmpty && email.isEmpty) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please provide at least one: a contact number or an email address.',
                                ),
                              ),
                            );
                            return;
                          }

                          setState(() => _isSubmitting = true);
                          final response = await _chatService.createChatSession(
                            chatContent: description,
                            customerName: name,
                            customerEmail: email,
                            customerPhone: phone,
                            languageInstance: 'en',
                          );

                          log("success ${response.success}");
                          log("isInQueue ${response.isInQueue}");
                          log("isOutOfOfficeTime ${response.isOutOfOfficeTime}");
                          log("message ${response.message}");
                          log("botResponse ${response.botResponse}");

                          if (response.success) {
                            await AppLocalStore.setLoging(true);
                            
                            // Add queue message if user is in queue
                            if (response.isInQueue) {
                              Provider.of<MessageList>(context, listen: false).addMessage(
                                time: DateTime.now().toString(),
                                isLocal: false,
                                message: 'message You are currently in the queue.A representative will assist you as soon as possible. We appreciate your patience.',
                                files: [],
                                senderType: 'user',
                              );
                            }
                            
                            if (!mounted) return;
                            
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  key: chatScreenKey,
                                ),
                              ),
                              (_) => false,
                            );
                          } else {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fail to Login'),
                              ),
                            );
                          }
                          if (!mounted) return;
                          setState(() => _isSubmitting = false);
                        },
                        child: Text(
                          'Send',
                          style: TextStyle(
                            fontSize: media.width * 0.05,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required Size media,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: media.height * 0.02,
          horizontal: media.width * 0.04,
        ),
      ),
    );
  }
}
