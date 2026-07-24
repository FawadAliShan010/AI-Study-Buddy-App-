import 'package:ai_study_buddy/quiz/screens/quiz_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/quiz_provider.dart';
import '../../../core/utils/helpers.dart';

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
    final questions = quizProvider.questions;
    final currentIndex = quizProvider.currentQuestionIndex;
    final question = questions[currentIndex];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Question ${currentIndex + 1}/${questions.length}'),
        actions: [
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
      body: Column(
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
                      question['question'],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(
                    (question['options'] as List).length,
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
    );
  }

  Widget _buildOption(int index, String option, QuizProvider provider) {
    final isSelected = _selectedAnswer == option;
    final isCorrect = _isAnswered && option == provider.questions[provider.currentQuestionIndex]['correctAnswer'];
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
      onTap: _isAnswered ? null : () => _selectOption(option),
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
                onPressed: _isAnswered ? null : provider.previousQuestion,
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
                  provider.currentQuestionIndex == provider.questions.length - 1
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

  void _selectOption(String option) {
    setState(() {
      _selectedAnswer = option;
      _isAnswered = true;
    });

    final provider = Provider.of<QuizProvider>(context, listen: false);
    provider.answerQuestion(option);
  }

  void _handleNext(QuizProvider provider) {
    if (!_isAnswered) return;

    if (provider.currentQuestionIndex == provider.questions.length - 1) {
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