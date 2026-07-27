import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/groq_ai_service.dart';
import '../services/local_storage_service.dart';

class QuizProvider extends ChangeNotifier {
  final GroqApiService _aiService = GroqApiService();
  final FirebaseService _firebaseService = FirebaseService();
  final LocalStorageService _storage = LocalStorageService();

  List<Map<String, dynamic>> _quizzes = [];
  List<Map<String, dynamic>> _currentQuizQuestions = [];
  List<String> _userAnswers = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = false;
  bool _isQuizCompleted = false;
  String? _currentTopic;
  int? _selectedAnswerIndex;
  bool _showAnswer = false;
  final Random _random = Random();

  // Getters
  List<Map<String, dynamic>> get quizzes => _quizzes;
  List<Map<String, dynamic>> get currentQuizQuestions => _currentQuizQuestions;
  List<String> get userAnswers => _userAnswers;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  bool get isLoading => _isLoading;
  bool get isQuizCompleted => _isQuizCompleted;
  String? get currentTopic => _currentTopic;
  int? get selectedAnswerIndex => _selectedAnswerIndex;
  bool get showAnswer => _showAnswer;
  int get totalQuestions => _currentQuizQuestions.length;
  double get progress => totalQuestions > 0 ? (_currentQuestionIndex / totalQuestions) : 0.0;

  QuizProvider() {
    _loadQuizzes();
  }

  void _loadQuizzes() {
    try {
      final savedQuizzes = _storage.getObject('quiz_history');
      if (savedQuizzes != null && savedQuizzes is List) {
        _quizzes = savedQuizzes.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      _quizzes = [];
    }
    notifyListeners();
  }

  Future<void> _saveQuizzes() async {
    try {
      await _storage.setObject('quiz_history', _quizzes);
    } catch (e) {
      // Failed to save quizzes
    }
  }

  Future<void> generateQuiz(String topic, int questionCount, {int numberOfQuestions = 5}) async {
    _setLoading(true);
    _currentTopic = topic;
    _score = 0;
    _currentQuestionIndex = 0;
    _isQuizCompleted = false;
    _selectedAnswerIndex = null;
    _showAnswer = false;
    _userAnswers = [];

    try {
      final response = await _aiService.generateQuiz(topic, numberOfQuestions);
      _currentQuizQuestions = _parseAndShuffleQuizResponse(response, numberOfQuestions);

      if (_currentQuizQuestions.isEmpty) {
        _currentQuizQuestions = _getFallbackQuestions(topic, numberOfQuestions);
      }

      // Shuffle the questions
      _currentQuizQuestions.shuffle(_random);

      _quizzes.add({
        'topic': topic,
        'questions': _currentQuizQuestions,
        'date': DateTime.now().toIso8601String(),
        'totalQuestions': _currentQuizQuestions.length,
        'score': 0,
        'completed': false,
      });
      await _saveQuizzes();

      notifyListeners();
    } catch (e) {
      _currentQuizQuestions = _getFallbackQuestions(topic, numberOfQuestions);
      _currentQuizQuestions.shuffle(_random);
      notifyListeners();
      throw Exception('Failed to generate quiz: $e');
    } finally {
      _setLoading(false);
    }
  }

  List<Map<String, dynamic>> _parseAndShuffleQuizResponse(String response, int expectedCount) {
    List<Map<String, dynamic>> questions = [];

    try {
      final lines = response.split('\n');
      Map<String, dynamic>? currentQuestion;

      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty) continue;

        if (line.startsWith('Q:')) {
          if (currentQuestion != null) {
            questions.add(currentQuestion);
          }
          currentQuestion = {
            'question': line.substring(2).trim(),
            'options': [],
            'correctAnswer': '',
          };
        } else if (line.startsWith('A:')) {
          if (currentQuestion != null) {
            currentQuestion['correctAnswer'] = line.substring(2).trim();
          }
        } else if (line.startsWith('Options:')) {
          if (currentQuestion != null) {
            final optionsStr = line.substring(8).trim();
            var options = optionsStr.split(',').map((o) => o.trim()).toList();

            // Shuffle options for each question
            options.shuffle(_random);
            currentQuestion['options'] = options;
          }
        }
      }

      if (currentQuestion != null) {
        questions.add(currentQuestion);
      }

      // Ensure correct answer is in options
      for (var question in questions) {
        final options = question['options'] as List;
        final correctAnswer = question['correctAnswer'] as String;

        // If correct answer not in options, add it
        if (!options.contains(correctAnswer)) {
          options.add(correctAnswer);
          options.shuffle(_random);
          question['options'] = options;
        }
      }

    } catch (e) {
      questions = [];
    }

    // Ensure we have the expected number of questions
    while (questions.length < expectedCount) {
      questions.add(_getFallbackQuestion('${_currentTopic ?? 'General'} ${questions.length + 1}'));
    }

