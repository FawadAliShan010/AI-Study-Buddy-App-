import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import '../services/firebase_service.dart';

class StudyProvider extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  final FirebaseService _firebaseService = FirebaseService();

  int _studyTime = 0;
  int _quizzesCompleted = 0;
  int _notesCreated = 0;
  int _streak = 0;
  bool _isLoading = false;
  bool _isSyncing = false;
  List<Map<String, dynamic>> _statsHistory = [];

  // Cache for study data
  DateTime? _lastSyncTime;

  int get studyTime => _studyTime;
  int get quizzesCompleted => _quizzesCompleted;
  int get notesCreated => _notesCreated;
  int get streak => _streak;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  List<Map<String, dynamic>> get statsHistory => _statsHistory;

  // New getters for profile screen
  int get averageDailyTime {
    if (_statsHistory.isEmpty) return 0;

    // Get unique days
    final Set<String> days = {};
    for (var stat in _statsHistory) {
      final dateStr = stat['date'] as String?;
      if (dateStr != null) {
        final day = dateStr.split('T').first;
        days.add(day);
      }
    }

    if (days.isEmpty) return 0;
    return (_studyTime / days.length).round();
  }

  StudyProvider() {
    _loadStats();
  }

  void _loadStats() {
    _statsHistory = _storage.getStudyStats();
    if (_statsHistory.isNotEmpty) {
      // Calculate totals from stats history - explicitly cast to int
      _studyTime = _statsHistory.fold<int>(0, (sum, item) {
        final value = item['studyTime'];
        return sum + (value is int ? value : (value as num?)?.toInt() ?? 0);
      });
      _quizzesCompleted = _statsHistory.fold<int>(0, (sum, item) {
        final value = item['quizzes'];
        return sum + (value is int ? value : (value as num?)?.toInt() ?? 0);
      });
      _notesCreated = _statsHistory.fold<int>(0, (sum, item) {
        final value = item['notes'];
        return sum + (value is int ? value : (value as num?)?.toInt() ?? 0);
      });
    }
    _calculateStreak();
    notifyListeners();
  }

  void _calculateStreak() {
    if (_statsHistory.isEmpty) {
      _streak = 0;
      return;
    }

    // Sort by date - fix the comparator
    List<Map<String, dynamic>> sortedStats = List.from(_statsHistory);
    sortedStats.sort((a, b) {
      final dateA = a['date'] as String?;
      final dateB = b['date'] as String?;
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateB.compareTo(dateA);
    });

    int currentStreak = 0;
    DateTime? lastDate;

    for (var stat in sortedStats) {
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

  // ============ NEW METHOD: Load study data from Firebase ============
  Future<void> loadStudyData(String? userId) async {
    _setLoading(true);
    try {
      if (userId != null && userId.isNotEmpty) {
        // Try to load from Firebase first
        final firebaseStats = await _firebaseService.getStudyStats(userId);

        if (firebaseStats != null) {
          // Update local stats with Firebase data
          _studyTime = firebaseStats['studyTime'] ?? 0;
          _quizzesCompleted = firebaseStats['quizzesCompleted'] ?? 0;
          _notesCreated = firebaseStats['notesCreated'] ?? 0;
          _streak = firebaseStats['streak'] ?? 0;

          // Save to local storage
          await _storage.saveStudyStats({
            'studyTime': _studyTime,
            'quizzes': _quizzesCompleted,
            'notes': _notesCreated,
            'date': DateTime.now().toIso8601String(),
          });

          _statsHistory = _storage.getStudyStats();
          _lastSyncTime = DateTime.now();
        } else {
          // If no Firebase data, load from local
          _loadStats();
        }
      } else {
        // No user, load from local
        _loadStats();
      }

      notifyListeners();
    } catch (e) {
      // Fallback to local data
      _loadStats();
    } finally {
      _setLoading(false);
    }
  }

  // ============ NEW METHOD: Get stats for the week ============
  Future<Map<String, dynamic>> getStatsForWeek() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final weekStats = _statsHistory.where((stat) {
      final statDate = stat['date'] as String?;
      if (statDate == null) return false;
      try {
        final date = DateTime.parse(statDate);
        return date.isAfter(weekAgo) && date.isBefore(now);
      } catch (e) {
        return false;
      }
    }).toList();

    return {
      'studyTime': weekStats.fold<int>(0, (sum, item) {
        final value = item['studyTime'];
        return sum + (value is int ? value : (value as num?)?.toInt() ?? 0);
      }),
      'quizzes': weekStats.fold<int>(0, (sum, item) {
        final value = item['quizzes'];
        return sum + (value is int ? value : (value as num?)?.toInt() ?? 0);
      }),
      'notes': weekStats.fold<int>(0, (sum, item) {
        final value = item['notes'];
        return sum + (value is int ? value : (value as num?)?.toInt() ?? 0);
      }),
      'totalActivities': weekStats.length,
      'dailyAverages': _calculateDailyAverages(weekStats),
    };
  }

  // ============ NEW METHOD: Get stats for the month ============
  Future<Map<String, dynamic>> getStatsForMonth() async {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));

    final monthStats = _statsHistory.where((stat) {
      final statDate = stat['date'] as String?;
      if (statDate == null) return false;
      try {
        final date = DateTime.parse(statDate);
        return date.isAfter(monthAgo) && date.isBefore(now);
      } catch (e) {
        return false;
      }
    }).toList();

    return {
      'studyTime': monthStats.fold<int>(0, (sum, item) {
        final value = item['studyTime'];
        return sum + (value is int ? value : (value as num?)?.toInt() ?? 0);
      }),
      'quizzes': monthStats.fold<int>(0, (sum, item) {
        final value = item['quizzes'];
        return sum + (value is int ? value : (value as num?)?.toInt() ?? 0);
      }),
      'notes': monthStats.fold<int>(0, (sum, item) {
        final value = item['notes'];
        return sum + (value is int ? value : (value as num?)?.toInt() ?? 0);
      }),
      'totalActivities': monthStats.length,
      'dailyAverages': _calculateDailyAverages(monthStats),
    };
  }

  // ============ NEW METHOD: Get stats for a specific date range ============
  Future<Map<String, dynamic>> getStatsForDateRange(DateTime start, DateTime end) async {
    final rangeStats = _statsHistory.where((stat) {
      final statDate = stat['date'] as String?;
      if (statDate == null) return false;
      try {
        final date = DateTime.parse(statDate);
        return date.isAfter(start) && date.isBefore(end);
      } catch (e) {
        return false;
      }
    }).toList();

    return {
      'studyTime': rangeStats.fold<int>(0, (sum, item) {
        final value = item['studyTime'];
        return sum + (value is int ? value : (value as num?)?.toInt() ?? 0);
      }),
      'quizzes': rangeStats.fold<int>(0, (sum, item) {
        final value = item['quizzes'];
        return sum + (value is int ? value : (value as num?)?.toInt() ?? 0);
      }),
      'notes': rangeStats.fold<int>(0, (sum, item) {
        final value = item['notes'];
        return sum + (value is int ? value : (value as num?)?.toInt() ?? 0);
      }),
      'totalActivities': rangeStats.length,
    };
  }

  // ============ NEW METHOD: Sync with Firebase ============
  Future<void> syncWithFirebase(String? userId) async {
    if (_isSyncing) return;
    if (userId == null || userId.isEmpty) {
      throw Exception('No user logged in');
    }

    _isSyncing = true;
    notifyListeners();

    try {
      // Sync local stats to Firebase
      await _firebaseService.updateStudyStats(userId, {
        'studyTime': _studyTime,
        'quizzesCompleted': _quizzesCompleted,
        'notesCreated': _notesCreated,
        'streak': _streak,
        'lastSyncDate': DateTime.now().toIso8601String(),
      });

      // Sync stats history as individual entries
      for (var stat in _statsHistory) {
        await _firebaseService.saveQuizResult(userId, stat);
      }

      _lastSyncTime = DateTime.now();
      _isSyncing = false;
      notifyListeners();
    } catch (e) {
      _isSyncing = false;
      notifyListeners();
      rethrow;
    }
  }

  // ============ NEW METHOD: Clear cache ============
  void clearCache() {
    _lastSyncTime = null;
    notifyListeners();
  }

  // ============ NEW METHOD: Check if data needs sync ============
  bool get needsSync {
    if (_lastSyncTime == null) return true;
    final hoursSinceSync = DateTime.now().difference(_lastSyncTime!).inHours;
    return hoursSinceSync > 24; // Sync every 24 hours
  }

  // ============ NEW METHOD: Get study time in formatted string ============
  String getFormattedStudyTime() {
    final hours = _studyTime ~/ 60;
    final minutes = _studyTime % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  // ============ NEW METHOD: Get progress percentage ============
  double getProgressPercentage(int targetHours) {
    final targetMinutes = targetHours * 60;
    if (targetMinutes == 0) return 0;
    return (_studyTime / targetMinutes).clamp(0.0, 1.0);
  }

  // ============ EXISTING METHODS (keep all) ============

  Future<void> updateStudyTime(int minutes) async {
    _setLoading(true);
    try {
      _studyTime += minutes;
      await _storage.saveStudyStats({
        'studyTime': minutes,
        'date': DateTime.now().toIso8601String(),
        'type': 'study',
      });
      _statsHistory = _storage.getStudyStats();
      _calculateStreak();
      notifyListeners();
    } catch (e) {
      rethrow;
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
      _statsHistory = _storage.getStudyStats();
      notifyListeners();
    } catch (e) {
      rethrow;
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
      _statsHistory = _storage.getStudyStats();
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshStats() async {
    _setLoading(true);
    try {
      _statsHistory = _storage.getStudyStats();
      _loadStats();
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getStatsForDate(DateTime date) async {
    final dateStr = date.toIso8601String().split('T').first;
    final statsForDate = _statsHistory.where((stat) {
      final statDate = stat['date'] as String?;
      if (statDate == null) return false;
      return statDate.startsWith(dateStr);
    }).toList();

    return {
      'studyTime': statsForDate.fold<int>(0, (sum, item) {
        final value = item['studyTime'];
        return sum + (value is int ? value : (value as num?)?.toInt() ?? 0);
      }),
      'quizzes': statsForDate.fold<int>(0, (sum, item) {
        final value = item['quizzes'];
        return sum + (value is int ? value : (value as num?)?.toInt() ?? 0);
      }),
      'notes': statsForDate.fold<int>(0, (sum, item) {
        final value = item['notes'];
        return sum + (value is int ? value : (value as num?)?.toInt() ?? 0);
      }),
      'totalActivities': statsForDate.length,
    };
  }

  Map<String, double> _calculateDailyAverages(List<Map<String, dynamic>> stats) {
    if (stats.isEmpty) return {};

    Map<String, List<int>> dailyStats = {};
    for (var stat in stats) {
      final dateStr = stat['date'] as String?;
      if (dateStr == null) continue;

      final date = dateStr.split('T').first;
      if (!dailyStats.containsKey(date)) {
        dailyStats[date] = [0, 0, 0]; // [studyTime, quizzes, notes]
      }

      final studyTimeValue = stat['studyTime'];
      final quizzesValue = stat['quizzes'];
      final notesValue = stat['notes'];

      dailyStats[date]![0] += (studyTimeValue is int ? studyTimeValue : (studyTimeValue as num?)?.toInt() ?? 0);
      dailyStats[date]![1] += (quizzesValue is int ? quizzesValue : (quizzesValue as num?)?.toInt() ?? 0);
      dailyStats[date]![2] += (notesValue is int ? notesValue : (notesValue as num?)?.toInt() ?? 0);
    }

    Map<String, double> averages = {};
    dailyStats.forEach((date, values) {
      averages[date] = (values[0] + values[1] + values[2]) / 3.0;
    });

    return averages;
  }

  Future<void> resetStats() async {
    _setLoading(true);
    try {
      _studyTime = 0;
      _quizzesCompleted = 0;
      _notesCreated = 0;
      _streak = 0;
      _statsHistory.clear();
      await _storage.clearStudyStats();
      _lastSyncTime = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}