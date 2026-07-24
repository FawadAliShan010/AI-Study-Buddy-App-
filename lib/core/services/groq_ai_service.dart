import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class GroqAIService {
  static final GroqAIService _instance = GroqAIService._internal();
  factory GroqAIService() => _instance;
  GroqAIService._internal();

  final String _apiKey = AppConstants.groqApiKey;
  final String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  Future<String> getAIResponse(
      String message,
      List<Map<String, String>> history,
      ) async {
    try {
      final messages = [
        {
          'role': 'system',
          'content':
          'You are an AI Study Buddy, a helpful and knowledgeable study assistant. '
              'You help students with their studies by providing clear explanations, '
              'examples, and guidance. You are patient, encouraging, and adaptive to '
              'the student\'s learning style. You can explain complex concepts simply, '
              'generate practice problems, and provide study tips. You specialize in '
              'making learning engaging and effective.'
        },
        ...history.map((msg) => {
          'role': msg['role'],
          'content': msg['content'],
        }),
        {'role': 'user', 'content': message},
      ];

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'mixtral-8x7b-32768',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1024,
          'top_p': 0.9,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('AI service failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('AI service error: $e');
    }
  }

  Future<String> summarizeText(String text) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'mixtral-8x7b-32768',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a summarization expert. Create a concise, well-structured summary of the provided text. Focus on key points and main ideas.'
            },
            {
              'role': 'user',
              'content': 'Summarize this text:\n\n$text'
            }
          ],
          'temperature': 0.3,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Summarization failed');
      }
    } catch (e) {
      throw Exception('Summarization error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> generateQuizQuestions(
      String topic,
      int numberOfQuestions,
      ) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'mixtral-8x7b-32768',
          'messages': [
            {
              'role': 'system',
              'content':
              'You are a quiz generator. Create multiple-choice questions based on the topic. '
                  'Return the response as a JSON array with each question having: '
                  'question, options (array of 4), correctAnswer, explanation.'
            },
            {
              'role': 'user',
              'content':
              'Generate $numberOfQuestions multiple-choice quiz questions about: $topic. '
                  'Make them progressively harder. Include a clear explanation for each answer.'
            }
          ],
          'temperature': 0.8,
          'max_tokens': 2000,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        // Try to parse JSON response
        try {
          return List<Map<String, dynamic>>.from(json.decode(content));
        } catch (e) {
          // If response is not JSON, parse as text and create structured format
          return _parseQuizQuestions(content);
        }
      } else {
        throw Exception('Quiz generation failed');
      }
    } catch (e) {
      throw Exception('Quiz generation error: $e');
    }
  }

  List<Map<String, dynamic>> _parseQuizQuestions(String text) {
    // Simple parser for text-based quiz responses
    // This is a fallback if AI doesn't return proper JSON
    final questions = <Map<String, dynamic>>[];
    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('Q')) {
        final question = lines[i].substring(2).trim();
        final options = <String>[];
        int j = i + 1;
        while (j < lines.length && lines[j].startsWith(' ')) {
          options.add(lines[j].trim());
          j++;
        }
        // Find answer and explanation
        String answer = '';
        String explanation = '';
        for (int k = j; k < lines.length; k++) {
          if (lines[k].contains('Answer:')) {
            answer = lines[k].substring(lines[k].indexOf(':') + 1).trim();
          }
          if (lines[k].contains('Explanation:')) {
            explanation = lines[k].substring(lines[k].indexOf(':') + 1).trim();
            break;
          }
        }
        if (question.isNotEmpty && options.length == 4) {
          questions.add({
            'question': question,
            'options': options,
            'correctAnswer': answer,
            'explanation': explanation,
          });
        }
        i = j - 1;
      }
    }
    return questions;
  }

  Future<String> getExplanation(String topic) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'mixtral-8x7b-32768',
          'messages': [
            {
              'role': 'system',
              'content':
              'You are a knowledgeable tutor. Provide a clear, engaging explanation '
                  'of the topic with examples and real-world applications.'
            },
            {
              'role': 'user',
              'content': 'Explain this topic in a way that is easy to understand, with examples: $topic'
            }
          ],
          'temperature': 0.6,
          'max_tokens': 800,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Explanation generation failed');
      }
    } catch (e) {
      throw Exception('Explanation error: $e');
    }
  }
}