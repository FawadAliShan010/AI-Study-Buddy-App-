import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/local_storage_service.dart';

class StudyProvider extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();

  int _studyTime = 0;
  int _quizzesCompleted = 0;
  int _notesCreated = 0;
  int _streak = 0;
  bool _isLoading = false;

  int get studyTime => _studyTime;
  int get quizzesCompleted => _quizzesCompleted;
  int get notesCreated => _notesCreated;
  int get streak => _streak;
  bool get isLoading => _isLoading;

  StudyProvider() {
    _loadStats();
  }

  void _loadStats() {
    final stats = _storage.getStudyStats();
    if (stats.isNotEmpty) {
      // Calculate totals from stats history - explicitly cast to int
      _studyTime = stats.fold<int>(0, (sum, item) {
        final value = item['studyTime'];
        return sum + (value is int ? value : (value as num?)?.toInt() ?? 0);
      });
      _quizzesCompleted = stats.fold<int>(0, (sum, item) {
        final value = item['quizzes'];
        return sum + (value is int ? value : (value as num?)?.toInt() ?? 0);
      });
      _notesCreated = stats.fold<int>(0, (sum, item) {
        final value = item['notes'];
        return sum + (value is int ? value : (value as num?)?.toInt() ?? 0);
      });
    }
    _calculateStreak();
    notifyListeners();
  }

  void _calculateStreak() {
    final stats = _storage.getStudyStats();
    if (stats.isEmpty) {
      _streak = 0;
      return;
    }

    // Sort by date - fix the comparator
    stats.sort((a, b) {
      final dateA = a['date'] as String?;
      final dateB = b['date'] as String?;
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateB.compareTo(dateA);
    });

    int currentStreak = 0;
    DateTime? lastDate;

    for (var stat in stats) {
      final dateStr = stat['date'] as String?;
      if (dateStr == null) continue;

      try {
        final date = DateTime.parse(dateStr);
        if (lastDate == null) {
          lastDate = date;
          currentStreak = 1;
          continue;
        }

        final difference = lastDate.difference(date).inDays;
        if (difference == 1) {
          currentStreak++;
          lastDate = date;
        } else if (difference > 1) {
          break;
        }
      } catch (e) {
        // Skip invalid dates
        continue;
      }
    }

    _streak = currentStreak;
  }

  Future<void> updateStudyTime(int minutes) async {
    _setLoading(true);
    try {
      _studyTime += minutes;
      await _storage.saveStudyStats({
        'studyTime': minutes,
        'date': DateTime.now().toIso8601String(),
        'type': 'study',
      });
      _calculateStreak();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update study time: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> incrementQuizzes() async {
    _setLoading(true);
    try {
      _quizzesCompleted++;
      await _storage.saveStudyStats({
        'quizzes': 1,
        'date': DateTime.now().toIso8601String(),
        'type': 'quiz',
      });
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update quizzes: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> incrementNotes() async {
    _setLoading(true);
    try {
      _notesCreated++;
      await _storage.saveStudyStats({
        'notes': 1,
        'date': DateTime.now().toIso8601String(),
        'type': 'note',
      });
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update notes: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> syncWithFirebase() async {
    // TODO: Implement Firebase sync when needed
    // This method can be used later to sync stats with Firebase
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void resetStats() {
    _studyTime = 0;
    _quizzesCompleted = 0;
    _notesCreated = 0;
    _streak = 0;
    notifyListeners();
  }
}