    return questions.take(expectedCount).toList();
  }

  List<Map<String, dynamic>> _getFallbackQuestions(String topic, int count) {
    final questions = <Map<String, dynamic>>[];
    for (int i = 0; i < count; i++) {
      questions.add(_getFallbackQuestion('$topic ${i + 1}'));
    }
    return questions;
  }

  Map<String, dynamic> _getFallbackQuestion(String topic) {
    final options = [
      'Option A',
      'Option B',
      'Option C',
      'Option D'
    ];

    // Randomly select one option as correct
    final correctIndex = _random.nextInt(options.length);
    final correctAnswer = options[correctIndex];

    // Shuffle options
    options.shuffle(_random);

    return {
      'question': 'What is a key concept in $topic?',
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }

  void selectAnswer(int answerIndex) {
    if (_isQuizCompleted || _showAnswer) return;

    _selectedAnswerIndex = answerIndex;
    _showAnswer = true;

    final question = _currentQuizQuestions[_currentQuestionIndex];
    final options = question['options'] as List;
    final selectedOption = options[answerIndex];
    final correctAnswer = question['correctAnswer'] as String;
    final isCorrect = selectedOption == correctAnswer;

    // Store user answer
    if (_userAnswers.length <= _currentQuestionIndex) {
      _userAnswers.add(selectedOption);
    } else {
      _userAnswers[_currentQuestionIndex] = selectedOption;
    }

    if (isCorrect) {
      _score++;
    }

    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _currentQuizQuestions.length - 1) {
      _currentQuestionIndex++;
      _selectedAnswerIndex = null;
      _showAnswer = false;
      notifyListeners();
    } else {
      _completeQuiz();
    }
  }

  void _completeQuiz() {
    _isQuizCompleted = true;

    if (_quizzes.isNotEmpty) {
      final lastQuiz = _quizzes.last;
      lastQuiz['score'] = _score;
      lastQuiz['completed'] = true;
      lastQuiz['percentage'] = (_score / _currentQuizQuestions.length * 100).round();
      _saveQuizzes();
    }

    notifyListeners();
  }

  void retakeQuiz() {
    // Reshuffle questions for retake
    _currentQuizQuestions.shuffle(_random);
    // Reshuffle options for each question
    for (var question in _currentQuizQuestions) {
      final options = question['options'] as List;
      options.shuffle(_random);
      question['options'] = options;
    }

    _currentQuestionIndex = 0;
    _score = 0;
    _isQuizCompleted = false;
    _selectedAnswerIndex = null;
    _showAnswer = false;
    _userAnswers = [];
    notifyListeners();
  }

  void resetQuiz() {
    _currentQuizQuestions = [];
    _currentQuestionIndex = 0;
    _score = 0;
    _isQuizCompleted = false;
    _currentTopic = null;
    _selectedAnswerIndex = null;
    _showAnswer = false;
    _userAnswers = [];
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Save quiz result to Firebase
  Future<void> saveQuizResult(Map<String, dynamic> result, String userId) async {
    try {
      final data = Map<String, dynamic>.from(result);
      data.remove('userId');
      await _firebaseService.saveQuizResult(userId, data);
    } catch (e) {
      final localResults = _storage.getObject('local_quiz_results') ?? [];
      if (localResults is List) {
        localResults.add(result);
        await _storage.setObject('local_quiz_results', localResults);
      }
    }
  }

  // Get quiz history from Firebase
  Future<List<Map<String, dynamic>>> getQuizHistory(String userId) async {
    try {
      final List<Map<String, dynamic>> results = [];
      final snapshot = await _firebaseService
          .getQuizResults(userId)
          .first;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        results.add(data);
      }

      return results;
    } catch (e) {
      final localHistory = _storage.getObject('quiz_history');
      if (localHistory != null && localHistory is List) {
        return localHistory.cast<Map<String, dynamic>>();
      }
      return [];
    }
  }

  // Stream quiz history from Firebase
  Stream<List<Map<String, dynamic>>> streamQuizHistory(String userId) {
    try {
      return _firebaseService
          .getQuizResults(userId)
          .map((snapshot) {
        final List<Map<String, dynamic>> results = [];
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          results.add(data);
        }
        return results;
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  Map<String, dynamic> getQuizStatistics() {
    final completedQuizzes = _quizzes.where((q) => q['completed'] == true).toList();

    if (completedQuizzes.isEmpty) {
      return {
        'totalQuizzes': 0,
        'averageScore': 0.0,
        'bestTopic': '',
        'totalQuestions': 0,
        'correctAnswers': 0,
      };
    }

    final totalScore = completedQuizzes.fold(0, (sum, q) => sum + (q['score'] as int));
    final averageScore = totalScore / completedQuizzes.length;

    Map<String, int> topicScores = {};
    for (var quiz in completedQuizzes) {
      final topic = quiz['topic'] as String;
      final score = quiz['score'] as int;
      topicScores[topic] = (topicScores[topic] ?? 0) + score;
    }

    String bestTopic = '';
    int highestScore = 0;
    topicScores.forEach((topic, score) {
      if (score > highestScore) {
        highestScore = score;
        bestTopic = topic;
      }
    });

    final totalQuestions = completedQuizzes.fold(0, (sum, q) => sum + (q['totalQuestions'] as int));
    final correctAnswers = completedQuizzes.fold(0, (sum, q) => sum + (q['score'] as int));

    return {
      'totalQuizzes': completedQuizzes.length,
      'averageScore': averageScore,
      'bestTopic': bestTopic,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
    };
  }
}