import 'dart:io';
import 'package:flutter/material.dart';
import '../services/groq_ai_service.dart';
import '../services/firebase_service.dart';
import '../services/local_storage_service.dart';
import '../models/upload_model.dart';

class ChatProvider extends ChangeNotifier {
  final GroqApiService _groqService = GroqApiService();
  final FirebaseService _firebaseService = FirebaseService();
  final LocalStorageService _storage = LocalStorageService();

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  bool _hasContext = false;
  String? _error;
  List<UploadModel> _attachedFiles = [];

  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  bool get hasContext => _hasContext;
  String? get error => _error;
  List<UploadModel> get attachedFiles => _attachedFiles;

  ChatProvider() {
    _loadChatHistory();
  }

  // ============ LOAD CHAT HISTORY ============

  Future<void> _loadChatHistory() async {
    try {
      final user = _firebaseService.currentUser;
      if (user != null) {
        final history = await _firebaseService.getChatHistory(user.uid).first;
        if (history.docs.isNotEmpty) {
          _messages = history.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList()
              .reversed
              .toList();
          if (_messages.isNotEmpty) _hasContext = true;
          notifyListeners();
        }
      } else {
        // Fallback to local storage
        final history = _storage.getObject('chat_history');
        if (history != null && history is List) {
          _messages = history.cast<Map<String, dynamic>>();
          if (_messages.isNotEmpty) _hasContext = true;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error loading chat history: $e');
      // Fallback to local storage
      final history = _storage.getObject('chat_history');
      if (history != null && history is List) {
        _messages = history.cast<Map<String, dynamic>>();
        if (_messages.isNotEmpty) _hasContext = true;
        notifyListeners();
      }
    }
  }

  Future<void> _saveChatHistory() async {
    try {
      final user = _firebaseService.currentUser;
      if (user != null) {
        // Save last 50 messages to Firebase
        final lastMessages = _messages.length > 50
            ? _messages.sublist(_messages.length - 50)
            : _messages;
        for (var msg in lastMessages) {
          await _firebaseService.saveChatMessage(user.uid, msg);
        }
      }
      // Also save locally
      await _storage.setObject('chat_history', _messages);
    } catch (e) {
      print('Error saving chat history: $e');
      await _storage.setObject('chat_history', _messages);
    }
  }

  // ============ SEND MESSAGE ============

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    // Add user message
    final userMessage = {
      'content': text,
      'isUser': true,
      'timestamp': DateTime.now().toIso8601String(),
      'isError': false,
    };
    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();
    await _saveChatHistory();

    try {
      // Build conversation history for context
      List<Map<String, String>> history = [];

      if (_hasContext && _messages.length > 1) {
        final contextMessages = _messages
            .where((msg) => !(msg['isContext'] ?? false))
            .toList();
        final lastMessages = contextMessages.length > 10
            ? contextMessages.sublist(contextMessages.length - 10)
            : contextMessages;

        for (var msg in lastMessages) {
          if (msg['isUser'] == true) {
            history.add({'role': 'user', 'content': msg['content']});
          } else if (!(msg['isError'] ?? false)) {
            history.add({'role': 'assistant', 'content': msg['content']});
          }
        }
      }

      // Prepare message with attached files context
      String messageText = text;
      if (_attachedFiles.isNotEmpty) {
        messageText += '\n\n📎 Attached Files:\n';
        for (var file in _attachedFiles) {
          messageText += '• ${file.fileName}: ${file.url}\n';
        }
        _attachedFiles.clear();
      }

      // Get AI response
      final response = await _groqService.getChatResponse(
        messageText,
        history: history.isNotEmpty ? history : null,
      );

      // Add AI response
      final aiMessage = {
        'content': response,
        'isUser': false,
        'timestamp': DateTime.now().toIso8601String(),
        'isError': false,
      };
      _messages.add(aiMessage);

      if (!_hasContext) {
        _hasContext = true;
      }

      _isLoading = false;
      notifyListeners();
      await _saveChatHistory();

    } on GroqApiException catch (e) {
      _isLoading = false;
      final errorMessage = {
        'content': 'Error: ${e.message}',
        'isUser': false,
        'timestamp': DateTime.now().toIso8601String(),
        'isError': true,
      };
      _messages.add(errorMessage);
      notifyListeners();
      await _saveChatHistory();
    } catch (e) {
      _isLoading = false;
      final errorMessage = {
        'content': 'An unexpected error occurred. Please try again.',
        'isUser': false,
        'timestamp': DateTime.now().toIso8601String(),
        'isError': true,
      };
      _messages.add(errorMessage);
      notifyListeners();
      await _saveChatHistory();
    }
  }

  // ============ FILE ATTACHMENT ============

  void attachFile(UploadModel file) {
    _attachedFiles.add(file);
    notifyListeners();
  }

  void removeAttachedFile(String fileId) {
    _attachedFiles.removeWhere((file) => file.id == fileId);
    notifyListeners();
  }

  void clearAttachedFiles() {
    _attachedFiles.clear();
    notifyListeners();
  }

  Future<void> attachFileWithMessage(UploadModel file) async {
    attachFile(file);
    await sendMessage('📎 I uploaded a file: ${file.fileName}');
  }

  // ============ VOICE RECORDING ============

  Future<String> startVoiceRecording() async {
    // TODO: Implement actual voice recording with speech_to_text
    await Future.delayed(const Duration(seconds: 2));
    return 'Voice recording placeholder text';
  }

  void stopVoiceRecording() {
    // TODO: Implement stop recording
  }

  // ============ CHAT MANAGEMENT ============

  void setTyping(bool typing) {
    _isTyping = typing;
    notifyListeners();
  }

  void clearContext() {
    _hasContext = false;
    _messages.removeWhere((msg) => msg['isContext'] == true);
    _saveChatHistory();
    notifyListeners();
  }

  void clearChat() async {
    _messages.clear();
    _hasContext = false;
    _attachedFiles.clear();
    notifyListeners();
    await _saveChatHistory();

    final user = _firebaseService.currentUser;
    if (user != null) {
      await _firebaseService.deleteAllChatHistory(user.uid);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}