import 'dart:io';

import 'package:flutter/material.dart';
import 'package:madfu_demo/core/app_info.dart';

class ChatMiniContainer extends StatelessWidget {
  const ChatMiniContainer({
    super.key,
    required this.isLocalFile,
    required this.isSender,
    required this.documentList,
    required this.message,
  });

  final bool isSender;
  final String message;
  final List<String>? documentList;
  final bool isLocalFile;

  @override
  Widget build(BuildContext context) {
    // Get screen width and height for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                      : const Color.fromARGB(150, 229, 229, 229),
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
                              .last; // Assuming each document has an 'extension' key
                          switch (fileExtension) {
                            case 'aac':
                            case 'm4a':
                            case 'wav':
                              return SizedBox.shrink();
                            case 'jpg':
                            case 'jpeg':
                            case 'png':
                              return isLocalFile
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.file(
                                          File(documentList![index])),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.network(
                                          "$mediaUrl${documentList![index]}"),
                                    );
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
                              return SizedBox.shrink();
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
