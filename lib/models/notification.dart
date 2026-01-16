// lib/models/notification.dart

class NotificationLog {
  final int id;
  final int studentId;
  final String studentName;
  final String rollNo;
  final int? parentDeviceId;
  final String? parentName;
  final String? parentPhone;
  final int? attendanceRecordId;
  final String notificationType;
  final String status;
  final String? errorMessage;
  final DateTime sentAt;

  NotificationLog({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.rollNo,
    this.parentDeviceId,
    this.parentName,
    this.parentPhone,
    this.attendanceRecordId,
    required this.notificationType,
    required this.status,
    this.errorMessage,
    required this.sentAt,
  });

  factory NotificationLog.fromJson(Map<String, dynamic> json) {
    return NotificationLog(
      id: json['id'],
      studentId: json['student_id'],
      studentName: json['student_name'],
      rollNo: json['roll_no'],
      parentDeviceId: json['parent_device_id'],
      parentName: json['parent_name'],
      parentPhone: json['parent_phone'],
      attendanceRecordId: json['attendance_record_id'],
      notificationType: json['notification_type'],
      status: json['status'],
      errorMessage: json['error_message'],
      sentAt: DateTime.parse(json['sent_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'roll_no': rollNo,
      'parent_device_id': parentDeviceId,
      'parent_name': parentName,
      'parent_phone': parentPhone,
      'attendance_record_id': attendanceRecordId,
      'notification_type': notificationType,
      'status': status,
      'error_message': errorMessage,
      'sent_at': sentAt.toIso8601String(),
    };
  }

  bool get isSuccess => status == 'sent' || status == 'delivered';
  bool get isFailed => status == 'failed';
  bool get isPending => status == 'pending';

  String get displayTitle {
    switch (notificationType.toLowerCase()) {
      case 'absence':
        return 'Absence Alert';
      case 'late':
        return 'Late Arrival';
      case 'custom':
        return 'Notification';
      default:
        return 'Attendance Update';
    }
  }
}

class NotificationStats {
  final int totalNotifications;
  final int sentCount;
  final int failedCount;
  final int deliveredCount;
  final int uniqueStudents;
  final int uniqueDevices;

  NotificationStats({
    required this.totalNotifications,
    required this.sentCount,
    required this.failedCount,
    required this.deliveredCount,
    required this.uniqueStudents,
    required this.uniqueDevices,
  });

  factory NotificationStats.fromJson(Map<String, dynamic> json) {
    return NotificationStats(
      totalNotifications: int.parse(json['total_notifications'].toString()),
      sentCount: int.parse(json['sent_count'].toString()),
      failedCount: int.parse(json['failed_count'].toString()),
      deliveredCount: int.parse(json['delivered_count'].toString()),
      uniqueStudents: int.parse(json['unique_students'].toString()),
      uniqueDevices: int.parse(json['unique_devices'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_notifications': totalNotifications,
      'sent_count': sentCount,
      'failed_count': failedCount,
      'delivered_count': deliveredCount,
      'unique_students': uniqueStudents,
      'unique_devices': uniqueDevices,
    };
  }

  double get successRate {
    if (totalNotifications == 0) return 0.0;
    return (sentCount / totalNotifications) * 100;
  }

  double get failureRate {
    if (totalNotifications == 0) return 0.0;
    return (failedCount / totalNotifications) * 100;
  }
}
