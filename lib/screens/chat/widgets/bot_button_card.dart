import 'package:flutter/material.dart';

class BotReplyButton {
  final String id;
  final String title;

  const BotReplyButton({required this.id, required this.title});
}

class BotButtonCard extends StatelessWidget {
  final String? headerImage;
  final String? title;
  final String? subtitle;
  final String time;
  final List<BotReplyButton>? buttons;
  final ValueChanged<BotReplyButton>? onButtonTap;

  const BotButtonCard({
    super.key,
     this.headerImage,
     this.title,
     this.subtitle,
    required this.time,
    this.buttons,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 280,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 224, 248, 252),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header section with logo
            if(headerImage!=null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Image.network(
                headerImage!,
                fit: BoxFit.fill,
              ),
            ),

            // Optional title
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),

            // Body message section
            if(subtitle!=null)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.black38, height: 1),

            // Buttons section
            if(buttons!=null && buttons!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: buttons!.map((btn) => _optionButton(
                  text: btn.title,
                  onTap: () {
                    if (onButtonTap != null) onButtonTap!(btn);
                  },
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black38),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          children: [
            const Icon(Icons.reply_outlined, color: Colors.green, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
