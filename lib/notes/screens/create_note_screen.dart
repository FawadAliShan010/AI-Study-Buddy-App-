import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/groq_ai_service.dart';
import '../../../core/utils/helpers.dart';

class CreateNoteScreen extends StatefulWidget {
  final String? noteId;
  final Map<String, dynamic>? noteData;

  const CreateNoteScreen({
    super.key,
    this.noteId,
    this.noteData,
  });

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _subjectController = TextEditingController();
  final _tagsController = TextEditingController();

  bool _isLoading = false;
  bool _isSummarizing = false;
  String _selectedSubject = 'General';

  final List<String> _subjects = [
    'General',
    'Math',
    'Science',
    'History',
    'English',
    'Art',
    'Music',
    'Physics',
    'Chemistry',
    'Biology',
    'Geography',
    'Computer Science',
    'Economics',
    'Business',
    'Psychology',
    'Philosophy',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.noteData != null) {
      _titleController.text = widget.noteData!['title'] ?? '';
      _contentController.text = widget.noteData!['content'] ?? '';
      _selectedSubject = widget.noteData!['subject'] ?? 'General';
      _tagsController.text = widget.noteData!['tags']?.join(', ') ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(widget.noteId == null ? 'Create Note' : 'Edit Note'),
        actions: [
          if (_contentController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.summarize_rounded),
              onPressed: _isSummarizing ? null : _summarizeContent,
              tooltip: 'Summarize with AI',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInUp(
                child: _buildTitleField(),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: _buildSubjectDropdown(),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: _buildTagsField(),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: _buildContentField(),
              ),
              if (_isSummarizing) ...[
                const SizedBox(height: 12),
                _buildSummarizingIndicator(),
              ],
              const SizedBox(height: 32),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: _buildSaveButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintText: 'Note Title',
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.3),
        ),
        border: InputBorder.none,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.all(16),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
    );
  }

  Widget _buildSubjectDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedSubject,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Select Subject',
          hintStyle: TextStyle(
            color: Colors.white38,
          ),
          icon: Icon(Icons.arrow_drop_down, color: Colors.white54),
        ),
        dropdownColor: AppColors.surface,
        style: const TextStyle(color: Colors.white),
        items: _subjects.map((subject) {
          return DropdownMenuItem(
            value: subject,
            child: Row(
              children: [
                Text(Helpers.getEmojiForSubject(subject)),
                const SizedBox(width: 8),
                Text(subject),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedSubject = value ?? 'General';
          });
        },
      ),
    );
  }

  Widget _buildTagsField() {
    return TextFormField(
      controller: _tagsController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Tags (comma separated)',
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.3),
        ),
        prefixIcon: const Icon(
          Icons.tag_rounded,
          color: Colors.white54,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: const BorderSide(
            color: AppColors.primary,
          ),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
    );
  }

  Widget _buildContentField() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: TextFormField(
        controller: _contentController,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.5,
        ),
        maxLines: null,
        expands: true,
        decoration: InputDecoration(
          hintText: 'Write your note content here...',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.3),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter some content';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSummarizingIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Generating summary with AI...',
            style: GoogleFonts.inter(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppGradients.secondaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        boxShadow: AppShadows.neon,
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveNote,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text(
          'Save Note',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _summarizeContent() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      Helpers.showSnackBar(context, 'Please enter some content first', isError: true);
      return;
    }

    setState(() => _isSummarizing = true);

    try {
      final summary = await GroqAIService().summarizeText(content);
      setState(() {
        _contentController.text = summary;
        _isSummarizing = false;
      });
      Helpers.showSnackBar(context, 'Summary generated successfully!');
    } catch (e) {
      setState(() => _isSummarizing = false);
      Helpers.showSnackBar(context, 'Failed to summarize: $e', isError: true);
    }
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseService().currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final noteData = {
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'subject': _selectedSubject,
        'tags': tags,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.noteId != null) {
        await FirebaseService().updateNote(userId, widget.noteId!, noteData);
        Helpers.showSnackBar(context, 'Note updated successfully!');
      } else {
        noteData['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseService().createNote(userId, noteData);
        Helpers.showSnackBar(context, 'Note created successfully!');
      }

      Navigator.pop(context);
    } catch (e) {
      Helpers.showSnackBar(context, 'Failed to save note: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _subjectController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}