// lib/models/device.dart
import 'student.dart';

class DeviceRegistration {
  final bool success;
  final String message;
  final String action; // 'created' or 'updated'
  final ParentDevice device;
  final Student student;

  DeviceRegistration({
    required this.success,
    required this.message,
    required this.action,
    required this.device,
    required this.student,
  });

  factory DeviceRegistration.fromJson(Map<String, dynamic> json) {
    return DeviceRegistration(
      success: json['success'],
      message: json['message'],
      action: json['action'],
      device: ParentDevice.fromJson(json['device']),
      student: Student.fromJson(json['student']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'action': action,
      'device': device.toJson(),
      'student': student.toJson(),
    };
  }

  bool get isNewDevice => action == 'created';
  bool get isUpdated => action == 'updated';
}

class ParentDevice {
  final int id;
  final int studentId;
  final String fcmToken;
  final String? parentName;
  final String? parentPhone;
  final String? parentEmail;
  final Map<String, dynamic>? deviceInfo;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastNotificationSent;

  ParentDevice({
    required this.id,
    required this.studentId,
    required this.fcmToken,
    this.parentName,
    this.parentPhone,
    this.parentEmail,
    this.deviceInfo,
    required this.isActive,
    required this.createdAt,
    this.lastNotificationSent,
  });

  factory ParentDevice.fromJson(Map<String, dynamic> json) {
    return ParentDevice(
      id: json['id'],
      studentId: json['student_id'],
      fcmToken: json['fcm_token'],
      parentName: json['parent_name'],
      parentPhone: json['parent_phone'],
      parentEmail: json['parent_email'],
      deviceInfo: json['device_info'] as Map<String, dynamic>?,
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      lastNotificationSent: json['last_notification_sent'] != null
          ? DateTime.parse(json['last_notification_sent'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'fcm_token': fcmToken,
      'parent_name': parentName,
      'parent_phone': parentPhone,
      'parent_email': parentEmail,
      'device_info': deviceInfo,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'last_notification_sent': lastNotificationSent?.toIso8601String(),
    };
  }

  String get devicePlatform {
    if (deviceInfo != null && deviceInfo!.containsKey('platform')) {
      return deviceInfo!['platform'] as String;
    }
    return 'Unknown';
  }

  String get deviceModel {
    if (deviceInfo != null && deviceInfo!.containsKey('model')) {
      return deviceInfo!['model'] as String;
    }
    return 'Unknown';
  }

  Duration? get timeSinceLastNotification {
    if (lastNotificationSent != null) {
      return DateTime.now().difference(lastNotificationSent!);
    }
    return null;
  }

  bool get hasRecentNotification {
    final timeSince = timeSinceLastNotification;
    if (timeSince != null) {
      return timeSince.inHours < 24;
    }
    return false;
  }
}
