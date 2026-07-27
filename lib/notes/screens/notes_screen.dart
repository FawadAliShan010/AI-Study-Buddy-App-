import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/utils/helpers.dart';
import '../widgets/note_card.dart';
import 'create_note_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String _searchQuery = '';
  String _selectedSubject = 'All';

  final List<String> _subjects = [
    'All',
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
  ];

  @override
  Widget build(BuildContext context) {
    final userId = _firebaseService.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _NotesSearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: userId == null
          ? _buildEmptyState()
          : Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firebaseService.getNotes(userId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final notes = snapshot.data?.docs ?? [];
                final filteredNotes = _filterNotes(notes);

                if (filteredNotes.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildNotesList(filteredNotes);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FadeInUp(
        child: Container(
          decoration: BoxDecoration(
            gradient: AppGradients.secondaryGradient,
            shape: BoxShape.circle,
            boxShadow: AppShadows.neon,
          ),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateNoteScreen(),
                ),
              );
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _subjects.length,
        itemBuilder: (context, index) {
          final subject = _subjects[index];
          final isSelected = subject == _selectedSubject;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                subject,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedSubject = subject;
                });
              },
              backgroundColor: Colors.white.withOpacity(0.05),
              selectedColor: AppColors.primary,
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.1),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  List<QueryDocumentSnapshot> _filterNotes(List<QueryDocumentSnapshot> notes) {
    return notes.where((note) {
      final data = note.data() as Map<String, dynamic>;
      final title = data['title']?.toString().toLowerCase() ?? '';
      final content = data['content']?.toString().toLowerCase() ?? '';
      final subject = data['subject']?.toString() ?? '';

      final matchesSearch = _searchQuery.isEmpty ||
          title.contains(_searchQuery.toLowerCase()) ||
          content.contains(_searchQuery.toLowerCase());

      final matchesSubject = _selectedSubject == 'All' || subject == _selectedSubject;

      return matchesSearch && matchesSubject;
    }).toList();
  }

  Widget _buildNotesList(List<QueryDocumentSnapshot> notes) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final data = note.data() as Map<String, dynamic>;
        final timestamp = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

        return FadeInUp(
          delay: Duration(milliseconds: index * 50),
          child: NoteCard(
            id: note.id,
            title: data['title'] ?? 'Untitled',
            content: data['content'] ?? '',
            subject: data['subject'] ?? 'General',
            timestamp: timestamp,
            onTap: () {
              // TODO: Navigate to note detail
            },
            onEdit: () {
              // TODO: Navigate to edit note
            },
            onDelete: () async {
              final confirm = await Helpers.showConfirmationDialog(
                context,
                'Delete Note',
                'Are you sure you want to delete this note?',
              );
              if (confirm) {
                final userId = _firebaseService.currentUser?.uid;
                if (userId != null) {
                  await _firebaseService.deleteNote(userId, note.id);
                  Helpers.showSnackBar(context, 'Note deleted successfully');
                }
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: Icon(
              Icons.note_add_rounded,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 16),
          FadeInDown(
            delay: const Duration(milliseconds: 200),
            child: Text(
              'No Notes Yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white54,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInDown(
            delay: const Duration(milliseconds: 400),
            child: Text(
              'Start creating your first note',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white38,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load notes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white38,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NotesSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Search results will be handled by the main widget
    close(context, query);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}