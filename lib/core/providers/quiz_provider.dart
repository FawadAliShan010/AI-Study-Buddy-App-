import 'package:flutter/material.dart';
import '../services/groq_ai_service.dart';
import '../services/firebase_service.dart';
import '../services/local_storage_service.dart';

class QuizProvider extends ChangeNotifier {
  final GroqAIService _aiService = GroqAIService();
  final FirebaseService _firebaseService = FirebaseService();
  final LocalStorageService _storage = LocalStorageService();

  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = false;
  bool _isQuizComplete = false;
  Map<int, String> _userAnswers = {};
  Map<int, bool> _answerResults = {};

  List<Map<String, dynamic>> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  bool get isLoading => _isLoading;
  bool get isQuizComplete => _isQuizComplete;
  Map<int, String> get userAnswers => _userAnswers;
  Map<int, bool> get answerResults => _answerResults;
  int get totalQuestions => _questions.length;
  double get progress => _questions.isEmpty ? 0 : _currentQuestionIndex / _questions.length;

  Future<void> generateQuiz(String topic, int numberOfQuestions) async {
    _setLoading(true);
    _resetQuiz();

    try {
      _questions = await _aiService.generateQuizQuestions(topic, numberOfQuestions);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to generate quiz: $e');
    } finally {
      _setLoading(false);
    }
  }

  void answerQuestion(String answer) {
    if (_isQuizComplete || _currentQuestionIndex >= _questions.length) return;

    final question = _questions[_currentQuestionIndex];
    final isCorrect = answer == question['correctAnswer'];

    _userAnswers[_currentQuestionIndex] = answer;
    _answerResults[_currentQuestionIndex] = isCorrect;

    if (isCorrect) {
      _score++;
    }

    if (_currentQuestionIndex == _questions.length - 1) {
      _isQuizComplete = true;
      _saveQuizResult();
    } else {
      _currentQuestionIndex++;
    }

    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  Future<void> _saveQuizResult() async {
    final userId = _firebaseService.currentUser?.uid;
    if (userId != null) {
      try {
        await _firebaseService.saveQuizResult(userId, {
          'score': _score,
          'totalQuestions': _questions.length,
          'percentage': (_score / _questions.length * 100).round(),
          'questions': _questions,
          'userAnswers': _userAnswers,
          'timestamp': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        print('Failed to save quiz result: $e');
      }
    }
  }

  void _resetQuiz() {
    _questions = [];
    _currentQuestionIndex = 0;
    _score = 0;
    _isQuizComplete = false;
    _userAnswers = {};
    _answerResults = {};
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void restartQuiz() {
    _currentQuestionIndex = 0;
    _score = 0;
    _isQuizComplete = false;
    _userAnswers = {};
    _answerResults = {};
    notifyListeners();
  }

  Map<String, dynamic> getResults() {
    final total = _questions.length;
    final correct = _score;
    final percentage = total > 0 ? (correct / total * 100).round() : 0;

    return {
      'totalQuestions': total,
      'correctAnswers': correct,
      'wrongAnswers': total - correct,
      'percentage': percentage,
      'passed': percentage >= 70,
      'questions': _questions.map((q) => {
        ...q,
        'userAnswer': _userAnswers[_questions.indexOf(q)],
        'isCorrect': _answerResults[_questions.indexOf(q)] ?? false,
      }).toList(),
    };
  }
}