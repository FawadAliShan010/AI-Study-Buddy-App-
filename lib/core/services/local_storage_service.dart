import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Generic methods
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  Future<void> setList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  List<String>? getList(String key) {
    return _prefs.getStringList(key);
  }

  // Complex data storage
  Future<void> setObject(String key, dynamic object) async {
    final jsonString = json.encode(object);
    await _prefs.setString(key, jsonString);
  }

  dynamic getObject(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString != null) {
      return json.decode(jsonString);
    }
    return null;
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }

  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  Set<String> getKeys() {
    return _prefs.getKeys();
  }

  // ==================== STUDY STATS METHODS ====================

  static const String _keyStudyStats = 'study_stats';

  Future<void> saveStudyStats(Map<String, dynamic> stats) async {
    try {
      final existing = getStudyStats();
      existing.add(stats);
      await setObject(_keyStudyStats, existing);
    } catch (e) {
      throw Exception('Failed to save study stats: $e');
    }
  }

  List<Map<String, dynamic>> getStudyStats() {
    try {
      final data = getObject(_keyStudyStats);
      if (data != null && data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> clearStudyStats() async {
    try {
      await remove(_keyStudyStats);
    } catch (e) {
      throw Exception('Failed to clear study stats: $e');
    }
  }

  Future<void> removeStudyStatsByDate(String date) async {
    try {
      final stats = getStudyStats();
      stats.removeWhere((stat) => stat['date'] == date);
      await setObject(_keyStudyStats, stats);
    } catch (e) {
      throw Exception('Failed to remove study stats by date: $e');
    }
  }

  Future<Map<String, dynamic>> getStatsSummary() async {
    try {
      final stats = getStudyStats();

      int totalStudyTime = 0;
      int totalQuizzes = 0;
      int totalNotes = 0;
      int totalActivities = stats.length;

      for (var stat in stats) {
        totalStudyTime += stat['studyTime'] as int? ?? 0;
        totalQuizzes += stat['quizzes'] as int? ?? 0;
        totalNotes += stat['notes'] as int? ?? 0;
      }

      return {
        'totalStudyTime': totalStudyTime,
        'totalQuizzes': totalQuizzes,
        'totalNotes': totalNotes,
        'totalActivities': totalActivities,
        'lastActivity': stats.isNotEmpty ? stats.last['date'] : null,
      };
    } catch (e) {
      return {
        'totalStudyTime': 0,
        'totalQuizzes': 0,
        'totalNotes': 0,
        'totalActivities': 0,
        'lastActivity': null,
      };
    }
  }

  // ==================== USER PREFERENCES METHODS ====================

  static const String _keyUserPreferences = 'user_preferences';

  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    try {
      await setObject(_keyUserPreferences, preferences);
    } catch (e) {
      throw Exception('Failed to save user preferences: $e');
    }
  }

  Map<String, dynamic>? getUserPreferences() {
    try {
      return getObject(_keyUserPreferences) as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearUserPreferences() async {
    try {
      await remove(_keyUserPreferences);
    } catch (e) {
      throw Exception('Failed to clear user preferences: $e');
    }
  }

  // ==================== ONBOARDING METHODS ====================

  static const String _keyOnboardingComplete = 'onboarding_complete';

  Future<void> setOnboardingComplete(bool complete) async {
    try {
      await setBool(_keyOnboardingComplete, complete);
    } catch (e) {
      throw Exception('Failed to set onboarding complete: $e');
    }
  }

  bool isOnboardingComplete() {
    try {
      return getBool(_keyOnboardingComplete) ?? false;
    } catch (e) {
      return false;
    }
  }

  // ==================== THEME SETTINGS METHODS ====================

  static const String _keyThemeMode = 'theme_mode';
  static const String _keyIsDarkMode = 'is_dark_mode';

  Future<void> setThemeMode(String themeMode) async {
    try {
      await setString(_keyThemeMode, themeMode);
    } catch (e) {
      throw Exception('Failed to set theme mode: $e');
    }
  }

  String? getThemeMode() {
    try {
      return getString(_keyThemeMode);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveIsDarkMode(bool isDark) async {
    try {
      await setBool(_keyIsDarkMode, isDark);
    } catch (e) {
      throw Exception('Failed to save dark mode: $e');
    }
  }

  bool getIsDarkMode() {
    try {
      return getBool(_keyIsDarkMode) ?? false;
    } catch (e) {
      return false;
    }
  }

  // ==================== AUTHENTICATION METHODS ====================

  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserId = 'user_id';

  Future<void> saveAuthToken(String token) async {
    try {
      await setString(_keyAuthToken, token);
    } catch (e) {
      throw Exception('Failed to save auth token: $e');
    }
  }

  String? getAuthToken() {
    try {
      return getString(_keyAuthToken);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearAuthToken() async {
    try {
      await remove(_keyAuthToken);
    } catch (e) {
      throw Exception('Failed to clear auth token: $e');
    }
  }

  Future<void> saveUserId(String userId) async {
    try {
      await setString(_keyUserId, userId);
    } catch (e) {
      throw Exception('Failed to save user ID: $e');
    }
  }

  String? getUserId() {
    try {
      return getString(_keyUserId);
    } catch (e) {
      return null;
    }
  }

  // ==================== CACHE METHODS ====================

  static const String _cachePrefix = 'cache_';

  Future<void> saveCache(String key, String value) async {
    try {
      await setString('$_cachePrefix$key', value);
    } catch (e) {
      throw Exception('Failed to save cache: $e');
    }
  }

  String? getCache(String key) {
    try {
      return getString('$_cachePrefix$key');
    } catch (e) {
      return null;
    }
  }

  Future<void> clearCache(String key) async {
    try {
      await remove('$_cachePrefix$key');
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }

  Future<void> clearAllCache() async {
    try {
      final keys = _prefs.getKeys();
      for (String key in keys) {
        if (key.startsWith(_cachePrefix)) {
          await _prefs.remove(key);
        }
      }
    } catch (e) {
      throw Exception('Failed to clear all cache: $e');
    }
  }

  // ==================== SETTINGS METHODS ====================

  static const String _keyAppSettings = 'app_settings';

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      await setObject(_keyAppSettings, settings);
    } catch (e) {
      throw Exception('Failed to save settings: $e');
    }
  }

  Map<String, dynamic> getSettings() {
    try {
      final settings = getObject(_keyAppSettings);
      return settings as Map<String, dynamic>? ?? {};
    } catch (e) {
      return {};
    }
  }

  Future<void> clearSettings() async {
    try {
      await remove(_keyAppSettings);
    } catch (e) {
      throw Exception('Failed to clear settings: $e');
    }
  }

  // ==================== NOTIFICATION METHODS ====================

  static const String _keyNotificationSettings = 'notification_settings';

  Future<void> saveNotificationSettings(Map<String, dynamic> settings) async {
    try {
      await setObject(_keyNotificationSettings, settings);
    } catch (e) {
      throw Exception('Failed to save notification settings: $e');
    }
  }

  Map<String, dynamic> getNotificationSettings() {
    try {
      final settings = getObject(_keyNotificationSettings);
      return settings as Map<String, dynamic>? ?? {};
    } catch (e) {
      return {};
    }
  }

  // ==================== UTILITY METHODS ====================

  Future<void> clearAllData() async {
    try {
      await clear();
    } catch (e) {
      throw Exception('Failed to clear all data: $e');
    }
  }

  Map<String, dynamic> getAllData() {
    try {
      final Map<String, dynamic> allData = {};
      final Set<String> keys = _prefs.getKeys();
      for (String key in keys) {
        final value = _prefs.get(key);
        if (value != null) {
          allData[key] = value;
        }
      }
      return allData;
    } catch (e) {
      return {};
    }
  }

  // ==================== EXPORT/IMPORT METHODS ====================

  Future<String> exportData() async {
    try {
      final allData = getAllData();
      return json.encode(allData);
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  Future<void> importData(String jsonData) async {
    try {
      final Map<String, dynamic> data = Map<String, dynamic>.from(json.decode(jsonData));
      for (String key in data.keys) {
        final value = data[key];
        if (value is String) {
          await setString(key, value);
        } else if (value is int) {
          await setInt(key, value);
        } else if (value is bool) {
          await setBool(key, value);
        } else if (value is double) {
          await setDouble(key, value);
        } else if (value is List<String>) {
          await setList(key, value);
        } else if (value is List) {
          await setObject(key, value);
        } else if (value is Map) {
          await setObject(key, value);
        }
      }
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  // ==================== SESSION METHODS ====================

  static const String _keyLastLogin = 'last_login';
  static const String _keySessionData = 'session_data';

  Future<void> saveLastLogin(DateTime dateTime) async {
    try {
      await setString(_keyLastLogin, dateTime.toIso8601String());
    } catch (e) {
      throw Exception('Failed to save last login: $e');
    }
  }

  DateTime? getLastLogin() {
    try {
      final dateStr = getString(_keyLastLogin);
      return dateStr != null ? DateTime.parse(dateStr) : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> saveSessionData(Map<String, dynamic> data) async {
    try {
      await setObject(_keySessionData, data);
    } catch (e) {
      throw Exception('Failed to save session data: $e');
    }
  }

  Map<String, dynamic>? getSessionData() {
    try {
      return getObject(_keySessionData) as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearSessionData() async {
    try {
      await remove(_keySessionData);
      await remove(_keyLastLogin);
    } catch (e) {
      throw Exception('Failed to clear session data: $e');
    }
  }
}