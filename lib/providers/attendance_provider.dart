// lib/providers/attendance_provider.dart
import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocalStorageService _storage = LocalStorageService();

  List<AttendanceRecord> _attendanceRecords = [];
  AttendanceSummary? _summary;
  bool _isLoading = false;
  String? _error;

  // Current filter state
  int? _currentMonth;
  int? _currentYear;

  // Getters
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  AttendanceSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasAttendance => _attendanceRecords.isNotEmpty;

  int? get currentMonth => _currentMonth;
  int? get currentYear => _currentYear;

  /// Load attendance calendar for a specific month/year
  Future<bool> loadAttendanceCalendar({int? month, int? year}) async {
    final studentId = _storage.getStudentId();
    if (studentId == null) {
      _error = 'No student registered';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    _currentMonth = month;
    _currentYear = year;
    notifyListeners();

    try {
      final response = await _apiService.getAttendanceCalendar(
        studentId: studentId,
        month: month,
        year: year,
      );

      if (response.success) {
        _attendanceRecords = response.data!;

        // Sort by date descending (most recent first)
        _attendanceRecords.sort((a, b) {
          return DateTime.parse(b.date).compareTo(DateTime.parse(a.date));
        });

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to load attendance: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load attendance summary
  Future<bool> loadSummary() async {
    final studentId = _storage.getStudentId();
    if (studentId == null) return false;

    try {
      final response = await _apiService.getAttendanceSummary(
        studentId: studentId,
      );

      if (response.success) {
        _summary = response.data;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Failed to load summary: $e');
      return false;
    }
  }

  /// Refresh current attendance data
  Future<void> refresh() async {
    await Future.wait([
      loadAttendanceCalendar(month: _currentMonth, year: _currentYear),
      loadSummary(),
    ]);
  }

  /// Get attendance for a specific date
  AttendanceRecord? getAttendanceForDate(DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];
    try {
      return _attendanceRecords.firstWhere(
        (record) => record.date.startsWith(dateStr),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get attendance records for a date range
  List<AttendanceRecord> getAttendanceForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _attendanceRecords.where((record) {
      final recordDate = DateTime.parse(record.date);
      return recordDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          recordDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Calculate statistics for current records
  Map<String, dynamic> getStatistics() {
    if (_attendanceRecords.isEmpty) {
      return {
        'totalDays': 0,
        'totalPresent': 0,
        'totalAbsent': 0,
        'averagePercentage': 0.0,
        'bestDay': null,
        'worstDay': null,
      };
    }

    int totalPresent = 0;
    int totalAbsent = 0;
    int totalMarked = 0;
    AttendanceRecord? bestDay;
    AttendanceRecord? worstDay;

    for (final record in _attendanceRecords) {
      totalPresent += record.totalPresent;
      totalAbsent += record.totalAbsent;
      totalMarked += record.totalMarked;

      if (record.totalMarked > 0) {
        if (bestDay == null || record.percentage > bestDay.percentage) {
          bestDay = record;
        }
        if (worstDay == null || record.percentage < worstDay.percentage) {
          worstDay = record;
        }
      }
    }

    final avgPercentage =
        totalMarked > 0 ? (totalPresent / totalMarked) * 100 : 0.0;

    return {
      'totalDays': _attendanceRecords.length,
      'totalPresent': totalPresent,
      'totalAbsent': totalAbsent,
      'totalMarked': totalMarked,
      'averagePercentage': avgPercentage,
      'bestDay': bestDay,
      'worstDay': worstDay,
    };
  }

  /// Get attendance trend (last 7 days)
  List<Map<String, dynamic>> getWeeklyTrend() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final weekRecords = getAttendanceForDateRange(weekAgo, now);

    return weekRecords.map((record) {
      return {
        'date': record.date,
        'percentage': record.percentage,
        'present': record.totalPresent,
        'absent': record.totalAbsent,
      };
    }).toList();
  }

  /// Get monthly attendance rate
  double getMonthlyAttendanceRate() {
    if (_attendanceRecords.isEmpty) return 0.0;

    int totalPresent = 0;
    int totalMarked = 0;

    for (final record in _attendanceRecords) {
      totalPresent += record.totalPresent;
      totalMarked += record.totalMarked;
    }

    return totalMarked > 0 ? (totalPresent / totalMarked) * 100 : 0.0;
  }

  /// Get attendance status color
  static Color getStatusColor(double percentage) {
    if (percentage >= 90) return const Color(0xFF4CAF50); // Green
    if (percentage >= 75) return const Color(0xFF2196F3); // Blue
    if (percentage >= 60) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }

  /// Clear attendance data
  void clearAttendance() {
    _attendanceRecords = [];
    _summary = null;
    _error = null;
    _currentMonth = null;
    _currentYear = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
