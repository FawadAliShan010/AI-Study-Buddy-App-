import 'package:ai_study_buddy/quiz/screens/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/quiz_provider.dart';
import 'quiz_result_screen.dart';

class QuizQuestionScreen extends StatefulWidget {
  const QuizQuestionScreen({super.key});

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  String? _selectedAnswer;
  bool _isAnswered = false;

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final questions = quizProvider.currentQuizQuestions;
    final currentIndex = quizProvider.currentQuestionIndex;

    // Check if questions exist
    if (questions.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const QuizScreen()),
          );
        }
      });
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0A0E17),
                const Color(0xFF1A1A2E),
                const Color(0xFF16213E),
                const Color(0xFF0F3460),
              ],
              stops: const [0.0, 0.3, 0.6, 1.0],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Loading questions...',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // If quiz is completed, show results
    if (quizProvider.isQuizCompleted) {
      return const QuizResultScreen();
    }

    // Ensure currentIndex is valid
    if (currentIndex >= questions.length) {
      return const QuizResultScreen();
    }

    final question = questions[currentIndex];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Question ${currentIndex + 1}/${questions.length}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Quiz Navigation Popup Button
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white70),
            color: const Color(0xFF1A1A2E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            onSelected: (value) {
              if (value == 'go_to_quiz') {
                _showGoToQuizDialog(context, quizProvider);
              } else if (value == 'reset_quiz') {
                _showResetQuizDialog(context, quizProvider);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'go_to_quiz',
                child: Row(
                  children: [
                    const Icon(
                      Icons.quiz_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Go to Quiz Home',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'reset_quiz',
                child: Row(
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Reset Quiz',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'quit_quiz',
                child: Row(
                  children: [
                    const Icon(
                      Icons.exit_to_app_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Quit Quiz',
                      style: GoogleFonts.inter(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Score display
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Text(
                  '${quizProvider.score}',
                  style: GoogleFonts.orbitron(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A0E17),
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
              const Color(0xFF0F3460),
            ],
            stops: const [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInDown(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppGradients.secondaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Question ${currentIndex + 1}',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInDown(
                      delay: const Duration(milliseconds: 100),
                      child: Text(
                        question['question'] ?? 'No question available',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...List.generate(
                      (question['options'] as List?)?.length ?? 0,
                          (index) => FadeInUp(
                        delay: Duration(milliseconds: 200 + index * 100),
                        child: _buildOption(
                          index,
                          question['options'][index],
                          quizProvider,
                        ),
                      ),
                    ),
                    if (_isAnswered && question['explanation'] != null) ...[
                      const SizedBox(height: 24),
                      FadeInUp(
                        child: _buildExplanation(question['explanation']),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _buildBottomBar(quizProvider),
          ],
        ),
      ),
    );
  }

  void _showGoToQuizDialog(BuildContext context, QuizProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        title: Text(
          'Go to Quiz Home?',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Your current progress will be lost if you leave now.',
          style: GoogleFonts.inter(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: Colors.white54,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Reset quiz and navigate to quiz screen
              provider.resetQuiz();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuizScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Go to Quiz',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetQuizDialog(BuildContext context, QuizProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        title: Text(
          'Reset Quiz?',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will reset your progress on the current quiz. Are you sure?',
          style: GoogleFonts.inter(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: Colors.white54,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              provider.retakeQuiz();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Quiz has been reset. Starting over!'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
              setState(() {
                _selectedAnswer = null;
                _isAnswered = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Reset',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(int index, String option, QuizProvider provider) {
    final isSelected = _selectedAnswer == option;
    final isCorrect = _isAnswered && option == provider.currentQuizQuestions[provider.currentQuestionIndex]['correctAnswer'];
    final isWrong = _isAnswered && isSelected && !isCorrect;

    Color? backgroundColor;
    Color? borderColor;

    if (_isAnswered) {
      if (isCorrect) {
        backgroundColor = Colors.green.withOpacity(0.2);
        borderColor = Colors.green;
      } else if (isWrong) {
        backgroundColor = Colors.red.withOpacity(0.2);
        borderColor = Colors.red;
      }
    } else if (isSelected) {
      backgroundColor = AppColors.primary.withOpacity(0.2);
      borderColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: _isAnswered ? null : () => _selectOption(option, provider),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          border: Border.all(
            color: borderColor ?? Colors.white.withOpacity(0.1),
            width: borderColor != null ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.white.withOpacity(0.2),
                ),
              ),
              child: Center(
                child: _isAnswered && isCorrect
                    ? const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                )
                    : _isAnswered && isWrong
                    ? const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 16,
                )
                    : Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
            if (_isAnswered && isCorrect)
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 20,
              ),
            if (_isAnswered && isWrong)
              const Icon(
                Icons.cancel_rounded,
                color: Colors.red,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanation(String explanation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Explanation',
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            explanation,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(QuizProvider provider) {
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
      child: Row(
        children: [
          if (provider.currentQuestionIndex > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isAnswered ? null : () => _goToPreviousQuestion(provider),
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
                label: const Text('Previous'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.2),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                  ),
                ),
              ),
            ),
          if (provider.currentQuestionIndex > 0)
            const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: _isAnswered
                    ? AppGradients.accentGradient
                    : AppGradients.secondaryGradient,
                borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                boxShadow: _isAnswered ? AppShadows.glow : AppShadows.neon,
              ),
              child: ElevatedButton(
                onPressed: () => _handleNext(provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                  ),
                ),
                child: Text(
                  provider.currentQuestionIndex == provider.currentQuizQuestions.length - 1
                      ? 'See Results'
                      : 'Next Question',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectOption(String option, QuizProvider provider) {
    setState(() {
      _selectedAnswer = option;
      _isAnswered = true;
    });

    final question = provider.currentQuizQuestions[provider.currentQuestionIndex];
    final options = question['options'] as List;
    final selectedIndex = options.indexOf(option);

    provider.selectAnswer(selectedIndex);
  }

  void _goToPreviousQuestion(QuizProvider provider) {
    if (provider.currentQuestionIndex > 0) {
      setState(() {
        _selectedAnswer = null;
        _isAnswered = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Go back not implemented yet'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _handleNext(QuizProvider provider) {
    if (!_isAnswered) return;

    if (provider.currentQuestionIndex == provider.currentQuizQuestions.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const QuizResultScreen(),
        ),
      );
    } else {
      setState(() {
        _selectedAnswer = null;
        _isAnswered = false;
      });
      provider.nextQuestion();
    }
  }
}