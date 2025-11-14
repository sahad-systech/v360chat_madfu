

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:madfu_demo/core/app_info.dart';
import 'package:madfu_demo/screens/chat/widgets/bot_button_card.dart';
import 'package:madfu_demo/screens/chat/widgets/bot_list_card.dart';

class ChatMiniContainer extends StatelessWidget {
  const ChatMiniContainer({
    super.key,
    required this.isLocalFile,
    required this.isSender,
    required this.documentList,
    required this.message,
    required this.isBot,
    this.botPayload,
    this.onButtonTap,
    required this.time,
  });

  final bool isSender;
  final String message;
  final List<String>? documentList;
  final bool isLocalFile;
  final bool isBot;
  final Map<String, dynamic>? botPayload;
  final ValueChanged<BotReplyButton>? onButtonTap;
  final String time;

  @override
  Widget build(BuildContext context) {
    // Get screen width and height for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // If this is a bot message with a structured payload, render a bot card
    if (isBot && botPayload != null) {
      final String content = message;
      final String actionsType =
          (botPayload!['bot_actions']?['type'] ?? '').toString();
      // Extract header image link if provided
      final String? headerImage = (botPayload!['bot_actions']?['header']
              ?['image']?['link'])
          ?.toString();

      if (actionsType == 'button') {
        // Extract button id/title from payload
        List<BotReplyButton> buttons = [];
        final dynamic rawButtons =
            botPayload!['bot_actions']?['action']?['buttons'];
        if (rawButtons is List) {
          for (final dynamic b in rawButtons) {
            if (b is Map) {
              final String id = (b['reply']?['id'] ?? b['id'] ?? '').toString();
              final String title =
                  (b['reply']?['title'] ?? b['title'] ?? '').toString();
              if (id.isNotEmpty && title.isNotEmpty) {
                buttons.add(BotReplyButton(id: id, title: title));
              }
            }
          }
        }
        return BotButtonCard(
          headerImage: headerImage,
          title: null,
          subtitle: content.isEmpty ? null : content,
          time: time,
          buttons: buttons.isEmpty ? null : buttons,
          onButtonTap: onButtonTap,
        );
      } else if (actionsType == 'image') {
        final String? imageUrl = botPayload!['bot_actions']?['image']?['link'];
        if (imageUrl != null) {
          return Image.network(imageUrl);
        }
      } else if (actionsType == 'list') {
        // Extract bot list buttons
        List<BotReplyButton> buttons = [];
        final dynamic sections =
            botPayload!['bot_actions']?['action']?['sections'];

        if (sections is List) {
          for (final section in sections) {
            if (section is Map && section['rows'] is List) {
              for (final row in section['rows']) {
                if (row is Map) {
                  final String id = (row['id'] ?? '').toString();
                  final String title = (row['title'] ?? '').toString();
                  if (id.isNotEmpty && title.isNotEmpty) {
                    buttons.add(BotReplyButton(id: id, title: title));
                  }
                }
              }
            }
          }
        }

        return BotListCard(
          text: content.isEmpty ? null : content,
          time: time,
          botButtons: buttons,
          onButtonTap: onButtonTap,
        );
      }
    }

    return Column(
      crossAxisAlignment:
          isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                padding: (documentList?.isEmpty ?? true)
                    ? EdgeInsets.all(screenWidth * 0.03)
                    : EdgeInsets.all(screenWidth * 0.02),
                constraints: BoxConstraints(maxWidth: screenWidth * 0.7),
                decoration: BoxDecoration(
                  color: isSender
                      ? const Color.fromARGB(255, 33, 37, 243)
                      : const Color.fromARGB(255, 215, 243, 247),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isSender ? 16 : 0),
                    bottomRight: Radius.circular(isSender ? 0 : 16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: isSender
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    // Display the message content
                    // Check file extension and display appropriate UI
                    if (documentList != null && documentList!.isNotEmpty)
                      ListView.builder(
                        padding: const EdgeInsets.all(0),
                        itemCount: documentList!.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final document = documentList![index];
                          final fileExtension = document
                              .split('.')
                              .last
                              .toLowerCase(); // Assuming each document has an 'extension' key
                          switch (fileExtension) {
                            case 'jpg':
                            case 'jpeg':
                            case 'png':
                              if (isLocalFile) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.file(
                                    File(documentList![index]),
                                    fit: BoxFit.cover,
                                  ),
                                );
                              } else {
                                // For agent-sent documents, construct the proper URL
                                final imageUrl = documentList![index].startsWith('http')
                                    ? documentList![index]
                                    : '$mediaUrl${documentList![index]}';
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child; // ✅ Show image once loaded
                                      }
                                      // ✅ Show loader while loading
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 40),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1.5,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                      child: Icon(Icons.broken_image,
                                          color: Colors.grey, size: 50),
                                    ),
                                  ),
                                );
                              }
                            case 'pdf':
                              return Stack(
                                children: [
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {},
                                      child: Container(
                                        margin: EdgeInsets.all(4),
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: const Color(0xFF8B0000),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.picture_as_pdf,
                                                color: Colors.white),
                                            SizedBox(width: 10),
                                            Text(
                                              'PDF Document',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: !isSender,
                                    child: Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {},
                                          child: CircleAvatar(
                                            radius: 16,
                                            backgroundColor: Colors.grey[500],
                                            child: Icon(Icons.download_rounded,
                                                color: Colors.white, size: 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );

                            case 'gif':
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {},
                                  child: Container(
                                    margin: EdgeInsets.all(5),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: const Color(0xFF6A5ACD),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.gif,
                                            color: Colors.white),
                                        SizedBox(width: 10),
                                        Text(
                                          'GIF File',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );

                            case 'mp4':
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {},
                                  child: Container(
                                    margin: EdgeInsets.all(5),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: const Color(0xFF2E8B57),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.movie,
                                            color: Colors.white),
                                        SizedBox(width: 10),
                                        Text(
                                          'Video File',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );

                            case 'xlsx':
                            case 'csv':
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {},
                                  child: Container(
                                    margin: EdgeInsets.all(5),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: const Color(0xFF4682B4),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.table_chart,
                                            color: Colors.white),
                                        SizedBox(width: 10),
                                        Text(
                                          'Spreadsheet File',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );

                            default:
                              // Show generic file icon for unknown extensions
                              final filename = documentList![index].split('/').last;
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {},
                                  child: Container(
                                    margin: EdgeInsets.all(5),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: const Color(0xFF555555),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.file_present,
                                            color: Colors.white),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            filename.isNotEmpty ? filename : 'File',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                          }
                        },
                      ),
                    if (message.isNotEmpty)
                      Text(
                        message,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: isSender ? Colors.white : Colors.black87,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
