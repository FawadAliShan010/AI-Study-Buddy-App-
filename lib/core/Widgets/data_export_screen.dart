import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/firebase_service.dart';
import '../../core/utils/helpers.dart';

class DataExportScreen extends StatefulWidget {
  const DataExportScreen({super.key});

  @override
  State<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends State<DataExportScreen> {
  bool _isLoading = false;
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Export Your Data',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Download all your data from the app including:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildExportItem(
              icon: Icons.person_outline_rounded,
              title: 'Profile Information',
              description: 'Your name, email, and profile picture',
            ),
            _buildExportItem(
              icon: Icons.note_rounded,
              title: 'Study Notes',
              description: 'All your notes and study materials',
            ),
            _buildExportItem(
              icon: Icons.quiz_rounded,
              title: 'Quiz Results',
              description: 'Your quiz history and scores',
            ),
            _buildExportItem(
              icon: Icons.timer_rounded,
              title: 'Study Statistics',
              description: 'Study time, streaks, and progress',
            ),
            _buildExportItem(
              icon: Icons.chat_rounded,
              title: 'Chat History',
              description: 'Your conversations and messages',
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _exporting ? null : _exportData,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _exporting
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Text('Export All Data'),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your data will be exported as a JSON file',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: Colors.green),
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    setState(() => _exporting = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        throw Exception('No user logged in');
      }

      final data = await FirebaseService().exportUserData(user.uid);

      // In a real app, you would save this to a file and share it
      // For now, just show a success message
      if (mounted) {
        Helpers.showSnackBar(
          context,
          'Data exported successfully! (${data.keys.length} items)',
        );
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(
          context,
          'Failed to export data: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }
}