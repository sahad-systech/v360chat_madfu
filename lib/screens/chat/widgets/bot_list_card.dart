import 'package:flutter/material.dart';
import 'package:madfu_demo/screens/chat/widgets/bot_button_card.dart';

class BotListCard extends StatelessWidget {
  final String? text;
  final String time;
  final List<BotReplyButton> botButtons;
  final ValueChanged<BotReplyButton>? onButtonTap;

  const BotListCard({
    super.key,
    this.text,
    required this.time,
   required this.botButtons,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      constraints: BoxConstraints(maxWidth: screenWidth * 0.7),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 211, 242, 247),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (text != null)
            Text(
              text!,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              time,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 10,
              ),
            ),
          ),
          // if (botButtons != null && botButtons!.isNotEmpty)
          _optionButton(
            text: 'Main Menu',
            onTap: () {
              // Get a valid context from Navigator
              final navContext =
                  Navigator.of(context, rootNavigator: true).context;

              showModalBottomSheet(
                context: navContext,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: botButtons
                          .map(
                            (btn) => ListTile(
                              leading: const Icon(Icons.arrow_right,
                                  color: Colors.green),
                              title: Text(btn.title),
                              onTap: () {
                                Navigator.pop(context);
                                if (onButtonTap != null) onButtonTap!(btn);
                              },
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _optionButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black38),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.menu, color: Colors.green, size: 18),
              const SizedBox(width: 6),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
