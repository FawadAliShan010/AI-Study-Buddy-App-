import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class FileAttachmentDialog extends StatelessWidget {
  final Function(dynamic file) onFileSelected;

  const FileAttachmentDialog({
    super.key,
    required this.onFileSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Attach File',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAttachmentOption(
                icon: Icons.image_rounded,
                label: 'Image',
                onTap: () => onFileSelected('image'),
              ),
              _buildAttachmentOption(
                icon: Icons.picture_as_pdf_rounded,
                label: 'PDF',
                onTap: () => onFileSelected('pdf'),
              ),
              _buildAttachmentOption(
                icon: Icons.description_rounded,
                label: 'Document',
                onTap: () => onFileSelected('document'),
              ),
              _buildAttachmentOption(
                icon: Icons.link_rounded,
                label: 'Link',
                onTap: () => onFileSelected('link'),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}