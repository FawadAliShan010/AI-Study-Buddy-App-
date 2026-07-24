import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/quiz_provider.dart';
import '../../../core/utils/helpers.dart';
import '../widgets/quiz_card.dart';
import 'quiz_question_screen.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final TextEditingController _topicController = TextEditingController();
  int _questionCount = 5;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);

    if (quizProvider.isLoading || _isGenerating) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (quizProvider.isQuizComplete && quizProvider.questions.isNotEmpty) {
      return const QuizResultScreen();
    }

    if (quizProvider.questions.isNotEmpty) {
      return const QuizQuestionScreen();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Smart Quiz'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Text(
                'Generate a Quiz',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              child: Text(
                'Test your knowledge with AI-generated questions',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: _buildTopicField(),
            ),
            const SizedBox(height: 20),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: _buildQuestionCount(),
            ),
            const SizedBox(height: 32),
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: _buildGenerateButton(),
            ),
            const SizedBox(height: 32),
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: _buildQuickQuizzes(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: TextField(
        controller: _topicController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Enter a topic (e.g., Quantum Physics)',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.3),
          ),
          prefixIcon: const Icon(
            Icons.topic_rounded,
            color: Colors.white54,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildQuestionCount() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.numbers_rounded,
            color: Colors.white54,
          ),
          const SizedBox(width: 12),
          Text(
            'Number of Questions:',
            style: GoogleFonts.inter(
              color: Colors.white70,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.remove_rounded),
            color: Colors.white54,
            onPressed: () {
              if (_questionCount > 3) {
                setState(() {
                  _questionCount--;
                });
              }
            },
          ),
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              '$_questionCount',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            color: Colors.white54,
            onPressed: () {
              if (_questionCount < 10) {
                setState(() {
                  _questionCount++;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppGradients.secondaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        boxShadow: AppShadows.neon,
      ),
      child: ElevatedButton(
        onPressed: _topicController.text.trim().isEmpty ? null : _generateQuiz,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          ),
        ),
        child: const Text(
          'Generate Quiz',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickQuizzes() {
    final quickTopics = [
      'Mathematics',
      'Science',
      'History',
      'Computer Science',
      'English Literature',
      'World Geography',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Quizzes',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickTopics.map((topic) {
            return FadeInUp(
              delay: Duration(milliseconds: 700 + quickTopics.indexOf(topic) * 100),
              child: ActionChip(
                label: Text(
                  topic,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  _topicController.text = topic;
                },
                backgroundColor: Colors.white.withOpacity(0.05),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _generateQuiz() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;

    setState(() => _isGenerating = true);

    try {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      await quizProvider.generateQuiz(topic, _questionCount);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const QuizQuestionScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(
          context,
          'Failed to generate quiz: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }
}