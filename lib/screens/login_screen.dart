import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class ChatRegisterPage extends StatelessWidget {
  const ChatRegisterPage({super.key});

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
              child: Column(
                children: [
                  _buildTextField('Full Name', media),

                  SizedBox(height: media.height * 0.02),

                  // Phone Input with Country Code
                  IntlPhoneField(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: media.height * 0.02,
                        horizontal: media.width * 0.04,
                      ),
                      counter: SizedBox.shrink(),
                      labelText: 'Contact Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    initialCountryCode: 'AE', // Saudi Arabia by default
                    onChanged: (phone) {
                      log(phone.completeNumber); // Use this to send full number
                    },
                  ),

                  SizedBox(height: media.height * 0.02),
                  _buildTextField('Email', media),

                  SizedBox(height: media.height * 0.02),
                  _buildTextField(
                    'Please describe the Issue',
                    media,
                    maxLines: 4,
                  ),

                  SizedBox(height: media.height * 0.04),

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
                      onPressed: () {
                        // handle form submission
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
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, Size media, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
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
