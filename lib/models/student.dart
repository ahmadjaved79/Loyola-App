// lib/models/student.dart
import 'attendance.dart';

class Student {
  final int id;
  final String rollNo;
  final String name;
  final int sectionId;
  final int year;
  final String? sectionName;

  Student({
    required this.id,
    required this.rollNo,
    required this.name,
    required this.sectionId,
    required this.year,
    this.sectionName,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      rollNo: json['roll_no'],
      name: json['name'],
      sectionId: json['section_id'],
      year: json['year'],
      sectionName: json['section_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roll_no': rollNo,
      'name': name,
      'section_id': sectionId,
      'year': year,
      'section_name': sectionName,
    };
  }

  // Copy with method for updates
  Student copyWith({
    int? id,
    String? rollNo,
    String? name,
    int? sectionId,
    int? year,
    String? sectionName,
  }) {
    return Student(
      id: id ?? this.id,
      rollNo: rollNo ?? this.rollNo,
      name: name ?? this.name,
      sectionId: sectionId ?? this.sectionId,
      year: year ?? this.year,
      sectionName: sectionName ?? this.sectionName,
    );
  }
}

class StudentProfile {
  final Student student;
  final AttendanceSummary attendanceSummary;
  final List<MonthlyBreakdown> monthlyBreakdown;
  final List<AttendanceRecord> recentAttendance;

  StudentProfile({
    required this.student,
    required this.attendanceSummary,
    required this.monthlyBreakdown,
    required this.recentAttendance,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      student: Student.fromJson(json['student']),
      attendanceSummary: AttendanceSummary.fromJson(json['attendanceSummary']),
      monthlyBreakdown: (json['monthlyBreakdown'] as List)
          .map((m) => MonthlyBreakdown.fromJson(m))
          .toList(),
      recentAttendance: (json['recentAttendance'] as List)
          .map((a) => AttendanceRecord.fromJson(a))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student': student.toJson(),
      'attendanceSummary': attendanceSummary.toJson(),
      'monthlyBreakdown': monthlyBreakdown.map((m) => m.toJson()).toList(),
      'recentAttendance': recentAttendance.map((a) => a.toJson()).toList(),
    };
  }
}
