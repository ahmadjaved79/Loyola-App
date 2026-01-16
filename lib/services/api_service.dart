import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student.dart';
import '../models/attendance.dart';
import '../models/notification.dart';
import '../models/device.dart';

class ApiService {
  // CHANGE THIS TO YOUR LOCAL IP ADDRESS
  static const String baseUrl = 'http://192.168.9.167:3001/api';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ==================== DEVICE REGISTRATION ====================

  /// Register parent device with FCM token
  Future<ApiResponse<DeviceRegistration>> registerDevice({
    required int studentId,
    required String fcmToken,
    String? parentName,
    String? parentPhone,
    String? parentEmail,
    Map<String, dynamic>? deviceInfo,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/parent/register-device'),
        headers: _headers,
        body: jsonEncode({
          'student_id': studentId,
          'fcm_token': fcmToken,
          'parent_name': parentName,
          'parent_phone': parentPhone,
          'parent_email': parentEmail,
          'device_info': deviceInfo,
        }),
      );

      return _handleResponse<DeviceRegistration>(
        response,
        (data) => DeviceRegistration.fromJson(data),
      );
    } catch (e) {
      return ApiResponse.error('Failed to register device: $e');
    }
  }

  /// Get all devices for a student
  Future<ApiResponse<List<ParentDevice>>> getDevices(int studentId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/parent/devices/$studentId'),
        headers: _headers,
      );

      return _handleResponse<List<ParentDevice>>(
        response,
        (data) {
          final devices = data['devices'] as List;
          return devices.map((d) => ParentDevice.fromJson(d)).toList();
        },
      );
    } catch (e) {
      return ApiResponse.error('Failed to fetch devices: $e');
    }
  }

  /// Deactivate device
  Future<ApiResponse<void>> deactivateDevice(int deviceId) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/parent/devices/$deviceId/deactivate'),
        headers: _headers,
      );

      return _handleResponse<void>(response, (_) => null);
    } catch (e) {
      return ApiResponse.error('Failed to deactivate device: $e');
    }
  }

  // ==================== STUDENT OPERATIONS ====================

  /// Get student profile by ID
  Future<ApiResponse<StudentProfile>> getStudentProfile(int studentId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/admin/students/$studentId'),
        headers: _headers,
      );

      return _handleResponse<StudentProfile>(
        response,
        (data) => StudentProfile.fromJson(data),
      );
    } catch (e) {
      return ApiResponse.error('Failed to fetch student profile: $e');
    }
  }

  /// Search student by roll number
  Future<ApiResponse<List<Student>>> searchStudent(String query) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/admin/students/search?q=$query'),
        headers: _headers,
      );

      return _handleResponse<List<Student>>(
        response,
        (data) {
          if (data is List) {
            return data.map((s) => Student.fromJson(s)).toList();
          }
          return [];
        },
      );
    } catch (e) {
      return ApiResponse.error('Failed to search student: $e');
    }
  }

  // ==================== ATTENDANCE OPERATIONS ====================

  /// Get attendance calendar for a student
  Future<ApiResponse<List<AttendanceRecord>>> getAttendanceCalendar({
    required int studentId,
    int? month,
    int? year,
  }) async {
    try {
      String url = '$baseUrl/admin/students/$studentId/attendance-calendar';

      if (month != null && year != null) {
        url += '?month=$month&year=$year';
      }

      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );

      return _handleResponse<List<AttendanceRecord>>(
        response,
        (data) {
          if (data is List) {
            return data.map((a) => AttendanceRecord.fromJson(a)).toList();
          }
          return [];
        },
      );
    } catch (e) {
      return ApiResponse.error('Failed to fetch attendance: $e');
    }
  }

  /// Get attendance summary for date range
  Future<ApiResponse<AttendanceSummary>> getAttendanceSummary({
    required int studentId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final profile = await getStudentProfile(studentId);

      if (!profile.success) {
        return ApiResponse.error(profile.message);
      }

      return ApiResponse.success(
        data: AttendanceSummary(
          totalDays: profile.data!.attendanceSummary.totalDays,
          presentCount: profile.data!.attendanceSummary.presentCount,
          totalMarked: profile.data!.attendanceSummary.totalMarked,
          attendancePercentage:
              profile.data!.attendanceSummary.attendancePercentage,
        ),
        message: 'Attendance summary fetched successfully',
      );
    } catch (e) {
      return ApiResponse.error('Failed to fetch summary: $e');
    }
  }

  // ==================== NOTIFICATION OPERATIONS ====================

  /// Get notification logs for a student
  Future<ApiResponse<List<NotificationLog>>> getNotificationLogs({
    required int studentId,
    String? startDate,
    String? endDate,
    String? status,
    int limit = 50,
    int page = 1,
  }) async {
    try {
      String url =
          '$baseUrl/notifications/logs?student_id=$studentId&limit=$limit&page=$page';

      if (startDate != null) url += '&start_date=$startDate';
      if (endDate != null) url += '&end_date=$endDate';
      if (status != null) url += '&status=$status';

      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );

      return _handleResponse<List<NotificationLog>>(
        response,
        (data) {
          final logs = data['logs'] as List;
          return logs.map((l) => NotificationLog.fromJson(l)).toList();
        },
      );
    } catch (e) {
      return ApiResponse.error('Failed to fetch notifications: $e');
    }
  }

  /// Test FCM token
  Future<ApiResponse<void>> testFcmToken({
    required String fcmToken,
    String? testMessage,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/notifications/test-token'),
        headers: _headers,
        body: jsonEncode({
          'fcm_token': fcmToken,
          'test_message': testMessage,
        }),
      );

      return _handleResponse<void>(response, (_) => null);
    } catch (e) {
      return ApiResponse.error('Failed to test token: $e');
    }
  }

  /// Get notification statistics
  Future<ApiResponse<NotificationStats>> getNotificationStats({
    String? startDate,
    String? endDate,
  }) async {
    try {
      String url = '$baseUrl/notifications/stats';

      if (startDate != null && endDate != null) {
        url += '?start_date=$startDate&end_date=$endDate';
      }

      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );

      return _handleResponse<NotificationStats>(
        response,
        (data) => NotificationStats.fromJson(data),
      );
    } catch (e) {
      return ApiResponse.error('Failed to fetch stats: $e');
    }
  }

  // ==================== HELPER METHODS ====================

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic) parser,
  ) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      final data = jsonDecode(response.body);

      try {
        return ApiResponse.success(
          data: parser(data),
          message: data['message'] ?? 'Success',
        );
      } catch (e) {
        return ApiResponse.error('Failed to parse response: $e');
      }
    } else {
      final error = jsonDecode(response.body);
      return ApiResponse.error(
        error['error'] ?? 'Request failed with status $statusCode',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

// ==================== API RESPONSE MODEL ====================

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;

  ApiResponse._({
    required this.success,
    this.data,
    required this.message,
  });

  factory ApiResponse.success({
    required T data,
    required String message,
  }) {
    return ApiResponse._(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error(String message) {
    return ApiResponse._(
      success: false,
      message: message,
    );
  }
}
