import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:madfu_demo/core/app_info.dart';
import 'package:madfu_demo/core/local_storage.dart';
import 'package:view360_chat/view360_chat.dart';

import '../../main.dart';
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

  @override
  void initState() {
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
        if (ChatScreenController.chatKey?.currentState != null) {
          ChatScreenController.chatKey?.currentState?.reciveMessage(
              content.toString(),
              (filePaths == null ? [] : filePaths as List<dynamic>)
                  .cast<String>());
        }
        log('content: $content');
        log('createdAt: $createdAt');
        log('filePaths: $filePaths');
        log('response: $response');
        log('senderType: $senderType');
      },
    );
    super.initState();
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
                        if (value!.isNotEmpty) {
                          final emailRegex =
                              RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                          if (!emailRegex.hasMatch(value)) {
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
                          final isValid =
                              _formKey.currentState?.validate() ?? false;

                          final phone = _phoneNumber?.trim() ?? '';
                          final phonevalid =
                              _phoneNumberValidation?.trim() ?? '';
                          final email = _emailController.text.trim();

                          if (!isValid) return;

                          // Custom logic: exactly one of phone or email is required

                          if (phonevalid.isEmpty && email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please provide at least one: a contact number or an email address.',
                                ),
                              ),
                            );
                            return;
                          }
                          // log("email $email");
                          // log("phone $phone");
                          // log("name ${_nameController.text}");
                          // log("desc ${_descController.text}");

                          final response =
                              await ChatService(baseUrl: baseUrl, appId: appId)
                                  .createChatSession(
                            chatContent: _descController.text,
                            customerName: _nameController.text,
                            customerEmail: email,
                            customerPhone: phone,
                          );

                          log("success ${response.success}");
                          log("isInQueue ${response.isInQueue}");
                          log("error ${response.error}");

                          if (response.success) {
                            AppLocalStore.setLoging(true);
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                          key: chatScreenKey,
                                        )),
                                (_) => false);
                          } else {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Fail to Login',
                                ),
                              ),
                            );
                            return;
                          }
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
