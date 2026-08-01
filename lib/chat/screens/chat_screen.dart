import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/providers/upload_provider.dart';
import '../../../core/constants/app_constants.dart';

import '../../core/services/groq_ai_service.dart';
import '../widgets/file_attachment_dialogue.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/suggestion_chips.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isRecording = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final uploadProvider = Provider.of<UploadProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('AI Study Assistant'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Powered by Groq',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Show upload status
          if (uploadProvider.isUploading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Chat?'),
                  content: const Text('This will delete all chat history.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        chatProvider.clearChat();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Chat cleared'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatProvider.messages.isEmpty
                ? _buildEmptyState()
                : _buildChatList(chatProvider),
          ),
          if (chatProvider.isLoading) const TypingIndicator(),
          if (uploadProvider.error != null)
            _buildErrorBanner(uploadProvider),
          _buildInputBar(chatProvider, uploadProvider),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(UploadProvider uploadProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              uploadProvider.error!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: uploadProvider.clearError,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppGradients.secondaryGradient,
                shape: BoxShape.circle,
                boxShadow: AppShadows.glow,
              ),
              child: const Icon(
                Icons.chat_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInDown(
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Ask me anything about your studies',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInDown(
            delay: const Duration(milliseconds: 400),
            child: Text(
              'I can help with explanations, examples, and practice',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SuggestionChips(),
        ],
      ),
    );
  }

  Widget _buildChatList(ChatProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: provider.messages.length,
      itemBuilder: (context, index) {
        final message = provider.messages[index];
        final isLastMessage = index == provider.messages.length - 1;

        return FadeInUp(
          delay: Duration(milliseconds: isLastMessage ? 100 : 0),
          child: MessageBubble(
            message: message['content'],
            isUser: message['isUser'],
            timestamp: DateTime.parse(message['timestamp']),
            isError: message['isError'] ?? false,
          ),
        );
      },
    );
  }

  Widget _buildInputBar(ChatProvider chatProvider, UploadProvider uploadProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.8),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          // Upload progress bar
          if (uploadProvider.isUploading)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: uploadProvider.uploadProgress,
                    backgroundColor: Colors.grey.shade800,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Uploading... ${(uploadProvider.uploadProgress * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          // Context indicator
          if (chatProvider.hasContext)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.memory_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Using context from previous conversation',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => chatProvider.clearContext(),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _isRecording ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: _isRecording ? Colors.red : Colors.white70,
                ),
                onPressed: uploadProvider.isUploading
                    ? null
                    : () => _toggleVoiceRecording(chatProvider),
              ),
              IconButton(
                icon: const Icon(Icons.attach_file, color: Colors.white70),
                onPressed: uploadProvider.isUploading
                    ? null
                    : () => _showFileAttachmentDialog(chatProvider, uploadProvider),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  enabled: !uploadProvider.isUploading,
                  decoration: InputDecoration(
                    hintText: uploadProvider.isUploading
                        ? 'Uploading file...'
                        : 'Ask a question...',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onSubmitted: (value) => _sendMessage(chatProvider),
                  onChanged: (value) => chatProvider.setTyping(value.isNotEmpty),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  gradient: chatProvider.isLoading || uploadProvider.isUploading
                      ? null
                      : AppGradients.secondaryGradient,
                  color: chatProvider.isLoading || uploadProvider.isUploading
                      ? Colors.grey[800]
                      : null,
                  shape: BoxShape.circle,
                  boxShadow: chatProvider.isLoading || uploadProvider.isUploading
                      ? null
                      : AppShadows.glow,
                ),
                child: chatProvider.isLoading || uploadProvider.isUploading
                    ? const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
                    : IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                  onPressed: () => _sendMessage(chatProvider),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(ChatProvider provider) async {
    final text = _controller.text.trim();
    if (text.isEmpty || provider.isLoading) return;

    _controller.clear();
    provider.setTyping(false);

    try {
      await provider.sendMessage(text);
      _scrollToBottom();
    } on GroqApiException catch (e) {
      _showErrorSnackBar('API Error: ${e.message}');
    } catch (e) {
      _showErrorSnackBar('Failed to send message: $e');
    }
  }

  void _showFileAttachmentDialog(ChatProvider chatProvider, UploadProvider uploadProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FileAttachmentDialog(
        onFileSelected: (file) async {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            _showErrorSnackBar('Please login to upload files');
            return;
          }

          final success = await uploadProvider.uploadFile(
            file: file,
            userId: user.uid,
            fieldName: 'files',
          );

          if (success && mounted) {
            await chatProvider.sendMessage(
                '📎 I uploaded a file: ${file.path.split('/').last}'
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File uploaded successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            );
            Navigator.pop(context);
          } else if (mounted) {
            _showErrorSnackBar(uploadProvider.error ?? 'Upload failed');
          }
        },
      ),
    );
  }

  void _toggleVoiceRecording(ChatProvider provider) {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      provider.startVoiceRecording().then((text) {
        if (mounted) {
          setState(() => _isRecording = false);
          if (text.isNotEmpty) {
            _controller.text = text;
            _sendMessage(provider);
          }
        }
      }).catchError((e) {
        if (mounted) {
          setState(() => _isRecording = false);
          _showErrorSnackBar('Voice recording failed: $e');
        }
      });
    } else {
      provider.stopVoiceRecording();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppConstants.animationDuration,
          curve: Curves.easeOut,
        );
      }
    });
  }
}