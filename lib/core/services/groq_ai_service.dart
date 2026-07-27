import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GroqApiException implements Exception {
  final String message;
  final int? statusCode;

  GroqApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'GroqApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class GroqApiService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  static const String _model = 'llama-3.3-70b-versatile';

  // In production, get this from secure storage or environment variables
  static String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  final http.Client _client = http.Client();

  Future<String> getChatResponse(
      String message, {
        List<Map<String, String>>? history,
        double temperature = 0.7,
        int maxTokens = 1024,
      }) async {
    try {
      // Build messages list with history
      final List<Map<String, String>> messages = [];

      // System prompt
      messages.add({
        'role': 'system',
        'content': 'You are an AI study assistant. Help students with their academic questions. Provide clear, accurate, and helpful explanations. If you don\'t know something, say so. Use examples when helpful.',
      });

      // Add history
      if (history != null && history.isNotEmpty) {
        messages.addAll(history);
      }

      // Add current message
      messages.add({
        'role': 'user',
        'content': message,
      });

      final request = {
        'model': _model,
        'messages': messages,
        'temperature': temperature,
        'max_tokens': maxTokens,
        'top_p': 1,
        'stream': false,
      };

      final response = await _client.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode(request),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        final error = json.decode(response.body);
        final errorMessage = error['error']['message'] ?? 'Unknown error occurred';
        throw GroqApiException(errorMessage, response.statusCode);
      }
    } catch (e) {
      if (e is GroqApiException) rethrow;
      throw GroqApiException('Network error: ${e.toString()}');
    }
  }

  Future<String> processFile(dynamic file) async {
    // Process different file types
    // This is a placeholder - implement actual file processing
    return 'File processed: ${file.runtimeType}';
  }

  Future<String> summarizeText(String text) async {
    try {
      final response = await getChatResponse(
        'Please summarize the following text concisely:\n\n$text',
        temperature: 0.3,
        maxTokens: 500,
      );
      return response;
    } catch (e) {
      throw GroqApiException('Failed to summarize: ${e.toString()}');
    }
  }

  Future<String> generateQuiz(String topic, int numberOfQuestions) async {
    try {
      final response = await getChatResponse(
        'Generate a $numberOfQuestions-question quiz about "$topic". '
            'Format each question as: Q: [question]\nA: [correct answer]\nOptions: [option1, option2, option3, option4]\n\n'
            'Make it educational and challenging.',
        temperature: 0.8,
        maxTokens: 1500,
      );
      return response;
    } catch (e) {
      throw GroqApiException('Failed to generate quiz: ${e.toString()}');
    }
  }

  Future<String> getStudyTips(String subject) async {
    try {
      final response = await getChatResponse(
        'Provide 5 effective study tips for learning "$subject". '
            'Make them specific, actionable, and research-based.',
        temperature: 0.6,
        maxTokens: 800,
      );
      return response;
    } catch (e) {
      throw GroqApiException('Failed to get study tips: ${e.toString()}');
    }
  }

  Future<String> answerQuestion(String question, {String? context}) async {
    try {
      final fullContext = context != null
          ? 'Context: $context\n\nQuestion: $question'
          : question;

      final response = await getChatResponse(
        fullContext,
        temperature: 0.5,
        maxTokens: 1000,
      );
      return response;
    } catch (e) {
      throw GroqApiException('Failed to answer question: ${e.toString()}');
    }
  }

  void dispose() {
    _client.close();
  }
}