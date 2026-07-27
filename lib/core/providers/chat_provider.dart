import 'package:flutter/material.dart';
import '../services/groq_ai_service.dart';
import '../services/local_storage_service.dart';

class ChatProvider extends ChangeNotifier {
  final GroqApiService _groqService = GroqApiService();
  final LocalStorageService _storage = LocalStorageService();

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  bool _hasContext = false;

  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  bool get hasContext => _hasContext;

  ChatProvider() {
    _loadChatHistory();
  }

  void _loadChatHistory() {
    final history = _storage.getObject('chat_history');
    if (history != null && history is List) {
      _messages = history.cast<Map<String, dynamic>>();
      if (_messages.isNotEmpty) _hasContext = true;
      notifyListeners();
    }
  }

  Future<void> _saveChatHistory() async {
    await _storage.setObject('chat_history', _messages);
  }

  void setTyping(bool isTyping) {
    _isTyping = isTyping;
    notifyListeners();
  }

  void clearContext() {
    _hasContext = false;
    _messages.removeWhere((msg) => msg['isContext'] == true);
    _saveChatHistory();
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;

    // Add user message
    _messages.add({
      'content': text,
      'isUser': true,
      'timestamp': DateTime.now().toIso8601String(),
      'isError': false,
    });

    _isLoading = true;
    notifyListeners();
    await _saveChatHistory();

    try {
      // Build conversation history for context
      List<Map<String, String>> history = [];

      // Add last 5 messages for context (if any)
      if (_hasContext && _messages.length > 1) {
        final contextMessages = _messages.where((msg) => !msg.containsKey('isContext')).toList();
        final lastMessages = contextMessages.length > 10
            ? contextMessages.sublist(contextMessages.length - 10)
            : contextMessages;

        for (var msg in lastMessages) {
          if (msg['isUser'] == true) {
            history.add({'role': 'user', 'content': msg['content']});
          } else {
            history.add({'role': 'assistant', 'content': msg['content']});
          }
        }
      }

      // Get AI response
      final response = await _groqService.getChatResponse(
        text,
        history: history,
      );

      // Add AI response
      _messages.add({
        'content': response,
        'isUser': false,
        'timestamp': DateTime.now().toIso8601String(),
        'isError': false,
      });

      // Enable context after first exchange
      if (!_hasContext) {
        _hasContext = true;
      }

    } on GroqApiException catch (e) {
      _messages.add({
        'content': 'Error: ${e.message}',
        'isUser': false,
        'timestamp': DateTime.now().toIso8601String(),
        'isError': true,
      });
    } catch (e) {
      _messages.add({
        'content': 'An unexpected error occurred. Please try again.',
        'isUser': false,
        'timestamp': DateTime.now().toIso8601String(),
        'isError': true,
      });
    } finally {
      _isLoading = false;
      await _saveChatHistory();
      notifyListeners();
    }
  }

  Future<void> attachFile(dynamic file) async {
    // Process file content and add to context
    final content = await _groqService.processFile(file);

    _messages.add({
      'content': '📎 [File attached] $content',
      'isUser': true,
      'timestamp': DateTime.now().toIso8601String(),
      'isContext': true,
      'file': true,
    });

    _hasContext = true;
    await _saveChatHistory();
    notifyListeners();
  }

  Future<String> startVoiceRecording() async {
    // Implement voice recording
    // This would use speech_to_text package
    // Return transcribed text
    return 'Voice recording placeholder';
  }

  void stopVoiceRecording() {
    // Stop recording
  }

  void clearChat() {
    _messages.clear();
    _hasContext = false;
    _saveChatHistory();
    notifyListeners();
  }
}