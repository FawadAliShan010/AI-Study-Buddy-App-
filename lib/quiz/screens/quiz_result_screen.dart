import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/quiz_provider.dart';
import '../../../core/utils/helpers.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final results = quizProvider.getResults();
    final percentage = results['percentage'] as int;
    final totalQuestions = results['totalQuestions'] as int;
    final correctAnswers = results['correctAnswers'] as int;
    final wrongAnswers = results['wrongAnswers'] as int;
    final passed = results['passed'] as bool;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Quiz Results'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FadeInDown(
              child: Column(
                children: [
                  Lottie.asset(
                    passed
                        ? 'assets/animations/success.json'
                        : 'assets/animations/ai_loading.json',
                    width: 200,
                    height: 200,
                    repeat: false,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    passed ? '🎉 Excellent!' : '💪 Keep Learning!',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: passed ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Helpers.getQuizScoreLabel(percentage.toDouble()),
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _buildScoreCard(
                context,
                percentage,
                totalQuestions,
                correctAnswers,
                wrongAnswers,
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: _buildActionButtons(context, quizProvider),
            ),
            if (results['questions'] != null) ...[
              const SizedBox(height: 24),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: _buildReviewSection(context, results['questions']),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(
      BuildContext context,
      int percentage,
      int totalQuestions,
      int correctAnswers,
      int wrongAnswers,
      ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.largeRadius),
        boxShadow: AppShadows.glow,
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Helpers.getQuizScoreColor(percentage.toDouble()),
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    '$percentage%',
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Score',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatItem(
                'Correct',
                correctAnswers.toString(),
                Colors.green,
                Icons.check_circle_rounded,
              ),
              _buildStatItem(
                'Wrong',
                wrongAnswers.toString(),
                Colors.red,
                Icons.cancel_rounded,
              ),
              _buildStatItem(
                'Total',
                totalQuestions.toString(),
                Colors.blue,
                Icons.question_answer_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, QuizProvider provider) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              provider.restartQuiz();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry Quiz'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: AppGradients.secondaryGradient,
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
              boxShadow: AppShadows.neon,
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                ),
              ),
              child: const Text('Back to Quiz'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection(BuildContext context, List questions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Answers',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...questions.map((question) {
          final index = questions.indexOf(question);
          final isCorrect = question['isCorrect'] ?? false;

          return FadeInUp(
            delay: Duration(milliseconds: 500 + index * 50),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCorrect
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                border: Border.all(
                  color: isCorrect
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.red.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isCorrect
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: isCorrect ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Q${index + 1}: ${question['question']}',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your answer: ${question['userAnswer'] ?? 'Not answered'}',
                    style: GoogleFonts.inter(
                      color: isCorrect ? Colors.green : Colors.red,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Correct: ${question['correctAnswer']}',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}