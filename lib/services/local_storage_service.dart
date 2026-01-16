// lib/services/local_storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;

  // Initialize storage
  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  // Ensure initialization
  void _ensureInitialized() {
    if (!_initialized) {
      throw Exception(
          'LocalStorageService not initialized. Call init() first.');
    }
  }

  // ==================== STUDENT INFO ====================

  /// Save student ID
  Future<void> saveStudentId(int studentId) async {
    _ensureInitialized();
    await _prefs.setInt('student_id', studentId);
  }

  /// Get student ID
  int? getStudentId() {
    _ensureInitialized();
    return _prefs.getInt('student_id');
  }

  /// Save student details
  Future<void> saveStudentDetails({
    required int id,
    required String rollNo,
    required String name,
    required int year,
    required String sectionName,
  }) async {
    _ensureInitialized();
    await _prefs.setInt('student_id', id);
    await _prefs.setString('student_roll_no', rollNo);
    await _prefs.setString('student_name', name);
    await _prefs.setInt('student_year', year);
    await _prefs.setString('student_section', sectionName);
  }

  /// Get student roll number
  String? getStudentRollNo() {
    _ensureInitialized();
    return _prefs.getString('student_roll_no');
  }

  /// Get student name
  String? getStudentName() {
    _ensureInitialized();
    return _prefs.getString('student_name');
  }

  /// Get student year
  int? getStudentYear() {
    _ensureInitialized();
    return _prefs.getInt('student_year');
  }

  /// Get student section
  String? getStudentSection() {
    _ensureInitialized();
    return _prefs.getString('student_section');
  }

  // ==================== PARENT INFO ====================

  /// Save parent information
  Future<void> saveParentInfo({
    required String name,
    String? phone,
    String? email,
  }) async {
    _ensureInitialized();
    await _prefs.setString('parent_name', name);
    if (phone != null && phone.isNotEmpty) {
      await _prefs.setString('parent_phone', phone);
    }
    if (email != null && email.isNotEmpty) {
      await _prefs.setString('parent_email', email);
    }
  }

  /// Get parent name
  String? getParentName() {
    _ensureInitialized();
    return _prefs.getString('parent_name');
  }

  /// Get parent phone
  String? getParentPhone() {
    _ensureInitialized();
    return _prefs.getString('parent_phone');
  }

  /// Get parent email
  String? getParentEmail() {
    _ensureInitialized();
    return _prefs.getString('parent_email');
  }

  // ==================== FCM TOKEN ====================

  /// Save FCM token
  Future<void> saveFcmToken(String token) async {
    _ensureInitialized();
    await _prefs.setString('fcm_token', token);
    await _prefs.setString(
      'fcm_token_updated_at',
      DateTime.now().toIso8601String(),
    );
  }

  /// Get FCM token
  String? getFcmToken() {
    _ensureInitialized();
    return _prefs.getString('fcm_token');
  }

  /// Get FCM token last updated time
  DateTime? getFcmTokenUpdatedAt() {
    _ensureInitialized();
    final dateStr = _prefs.getString('fcm_token_updated_at');
    if (dateStr != null) {
      return DateTime.parse(dateStr);
    }
    return null;
  }

  // ==================== APP STATE ====================

  /// Check if first launch
  bool isFirstLaunch() {
    _ensureInitialized();
    return _prefs.getBool('first_launch') ?? true;
  }

  /// Set first launch complete
  Future<void> setFirstLaunchComplete() async {
    _ensureInitialized();
    await _prefs.setBool('first_launch', false);
  }

  /// Check if user is registered
  bool isUserRegistered() {
    _ensureInitialized();
    return _prefs.getInt('student_id') != null &&
        _prefs.getString('parent_name') != null;
  }

  // ==================== NOTIFICATIONS SETTINGS ====================

  /// Enable/disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    _ensureInitialized();
    await _prefs.setBool('notifications_enabled', enabled);
  }

  /// Check if notifications are enabled
  bool areNotificationsEnabled() {
    _ensureInitialized();
    return _prefs.getBool('notifications_enabled') ?? true;
  }

  /// Save last notification time
  Future<void> saveLastNotificationTime(DateTime time) async {
    _ensureInitialized();
    await _prefs.setString('last_notification_time', time.toIso8601String());
  }

  /// Get last notification time
  DateTime? getLastNotificationTime() {
    _ensureInitialized();
    final timeStr = _prefs.getString('last_notification_time');
    if (timeStr != null) {
      return DateTime.parse(timeStr);
    }
    return null;
  }

  // ==================== CACHE MANAGEMENT ====================

  /// Save cached data (generic)
  Future<void> saveCache(String key, Map<String, dynamic> data) async {
    _ensureInitialized();
    await _prefs.setString(key, jsonEncode(data));
    await _prefs.setString(
      '${key}_cached_at',
      DateTime.now().toIso8601String(),
    );
  }

  /// Get cached data (generic)
  Map<String, dynamic>? getCache(String key) {
    _ensureInitialized();
    final dataStr = _prefs.getString(key);
    if (dataStr != null) {
      return jsonDecode(dataStr) as Map<String, dynamic>;
    }
    return null;
  }

  /// Check if cache is valid (not older than duration)
  bool isCacheValid(String key, Duration maxAge) {
    _ensureInitialized();
    final cachedAtStr = _prefs.getString('${key}_cached_at');
    if (cachedAtStr == null) return false;

    final cachedAt = DateTime.parse(cachedAtStr);
    final age = DateTime.now().difference(cachedAt);
    return age <= maxAge;
  }

  /// Clear specific cache
  Future<void> clearCache(String key) async {
    _ensureInitialized();
    await _prefs.remove(key);
    await _prefs.remove('${key}_cached_at');
  }

  // ==================== APP PREFERENCES ====================

  /// Save theme mode
  Future<void> saveThemeMode(String mode) async {
    _ensureInitialized();
    await _prefs.setString('theme_mode', mode);
  }

  /// Get theme mode
  String getThemeMode() {
    _ensureInitialized();
    return _prefs.getString('theme_mode') ?? 'system';
  }

  /// Save language
  Future<void> saveLanguage(String languageCode) async {
    _ensureInitialized();
    await _prefs.setString('language', languageCode);
  }

  /// Get language
  String getLanguage() {
    _ensureInitialized();
    return _prefs.getString('language') ?? 'en';
  }

  // ==================== STATISTICS ====================

  /// Increment app open count
  Future<void> incrementAppOpenCount() async {
    _ensureInitialized();
    final count = _prefs.getInt('app_open_count') ?? 0;
    await _prefs.setInt('app_open_count', count + 1);
    await _prefs.setString(
      'last_app_open',
      DateTime.now().toIso8601String(),
    );
  }

  /// Get app open count
  int getAppOpenCount() {
    _ensureInitialized();
    return _prefs.getInt('app_open_count') ?? 0;
  }

  /// Get last app open time
  DateTime? getLastAppOpenTime() {
    _ensureInitialized();
    final timeStr = _prefs.getString('last_app_open');
    if (timeStr != null) {
      return DateTime.parse(timeStr);
    }
    return null;
  }

  // ==================== DATA MANAGEMENT ====================

  /// Clear all user data (logout)
  Future<void> clearUserData() async {
    _ensureInitialized();

    // Keys to preserve
    final preserveKeys = [
      'first_launch',
      'app_open_count',
      'theme_mode',
      'language',
    ];

    // Get all keys
    final keys = _prefs.getKeys();

    // Remove all except preserved keys
    for (final key in keys) {
      if (!preserveKeys.contains(key)) {
        await _prefs.remove(key);
      }
    }
  }

  /// Clear all data including app state
  Future<void> clearAll() async {
    _ensureInitialized();
    await _prefs.clear();
  }

  /// Get all stored keys (for debugging)
  Set<String> getAllKeys() {
    _ensureInitialized();
    return _prefs.getKeys();
  }

  /// Export all data as JSON (for debugging/backup)
  Map<String, dynamic> exportData() {
    _ensureInitialized();
    final data = <String, dynamic>{};
    for (final key in _prefs.getKeys()) {
      data[key] = _prefs.get(key);
    }
    return data;
  }

  /// Check storage size (approximate)
  int getApproximateSize() {
    _ensureInitialized();
    int totalSize = 0;
    for (final key in _prefs.getKeys()) {
      final value = _prefs.get(key);
      if (value is String) {
        totalSize += value.length;
      }
    }
    return totalSize;
  }
}
