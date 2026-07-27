import 'dart:convert';
import 'package:flutter/material.dart';

import '../services/groq_ai_service.dart';


class QuizProvider extends ChangeNotifier {
  final GroqApiService _aiService = GroqApiService();

  List<Map<String, dynamic>> _currentQuizQuestions = [];
  List<int> _userAnswers = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = false;
  bool _isQuizCompleted = false;
  int _totalQuestions = 0;

  List<Map<String, dynamic>> _quizzes = [];

  // Getters
  List<Map<String, dynamic>> get currentQuizQuestions => _currentQuizQuestions;
  List<int> get userAnswers => _userAnswers;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  bool get isLoading => _isLoading;
  bool get isQuizCompleted => _isQuizCompleted;
  int get totalQuestions => _totalQuestions;
  List<Map<String, dynamic>> get quizzes => _quizzes;

  // Study stats getters for HomeScreen
  int get studyTime => _calculateStudyTime();
  int get quizzesCompleted => _quizzes.where((q) => q['completed'] == true).length;
  int get notesCreated => 0;
  int get streak => _calculateStreak();

  QuizProvider() {
    loadDemoData();
  }

  int _calculateStudyTime() {
    int totalTime = 0;
    for (var quiz in _quizzes) {
      if (quiz['completed'] == true && quiz['timeSpent'] != null) {
        totalTime += quiz['timeSpent'] as int;
      }
    }
    return totalTime;
  }

