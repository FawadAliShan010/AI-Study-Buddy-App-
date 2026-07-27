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

  // ✅ UPDATED: Generate quiz with proper JSON format
  Future<String> generateQuiz(String topic, int numberOfQuestions) async {
    try {
      final prompt = '''
Generate $numberOfQuestions multiple-choice quiz questions about "$topic".

Return ONLY a valid JSON array with this exact format. No other text or markdown:

[
  {
    "question": "What is the question?",
    "options": ["A. Option 1", "B. Option 2", "C. Option 3", "D. Option 4"],
    "correctAnswer": "A. Option 1",
    "explanation": "Brief explanation of why this is correct",
    "topic": "$topic"
  }
]

Requirements:
- Each question must have exactly 4 options
- Options should be labeled A, B, C, D
- The correctAnswer must exactly match one of the options
- Make questions educational and appropriately challenging
- Ensure the JSON is valid and properly formatted
- Do not include any text outside the JSON array
''';

      final response = await getChatResponse(
        prompt,
        temperature: 0.7,
        maxTokens: 2000,
      );

      // Clean the response to ensure it's valid JSON
      String cleanedResponse = response.trim();

      // Remove markdown code blocks if present
      if (cleanedResponse.contains('```json')) {
        cleanedResponse = cleanedResponse.split('```json')[1].split('```')[0].trim();
      } else if (cleanedResponse.contains('```')) {
        cleanedResponse = cleanedResponse.split('```')[1].split('```')[0].trim();
      }

      // Validate JSON before returning
      try {
        final List<dynamic> parsed = jsonDecode(cleanedResponse);
        if (parsed.isEmpty) {
          throw Exception('Generated quiz is empty');
        }
        return cleanedResponse;
      } catch (e) {
        // If parsing fails, try to extract JSON from the response
        final startIndex = cleanedResponse.indexOf('[');
        final endIndex = cleanedResponse.lastIndexOf(']');
        if (startIndex != -1 && endIndex != -1 && startIndex < endIndex) {
          final extractedJson = cleanedResponse.substring(startIndex, endIndex + 1);
          try {
            jsonDecode(extractedJson);
            return extractedJson;
          } catch (e2) {
            throw Exception('Failed to parse JSON: $e2\nRaw response: $response');
          }
        }
        throw Exception('No valid JSON found in response: $response');
      }
    } catch (e) {
      if (e is GroqApiException) rethrow;
      throw GroqApiException('Failed to generate quiz: ${e.toString()}');
    }
  }

  // ✅ NEW: Generate quiz and return parsed List directly
  Future<List<Map<String, dynamic>>> generateQuizParsed(
      String topic,
      int numberOfQuestions
      ) async {
    final jsonString = await generateQuiz(topic, numberOfQuestions);
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((q) => Map<String, dynamic>.from(q)).toList();
    } catch (e) {
      throw GroqApiException('Failed to parse quiz JSON: ${e.toString()}');
    }
  }

  // ✅ NEW: Generate quiz with fallback questions if API fails
  Future<List<Map<String, dynamic>>> generateQuizWithFallback(
      String topic,
      int numberOfQuestions
      ) async {
    try {
      return await generateQuizParsed(topic, numberOfQuestions);
    } catch (e) {
      // Return fallback questions if API fails
      return _getFallbackQuestions(topic, numberOfQuestions);
    }
  }

  // ✅ NEW: Fallback questions for when API is unavailable
  List<Map<String, dynamic>> _getFallbackQuestions(String topic, int count) {
    final List<Map<String, dynamic>> questions = [];

    final fallbackTopics = {
      'mathematics': [
        {
          'question': 'What is 7 × 8?',
          'options': ['A. 48', 'B. 54', 'C. 56', 'D. 64'],
          'correctAnswer': 'C. 56',
          'explanation': '7 × 8 = 56. You can remember this as 7 times 8 equals 56.',
        },
        {
          'question': 'What is the square root of 144?',
          'options': ['A. 10', 'B. 11', 'C. 12', 'D. 13'],
          'correctAnswer': 'C. 12',
          'explanation': '12 × 12 = 144, so the square root of 144 is 12.',
        },
      ],
      'science': [
        {
          'question': 'What is the chemical symbol for water?',
          'options': ['A. H2O', 'B. CO2', 'C. NaCl', 'D. HCl'],
          'correctAnswer': 'A. H2O',
          'explanation': 'Water is H2O - two hydrogen atoms and one oxygen atom.',
        },
        {
          'question': 'What planet is known as the Red Planet?',
          'options': ['A. Venus', 'B. Mars', 'C. Jupiter', 'D. Saturn'],
          'correctAnswer': 'B. Mars',
          'explanation': 'Mars is called the Red Planet because of its reddish appearance due to iron oxide.',
        },
      ],
      'history': [
        {
          'question': 'In what year did World War II end?',
          'options': ['A. 1943', 'B. 1944', 'C. 1945', 'D. 1946'],
          'correctAnswer': 'C. 1945',
          'explanation': 'World War II ended in 1945 with the surrender of Germany and Japan.',
        },
      ],
      'computer science': [
        {
          'question': 'What does CPU stand for?',
          'options': ['A. Central Processing Unit', 'B. Computer Personal Unit', 'C. Central Program Utility', 'D. Control Processing Unit'],
          'correctAnswer': 'A. Central Processing Unit',
          'explanation': 'CPU stands for Central Processing Unit, the primary component of a computer.',
        },
        {
          'question': 'What is an algorithm?',
          'options': ['A. A type of computer', 'B. A step-by-step procedure for solving a problem', 'C. A programming language', 'D. A type of data structure'],
          'correctAnswer': 'B. A step-by-step procedure for solving a problem',
          'explanation': 'An algorithm is a set of step-by-step instructions for solving a problem.',
        },
      ],
    };

    final topicLower = topic.toLowerCase();
    List<Map<String, dynamic>> availableQuestions = [];

    for (final key in fallbackTopics.keys) {
      if (topicLower.contains(key)) {
        availableQuestions.addAll(fallbackTopics[key]!);
      }
    }

    // If no matching topics, use general questions
    if (availableQuestions.isEmpty) {
      availableQuestions = [
        {
          'question': 'What is the capital of France?',
          'options': ['A. London', 'B. Berlin', 'C. Paris', 'D. Madrid'],
          'correctAnswer': 'C. Paris',
          'explanation': 'Paris is the capital and largest city of France.',
        },
        {
          'question': 'What is the largest ocean on Earth?',
          'options': ['A. Atlantic Ocean', 'B. Indian Ocean', 'C. Pacific Ocean', 'D. Arctic Ocean'],
          'correctAnswer': 'C. Pacific Ocean',
          'explanation': 'The Pacific Ocean is the largest ocean, covering about 30% of the Earth\'s surface.',
        },
        {
          'question': 'What is the speed of light approximately?',
          'options': ['A. 300,000 km/s', 'B. 150,000 km/s', 'C. 500,000 km/s', 'D. 100,000 km/s'],
          'correctAnswer': 'A. 300,000 km/s',
          'explanation': 'The speed of light is approximately 300,000 kilometers per second.',
        },
      ];
    }

    // Select the required number of questions
    final shuffled = List<Map<String, dynamic>>.from(availableQuestions)..shuffle();
    final selected = shuffled.take(count.clamp(1, shuffled.length)).toList();

    // Add topic to each question
    return selected.map((q) {
      q['topic'] = topic;
      return q;
    }).toList();
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