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

  // App specific storage
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyUserPreferences = 'user_preferences';
  static const String _keyStudyStats = 'study_stats';
  static const String _keyThemeMode = 'theme_mode';

  Future<void> setOnboardingComplete(bool complete) async {
    await setBool(_keyOnboardingComplete, complete);
  }

  bool isOnboardingComplete() {
    return getBool(_keyOnboardingComplete) ?? false;
  }

  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    await setObject(_keyUserPreferences, preferences);
  }

  Map<String, dynamic>? getUserPreferences() {
    return getObject(_keyUserPreferences) as Map<String, dynamic>?;
  }

  Future<void> saveStudyStats(Map<String, dynamic> stats) async {
    final existing = getStudyStats() ?? [];
    existing.add(stats);
    await setObject(_keyStudyStats, existing);
  }

  List<Map<String, dynamic>> getStudyStats() {
    final data = getObject(_keyStudyStats);
    if (data != null && data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> setThemeMode(String themeMode) async {
    await setString(_keyThemeMode, themeMode);
  }

  String? getThemeMode() {
    return getString(_keyThemeMode);
  }
}