import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/quiz_provider.dart';
import 'quiz_screen.dart';
import 'quiz_question_screen.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);

    // Get results from quiz provider with safe defaults
    final totalQuestions = quizProvider.totalQuestions > 0 ? quizProvider.totalQuestions : 0;
    final score = quizProvider.score;
    final percentage = totalQuestions > 0 ? (score / totalQuestions * 100).round() : 0;
    final correctAnswers = score;
    final wrongAnswers = totalQuestions - score;
    final passed = percentage >= 60;

    return WillPopScope(
      onWillPop: () async {
        quizProvider.resetQuiz();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const QuizScreen()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Quiz Results',
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
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
          ),
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
                  quizProvider.resetQuiz();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const QuizScreen()),
                  );
                } else if (value == 'retry_quiz') {
                  quizProvider.retakeQuiz();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const QuizQuestionScreen()),
                  );
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
                  value: 'retry_quiz',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.refresh_rounded,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Retry Quiz',
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
                  value: 'close',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.close_rounded,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Close',
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
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              passed ? Icons.emoji_events_rounded : Icons.school_rounded,
                              size: 100,
                              color: passed ? Colors.green : Colors.orange,
                            );
                          },
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
                          _getQuizScoreLabel(percentage.toDouble()),
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
                  if (quizProvider.currentQuizQuestions.isNotEmpty && quizProvider.userAnswers.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: _buildReviewSection(context, quizProvider),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getQuizScoreLabel(double percentage) {
    if (percentage >= 90) return 'Outstanding! You\'re a genius!';
    if (percentage >= 75) return 'Great job! You really know your stuff!';
    if (percentage >= 60) return 'Good effort! Keep practicing!';
    if (percentage >= 40) return 'Not bad! Review and try again.';
    return 'Don\'t give up! Practice makes perfect!';
  }

  Color _getQuizScoreColor(double percentage) {
    if (percentage >= 75) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
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
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getQuizScoreColor(percentage.toDouble()),
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
              provider.retakeQuiz();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuizQuestionScreen(),
                ),
              );
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry Quiz'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: BorderSide(
                color: Colors.white.withOpacity(0.2),
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
                provider.resetQuiz();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuizScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                ),
              ),
              child: const Text('New Quiz'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection(BuildContext context, QuizProvider provider) {
    final questions = provider.currentQuizQuestions;
    final userAnswers = provider.userAnswers;

    if (questions.isEmpty || userAnswers.isEmpty) {
      return const SizedBox.shrink();
    }

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
        ...List.generate(questions.length, (index) {
          final question = questions[index];
          final options = question['options'] as List? ?? [];
          final correctAnswer = question['correctAnswer'] ?? '';

          final selectedOption = index < userAnswers.length
              ? userAnswers[index]
              : null;

          final isCorrect = selectedOption != null &&
              selectedOption == correctAnswer;

          return FadeInUp(
            delay: Duration(milliseconds: 500 + index * 50),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCorrect
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                border: Border.all(
                  color: isCorrect
                      ? Colors.green.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3),
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
                          'Q${index + 1}: ${question['question'] ?? 'No question'}',
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
                    'Your answer: ${selectedOption ?? 'Not answered'}',
                    style: GoogleFonts.inter(
                      color: isCorrect ? Colors.green : Colors.red,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Correct: $correctAnswer',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}