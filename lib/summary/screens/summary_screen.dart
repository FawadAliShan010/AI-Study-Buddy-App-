import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/study_provider.dart';
import '../../../core/utils/helpers.dart';
import '../../core/services/groq_ai_service.dart';
import '../widgets/summary_card.dart';
import '../../notes/screens/notes_screen.dart';
import '../../quiz/screens/quiz_screen.dart';
import '../../chat/screens/chat_screen.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  String? _summaryResult;

  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Smart Summary'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Text(
                'AI-Powered Summarization',
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
                'Paste text or upload content to get an AI-generated summary',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: _buildInputSection(),
            ),
            const SizedBox(height: 20),
            if (_isLoading) ...[
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text(
                      'Generating summary...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
            if (_summaryResult != null) ...[
              const SizedBox(height: 20),
              FadeInUp(
                child: _buildSummaryResult(),
              ),
            ],
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: _buildQuickActions(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 150,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Paste your text here to summarize...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppConstants.defaultRadius),
                bottomRight: Radius.circular(AppConstants.defaultRadius),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _uploadFile,
                    icon: const Icon(Icons.upload_file_rounded),
                    label: const Text('Upload File'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.defaultRadius,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppGradients.secondaryGradient,
                    borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                    boxShadow: AppShadows.neon,
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading || _textController.text.isEmpty
                        ? null
                        : _summarize,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.defaultRadius,
                        ),
                      ),
                    ),
                    child: const Text('Summarize'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryResult() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        boxShadow: AppShadows.glow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.summarize_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy_rounded, color: Colors.white70),
                onPressed: () {
                  // TODO: Copy to clipboard
                  Helpers.showSnackBar(context, 'Copied to clipboard!');
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _summaryResult!,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Colors.white38,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'AI-generated summary • ${_textController.text.split(' ').length} words',
                style: GoogleFonts.inter(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.note_add_rounded,
                title: 'Create Note',
                subtitle: 'Save summary as note',
                gradient: AppGradients.primaryGradient,
                onTap: () {
                  if (_summaryResult != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotesScreen(),
                      ),
                    );
                  } else {
                    Helpers.showSnackBar(
                      context,
                      'Generate a summary first',
                      isError: true,
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.quiz_rounded,
                title: 'Generate Quiz',
                subtitle: 'Test your knowledge',
                gradient: AppGradients.secondaryGradient,
                onTap: () {
                  if (_summaryResult != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuizScreen(),
                      ),
                    );
                  } else {
                    Helpers.showSnackBar(
                      context,
                      'Generate a summary first',
                      isError: true,
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.chat_rounded,
                title: 'Ask AI',
                subtitle: 'Discuss the content',
                gradient: AppGradients.accentGradient,
                onTap: () {
                  if (_summaryResult != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatScreen(),
                      ),
                    );
                  } else {
                    Helpers.showSnackBar(
                      context,
                      'Generate a summary first',
                      isError: true,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          boxShadow: AppShadows.glow,
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _summarize() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _summaryResult = null;
    });

    try {
      final summary = await GroqAIService().summarizeText(text);
      setState(() {
        _summaryResult = summary;
        _isLoading = false;
      });
      Helpers.showSnackBar(context, 'Summary generated successfully!');
    } catch (e) {
      setState(() => _isLoading = false);
      Helpers.showSnackBar(context, 'Failed to generate summary: $e', isError: true);
    }
  }

  Future<void> _uploadFile() async {
    // TODO: Implement file upload
    Helpers.showSnackBar(context, 'File upload coming soon!');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}