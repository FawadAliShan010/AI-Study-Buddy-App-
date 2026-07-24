import 'package:flutter/material.dart';
import '../services/groq_ai_service.dart';
import '../services/firebase_service.dart';
import '../services/local_storage_service.dart';

class ChatProvider extends ChangeNotifier {
  final GroqAIService _aiService = GroqAIService();
  final FirebaseService _firebaseService = FirebaseService();
  final LocalStorageService _storage = LocalStorageService();

  List<Map<String, dynamic>> _messages = [];
  List<Map<String, String>> _history = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ChatProvider() {
    _loadChatHistory();
  }

  void _loadChatHistory() {
    final history = _storage.getObject('chat_history');
    if (history != null && history is List) {
      _messages = history.cast<Map<String, dynamic>>();
      _updateHistory();
    }
  }

  void _updateHistory() {
    _history = _messages.map<Map<String, String>>((msg) {
      return {
        'role': msg['isUser'] == true ? 'user' : 'assistant',
        'content': msg['content']?.toString() ?? '',
      };
    }).toList();
  }

  Future<void> sendMessage(String message) async {
    _setLoading(true);
    _error = null;

    // Add user message
    _messages.add({
      'content': message,
      'isUser': true,
      'timestamp': DateTime.now().toIso8601String(),
    });
    _updateHistory();
    notifyListeners();

    try {
      // Get AI response
      final response = await _aiService.getAIResponse(message, _history);

      // Add AI response
      _messages.add({
        'content': response,
        'isUser': false,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _updateHistory();
      notifyListeners();

      // Save to local storage
      await _storage.setObject('chat_history', _messages);

      // Save to Firebase if user is authenticated
      final userId = _firebaseService.currentUser?.uid;
      if (userId != null) {
        await _firebaseService.saveChatMessage(userId, {
          'message': message,
          'response': response,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      _error = e.toString();
      // Remove user message if AI fails
      if (_messages.isNotEmpty) {
        _messages.removeLast();
      }
      _updateHistory();
      notifyListeners();
      throw Exception('Failed to get AI response: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> regenerateResponse() async {
    if (_messages.isEmpty) return;

    // Remove last AI response if exists
    if (!_messages.last['isUser']) {
      _messages.removeLast();
      _updateHistory();
    }

    // Get the last user message
    final userMessage = _messages.lastWhere((msg) => msg['isUser'] == true);
    await sendMessage(userMessage['content']?.toString() ?? '');
  }

  void clearChat() {
    _messages.clear();
    _history.clear();
    _storage.remove('chat_history');
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  List<Map<String, dynamic>> getMessageHistory() {
    return _messages;
  }
}