  int _calculateStreak() {
    if (_quizzes.isEmpty) return 0;

    final completedQuizzes = _quizzes
        .where((q) => q['completed'] == true)
        .toList()
      ..sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

    if (completedQuizzes.isEmpty) return 0;

    final now = DateTime.now();
    final lastQuizDate = DateTime.parse(completedQuizzes.first['date']);
    final difference = now.difference(lastQuizDate).inDays;

    if (difference > 1) return 0;

    int streak = 0;
    for (int i = 0; i < completedQuizzes.length - 1; i++) {
      final current = DateTime.parse(completedQuizzes[i]['date']);
      final next = DateTime.parse(completedQuizzes[i + 1]['date']);
      if (current.difference(next).inDays <= 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak + 1;
  }

  Map<String, dynamic> getQuizStatistics() {
    final completedQuizzes = _quizzes.where((q) => q['completed'] == true).toList();

    if (completedQuizzes.isEmpty) {
      return {
        'totalQuizzes': 0,
        'averageScore': 0.0,
        'bestTopic': null,
        'totalQuestions': 0,
        'correctAnswers': 0,
      };
    }

    int totalScore = 0;
    Map<String, int> topicScores = {};
    int totalQuestions = 0;
    int correctAnswers = 0;

    for (var quiz in completedQuizzes) {
      final percentage = quiz['percentage'] as int? ?? 0;
      totalScore += percentage;

      final topic = quiz['topic'] as String? ?? 'Unknown';
      topicScores[topic] = (topicScores[topic] ?? 0) + percentage;

      totalQuestions += quiz['totalQuestions'] as int? ?? 0;
      correctAnswers += quiz['correctAnswers'] as int? ?? 0;
    }

    String? bestTopic;
    int bestScore = 0;
    topicScores.forEach((topic, score) {
      if (score > bestScore) {
        bestScore = score;
        bestTopic = topic;
      }
    });

    return {
      'totalQuizzes': completedQuizzes.length,
      'averageScore': totalScore / completedQuizzes.length,
      'bestTopic': bestTopic,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
    };
  }

  // ✅ FIXED: generateQuiz method with proper type handling
  Future<void> generateQuiz(String topic, int questionCount) async {
    _isLoading = true;
    _isQuizCompleted = false;
    _currentQuestionIndex = 0;
    _score = 0;
    _userAnswers = [];
    notifyListeners();

    try {
      // This returns a String (JSON)
      final response = await _aiService.generateQuiz(topic, questionCount);

      List<Map<String, dynamic>> parsedQuestions = [];

      // ✅ FIXED: Only check for String since that's what the service returns
      if (response is String) {
        try {
          String jsonString = response.trim();

          // Remove markdown code blocks
          if (jsonString.contains('```json')) {
            jsonString = jsonString.split('```json')[1].split('```')[0].trim();
          } else if (jsonString.contains('```')) {
            jsonString = jsonString.split('```')[1].split('```')[0].trim();
          }

          // Parse the JSON string
          final List<dynamic> decoded = jsonDecode(jsonString);
          parsedQuestions = decoded.map((q) => Map<String, dynamic>.from(q)).toList();

        } catch (e) {
          throw Exception('Failed to parse JSON response: $e\nRaw response: $response');
        }
      } else {
        throw Exception('Unexpected response type: ${response.runtimeType}');
      }

      if (parsedQuestions.isEmpty) {
        throw Exception('No questions generated. Please try again.');
      }

      _currentQuizQuestions = parsedQuestions;
      _totalQuestions = parsedQuestions.length;

      // Add quiz to history with pending status
      _quizzes.add({
        'topic': topic,
        'totalQuestions': questionCount,
        'correctAnswers': 0,
        'percentage': 0,
        'date': DateTime.now().toIso8601String(),
        'completed': false,
        'timeSpent': 0,
      });

    } catch (e) {
      // Clean up if generation fails
      _currentQuizQuestions = [];
      _totalQuestions = 0;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ SIMPLER VERSION: Use the service's parsed method directly
  Future<void> generateQuizSimple(String topic, int questionCount) async {
    _isLoading = true;
    _isQuizCompleted = false;
    _currentQuestionIndex = 0;
    _score = 0;
    _userAnswers = [];
    notifyListeners();

    try {
      // This returns parsed List directly
      final parsedQuestions = await _aiService.generateQuizWithFallback(
        topic,
        questionCount,
      );

      if (parsedQuestions.isEmpty) {
        throw Exception('No questions generated. Please try again.');
      }

      _currentQuizQuestions = parsedQuestions;
      _totalQuestions = parsedQuestions.length;

      _quizzes.add({
        'topic': topic,
        'totalQuestions': questionCount,
        'correctAnswers': 0,
        'percentage': 0,
        'date': DateTime.now().toIso8601String(),
        'completed': false,
        'timeSpent': 0,
      });

    } catch (e) {
      _currentQuizQuestions = [];
      _totalQuestions = 0;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectAnswer(int selectedIndex) {
    if (_currentQuestionIndex >= _currentQuizQuestions.length) return;

    final question = _currentQuizQuestions[_currentQuestionIndex];
    final options = question['options'] as List;
    final correctAnswer = question['correctAnswer'] as String;

    final selectedAnswer = options[selectedIndex] as String;
    final isCorrect = selectedAnswer == correctAnswer;

    _userAnswers.add(selectedIndex);
    if (isCorrect) {
      _score++;
    }

    if (_userAnswers.length == _currentQuizQuestions.length) {
      _isQuizCompleted = true;
      _saveQuizResult();
    }

    notifyListeners();
  }

  void _saveQuizResult() {
    final totalQuestions = _currentQuizQuestions.length;
    final correctAnswers = _score;
    final percentage = totalQuestions > 0 ? (correctAnswers / totalQuestions * 100).round() : 0;

    final pendingIndex = _quizzes.indexWhere((q) => q['completed'] == false);
    if (pendingIndex != -1) {
      _quizzes[pendingIndex]['correctAnswers'] = correctAnswers;
      _quizzes[pendingIndex]['percentage'] = percentage;
      _quizzes[pendingIndex]['completed'] = true;
    }

    final quizResult = {
      'topic': _currentQuizQuestions.isNotEmpty
          ? _currentQuizQuestions.first['topic'] ?? 'Unknown Topic'
          : 'Unknown Topic',
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'percentage': percentage,
      'date': DateTime.now().toIso8601String(),
      'completed': true,
      'timeSpent': 0,
    };

    _quizzes.add(quizResult);
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _currentQuizQuestions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void retakeQuiz() {
    _currentQuestionIndex = 0;
    _score = 0;
    _userAnswers = [];
    _isQuizCompleted = false;
    notifyListeners();
  }

  void resetQuiz() {
    _currentQuizQuestions = [];
    _currentQuestionIndex = 0;
    _score = 0;
    _userAnswers = [];
    _isLoading = false;
    _isQuizCompleted = false;
    _totalQuestions = 0;
    notifyListeners();
  }

  Future<void> refreshStats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    notifyListeners();
  }

  // Load demo data for testing
  void loadDemoData() {
    _quizzes = [
      {
        'topic': 'Mathematics',
        'totalQuestions': 5,
        'correctAnswers': 4,
        'percentage': 80,
        'date': DateTime.now().subtract(const Duration(days: 0)).toIso8601String(),
        'completed': true,
        'timeSpent': 5,
      },
      {
        'topic': 'Science',
        'totalQuestions': 5,
        'correctAnswers': 3,
        'percentage': 60,
        'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'completed': true,
        'timeSpent': 4,
      },
      {
        'topic': 'History',
        'totalQuestions': 5,
        'correctAnswers': 5,
        'percentage': 100,
        'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'completed': true,
        'timeSpent': 6,
      },
    ];
    notifyListeners();
  }

  void clearHistory() {
    _quizzes.clear();
    notifyListeners();
  }

  int get totalQuizzesTaken => _quizzes.where((q) => q['completed'] == true).length;

  double get averageScore {
    final completed = _quizzes.where((q) => q['completed'] == true).toList();
    if (completed.isEmpty) return 0.0;
    int total = 0;
    for (var quiz in completed) {
      total += quiz['percentage'] as int? ?? 0;
    }
    return total / completed.length;
  }
}