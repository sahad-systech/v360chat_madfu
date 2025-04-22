import 'package:flutter/material.dart';

class ChatBottomSheet extends StatelessWidget {
  final VoidCallback onGalleryTap;
  final VoidCallback onCameraTap;
  final VoidCallback onDocumentTap;
  final VoidCallback onAudioTap;

  const ChatBottomSheet({
    super.key,
    required this.onGalleryTap,
    required this.onCameraTap,
    required this.onDocumentTap,
    required this.onAudioTap,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Container(
      height: media.height * 0.25,
      width: double.infinity,
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Container(
            height: media.height * 0.008,
            width: media.width * 0.2,
            margin: EdgeInsets.symmetric(vertical: media.height * 0.015),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CircleButton(
                icon: Icons.photo,
                label: 'Photos',
                onTap: onGalleryTap,
              ),
              _CircleButton(
                icon: Icons.camera_alt,
                label: 'Camera',
                onTap: onCameraTap,
              ),
              _CircleButton(
                icon: Icons.description,
                label: 'Document',
                onTap: onDocumentTap,
              ),
              _CircleButton(
                icon: Icons.audiotrack,
                label: 'Audio',
                onTap: onAudioTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Icon(icon, size: media.height * 0.035, color: Colors.black),
          ),
          SizedBox(height: media.height * 0.01),
          Text(
            label,
            style: TextStyle(
              fontSize: media.width * 0.035,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
