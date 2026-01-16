// lib/models/attendance.dart

class AttendanceRecord {
  final String date;
  final int? dayOrder;
  final Map<String, int> periods; // period_0 to period_7
  final int? markedPeriods;
  final int? presentPeriods;
  final double? attendanceRate;

  AttendanceRecord({
    required this.date,
    this.dayOrder,
    required this.periods,
    this.markedPeriods,
    this.presentPeriods,
    this.attendanceRate,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    Map<String, int> periods = {};

    if (json['periods'] != null) {
      final periodsData = json['periods'] as Map<String, dynamic>;
      periods = periodsData.map((key, value) => MapEntry(key, value as int));
    } else {
      // Fallback for direct period fields
      for (int i = 0; i <= 7; i++) {
        final key = 'period_$i';
        if (json.containsKey(key)) {
          periods[key] = json[key] ?? -1;
        }
      }
    }

    return AttendanceRecord(
      date: json['date'],
      dayOrder: json['day_order'] ?? json['dayOrder'],
      periods: periods,
      markedPeriods: json['markedPeriods'],
      presentPeriods: json['presentPeriods'],
      attendanceRate: json['attendanceRate']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'dayOrder': dayOrder,
      'periods': periods,
      'markedPeriods': markedPeriods,
      'presentPeriods': presentPeriods,
      'attendanceRate': attendanceRate,
    };
  }

  int get totalPresent {
    return periods.values.where((v) => v == 1).length;
  }

  int get totalAbsent {
    return periods.values.where((v) => v == 0).length;
  }

  int get totalMarked {
    return periods.values.where((v) => v != -1).length;
  }

  double get percentage {
    final marked = totalMarked;
    if (marked == 0) return 0.0;
    return (totalPresent / marked) * 100;
  }

  String get statusText {
    final pct = percentage;
    if (pct >= 90) return 'Excellent';
    if (pct >= 75) return 'Good';
    if (pct >= 60) return 'Fair';
    return 'Poor';
  }

  // Get period status (-1: not marked, 0: absent, 1: present)
  int getPeriodStatus(int periodNumber) {
    return periods['period_$periodNumber'] ?? -1;
  }
}

class AttendanceSummary {
  final int totalDays;
  final int presentCount;
  final int totalMarked;
  final double attendancePercentage;

  AttendanceSummary({
    required this.totalDays,
    required this.presentCount,
    required this.totalMarked,
    required this.attendancePercentage,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      totalDays: json['totalDays'] ?? 0,
      presentCount: json['presentCount'] ?? 0,
      totalMarked: json['totalMarked'] ?? 0,
      attendancePercentage: (json['attendancePercentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDays': totalDays,
      'presentCount': presentCount,
      'totalMarked': totalMarked,
      'attendancePercentage': attendancePercentage,
    };
  }

  int get absentCount => totalMarked - presentCount;

  String get statusText {
    if (attendancePercentage >= 90) return 'Excellent';
    if (attendancePercentage >= 75) return 'Good';
    if (attendancePercentage >= 60) return 'Fair';
    return 'Critical';
  }

  bool get isCritical => attendancePercentage < 75;
  bool get isGood => attendancePercentage >= 75;
  bool get isExcellent => attendancePercentage >= 90;
}

class MonthlyBreakdown {
  final String month;
  final int totalDays;
  final int presentCount;
  final int totalMarked;
  final double attendancePercentage;

  MonthlyBreakdown({
    required this.month,
    required this.totalDays,
    required this.presentCount,
    required this.totalMarked,
    required this.attendancePercentage,
  });

  factory MonthlyBreakdown.fromJson(Map<String, dynamic> json) {
    return MonthlyBreakdown(
      month: json['month'],
      totalDays: json['totalDays'],
      presentCount: json['presentCount'],
      totalMarked: json['totalMarked'],
      attendancePercentage: json['attendancePercentage'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'totalDays': totalDays,
      'presentCount': presentCount,
      'totalMarked': totalMarked,
      'attendancePercentage': attendancePercentage,
    };
  }

  int get absentCount => totalMarked - presentCount;
}
