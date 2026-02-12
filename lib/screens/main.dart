import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ==================== FIREBASE OPTIONS ====================
// Replace these with your actual Firebase configuration
class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAxSS5B5Daanx1CjkIAoxy4bHaLsvsKa5k',
    appId: '1:1013486873658:android:592719c9fc8cfbd7c29903',
    messagingSenderId: '1013486873658',
    projectId: 'loyola-8b679',
    storageBucket: 'loyola-8b679.firebasestorage.app',
  );
}

// ==================== CONFIGURATION ====================
const String API_BASE_URL = 'https://moises-epideictic-delpha.ngrok-free.dev'; // REPLACE WITH YOUR SERVER IP

// ==================== BACKGROUND MESSAGE HANDLER ====================
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  print('Background message: ${message.notification?.title}');
}

// ==================== MAIN FUNCTION ====================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(const AttendanceApp());
}

// ==================== MODELS ====================
class Student {
  final int id;
  final String rollNo;
  final String name;
  final String sectionName;
  final int year;

  Student({
    required this.id,
    required this.rollNo,
    required this.name,
    required this.sectionName,
    required this.year,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: int.parse(json['id']),
      rollNo: json['roll_no'],
      name: json['name'],
      sectionName: json['sectionName'] ?? json['section_name'] ?? 'Unknown',
      year: json['year'],
    );
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
      attendancePercentage: (json['attendancePercentage'] ?? 0.0).toDouble(),
    );
  }
}

class NotificationLog {
  final int id;
  final String studentName;
  final String rollNo;
  final String notificationType;
  final String status;
  final DateTime sentAt;

  NotificationLog({
    required this.id,
    required this.studentName,
    required this.rollNo,
    required this.notificationType,
    required this.status,
    required this.sentAt,
  });

  factory NotificationLog.fromJson(Map<String, dynamic> json) {
    return NotificationLog(
      id: int.parse(json['id']),
      studentName: json['student_name'],
      rollNo: json['roll_no'],
      notificationType: json['notification_type'],
      status: json['status'],
      sentAt: DateTime.parse(json['sent_at']),
    );
  }
}

class MonthlyData {
  final String month;
  final int totalDays;
  final int presentCount;
  final int totalMarked;
  final double percentage;

  MonthlyData({
    required this.month,
    required this.totalDays,
    required this.presentCount,
    required this.totalMarked,
    required this.percentage,
  });

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    final totalMarked = json['totalMarked'] ?? 0;
    final presentCount = json['presentCount'] ?? 0;
    return MonthlyData(
      month: json['month'],
      totalDays: json['totalDays'] ?? 0,
      presentCount: presentCount,
      totalMarked: totalMarked,
      percentage: totalMarked > 0 ? (presentCount / totalMarked * 100) : 0,
    );
  }
}

// New model for absence details
class AbsenceDetail {
  final DateTime date;
  final String type; // 'full' or 'partial'
  final int absentPeriods;
  final List<int> periods;

  AbsenceDetail({
    required this.date,
    required this.type,
    required this.absentPeriods,
    required this.periods,
  });
}

// ==================== TELUGU MONTH NAMES ====================
const Map<int, String> teluguMonths = {
  1: 'జనవరి',
  2: 'ఫిబ్రవరి',
  3: 'మార్చి',
  4: 'ఏప్రిల్',
  5: 'మే',
  6: 'జూన్',
  7: 'జూలై',
  8: 'ఆగస్టు',
  9: 'సెప్టెంబర్',
  10: 'అక్టోబర్',
  11: 'నవంబర్',
  12: 'డిసెంబర్',
};

// ==================== APP THEME ====================
class AppTheme {
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const successGradient = LinearGradient(
    colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const warningGradient = LinearGradient(
    colors: [Color(0xFFF2994A), Color(0xFFF2C94C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const dangerGradient = LinearGradient(
    colors: [Color(0xFFEB5757), Color(0xFFF27474)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.deepPurple,
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

// ==================== MAIN APP ====================
class AttendanceApp extends StatelessWidget {
  const AttendanceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Attendance',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

// ==================== SPLASH SCREEN ====================
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.delayed(const Duration(seconds: 2));
    
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getInt('student_id');
    
    if (!mounted) return;
    
    if (studentId != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DashboardScreen(studentId: studentId)),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.school,
                  size: 80,
                  color: Color(0xFF667eea),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Attendance Manager',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Stay connected with your child\'s attendance',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== LOGIN SCREEN ====================
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rollNoController = TextEditingController(); // CHANGED: from studentId to rollNo
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _rollNoController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final rollNo = _rollNoController.text.trim();
      
      // ENHANCEMENT 1: Search for student by roll number first
      final searchResponse = await http.get(
        Uri.parse('$API_BASE_URL/api/admin/students/search?q=$rollNo'),
      );

      if (searchResponse.statusCode != 200) {
        throw Exception('Failed to search for student');
      }

      final List<dynamic> searchResults = jsonDecode(searchResponse.body);
      
      if (searchResults.isEmpty) {
        throw Exception('No student found with roll number: $rollNo');
      }

      // Find exact match for roll number
      final studentData = searchResults.firstWhere(
        (s) => s['roll_no'].toString().toLowerCase() == rollNo.toLowerCase(),
        orElse: () => null,
      );

      if (studentData == null) {
        throw Exception('No exact match found for roll number: $rollNo');
      }

      final studentId =   int.parse(studentData['id']) as int;

      // Now get full student details
      final studentResponse = await http.get(
        Uri.parse('$API_BASE_URL/api/admin/students/$studentId'),
      );

      if (studentResponse.statusCode != 200) {
        throw Exception('Failed to fetch student details');
      }

      final fullStudentData = jsonDecode(studentResponse.body);
      final student = Student.fromJson(fullStudentData['student']);

      // Get FCM token
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        throw Exception('Failed to get FCM token');
      }

      // Register device with backend
      final registerResponse = await http.post(
        Uri.parse('$API_BASE_URL/api/parent/register-device'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'student_id': studentId,
          'fcm_token': fcmToken,
          'parent_name': _parentNameController.text.isEmpty ? null : _parentNameController.text,
          'parent_phone': _parentPhoneController.text.isEmpty ? null : _parentPhoneController.text,
          'device_info': {
            'platform': 'android',
            'app_version': '1.0.0',
          },
        }),
      );

      if (registerResponse.statusCode != 200 && registerResponse.statusCode != 201) {
        throw Exception('Failed to register device');
      }

      // Save student ID and other info
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('student_id', studentId);
      await prefs.setString('student_name', student.name);
      await prefs.setString('roll_no', student.rollNo);

      if (!mounted) return;

      // Navigate to dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DashboardScreen(studentId: studentId)),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Successfully registered for notifications!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.school,
                          size: 64,
                          color: Color(0xFF667eea),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Parent Login',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Enter student details to receive attendance notifications',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _rollNoController,
                          keyboardType: TextInputType.text, // CHANGED: from number to text
                          decoration: InputDecoration(
                            labelText: 'Student Roll Number', // CHANGED: label
                            prefixIcon: const Icon(Icons.confirmation_number),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter student roll number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _parentNameController,
                          decoration: InputDecoration(
                            labelText: 'Parent Name (Optional)',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _parentPhoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Phone Number (Optional)',
                            prefixIcon: const Icon(Icons.phone),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667eea),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Register & Continue',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== DASHBOARD SCREEN ====================
class DashboardScreen extends StatefulWidget {
  final int studentId;

  const DashboardScreen({Key? key, required this.studentId}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  Student? _student;
  AttendanceSummary? _summary;
  List<MonthlyData> _monthlyData = [];
  List<NotificationLog> _notifications = [];
  Map<String, Map<String, dynamic>> _absenceHistory = {}; // CHANGED: new structure
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _setupFCM();
    _loadData();
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        setState(() => _selectedIndex = 2);
      },
    );

    // Create notification channel
    const channel = AndroidNotificationChannel(
      'attendance_alerts',
      'Attendance Alerts',
      description: 'Notifications for student attendance',
      importance: Importance.high,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _setupFCM() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showLocalNotification(
          message.notification!.title ?? 'Attendance Alert',
          message.notification!.body ?? '',
        );
      }
      // Reload notifications
      _loadNotifications();
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      setState(() => _selectedIndex = 2);
    });
  }

  Future<void> _showLocalNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'attendance_alerts',
      'Attendance Alerts',
      channelDescription: 'Notifications for student attendance',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    await Future.wait([
      _loadStudentInfo(),
      _loadAttendanceSummary(),
      _loadMonthlyData(),
      _loadNotifications(),
    ]);
    
    setState(() => _isLoading = false);
  }

  Future<void> _loadStudentInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$API_BASE_URL/api/admin/students/${widget.studentId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _student = Student.fromJson(data['student']);
        });
      }
    } catch (e) {
      print('Error loading student info: $e');
    }
  }

  Future<void> _loadAttendanceSummary() async {
    try {
      final response = await http.get(
        Uri.parse('$API_BASE_URL/api/admin/students/${widget.studentId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _summary = AttendanceSummary.fromJson(data['attendanceSummary']);
        });
      }
    } catch (e) {
      print('Error loading attendance summary: $e');
    }
  }

  Future<void> _loadMonthlyData() async {
    try {
      final response = await http.get(
        Uri.parse('$API_BASE_URL/api/admin/students/${widget.studentId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> monthlyBreakdown = data['monthlyBreakdown'] ?? [];
        
        setState(() {
          _monthlyData = monthlyBreakdown.map((m) => MonthlyData.fromJson(m)).toList();
        });
      }
    } catch (e) {
      print('Error loading student info: $e');
    }
  }

  // ENHANCEMENT 2: Complete absence history with dates
  Future<void> _loadNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$API_BASE_URL/api/admin/students/${widget.studentId}/attendance-calendar'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        // Group absences by month with detailed dates
        Map<String, Map<String, dynamic>> monthlyAbsences = {};
        
        for (var record in data) {
          final dateStr = record['date'];
          final date = DateTime.parse(dateStr);
          final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
          
          if (!monthlyAbsences.containsKey(monthKey)) {
            monthlyAbsences[monthKey] = {
              'year': date.year,
              'month': date.month,
              'fullDayAbsences': <AbsenceDetail>[],
              'partialAbsences': <AbsenceDetail>[],
            };
          }
          
          final periods = [
            record['periods']['period_0'] ?? -1,
            record['periods']['period_1'] ?? -1,
            record['periods']['period_2'] ?? -1,
            record['periods']['period_3'] ?? -1,
            record['periods']['period_4'] ?? -1,
            record['periods']['period_5'] ?? -1,
            record['periods']['period_6'] ?? -1,
            record['periods']['period_7'] ?? -1,
          ];
          
          final markedPeriods = periods.where((p) => p != -1).toList();
          final absentPeriods = markedPeriods.where((p) => p == 0).length;
          
          if (markedPeriods.isNotEmpty && absentPeriods > 0) {
            final absenceDetail = AbsenceDetail(
              date: date,
              type: absentPeriods == markedPeriods.length ? 'full' : 'partial',
              absentPeriods: absentPeriods,
              periods: periods.cast<int>(),
            );
            
            if (absentPeriods == markedPeriods.length) {
              // Full day absent
              monthlyAbsences[monthKey]!['fullDayAbsences'].add(absenceDetail);
            } else {
              // Partial absent
              monthlyAbsences[monthKey]!['partialAbsences'].add(absenceDetail);
            }
          }
        }
        
        if (mounted) {
          setState(() {
            _absenceHistory = monthlyAbsences;
          });
        }
      }
    } catch (e) {
      print('Error loading absence history: $e');
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _selectedIndex,
              children: [
                _buildHomeTab(),
                _buildAnalyticsTab(),
                _buildNotificationsTab(),
                _buildProfileTab(),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF667eea),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // ==================== HOME TAB ====================
  Widget _buildHomeTab() {
    if (_student == null || _summary == null) {
      return const Center(child: Text('No data available'));
    }

    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome back,',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          Text(
                            _student!.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.school, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoItem('Roll No', _student!.rollNo),
                        Container(width: 1, height: 40, color: Colors.white30),
                        _buildInfoItem('Class', _student!.sectionName),
                        Container(width: 1, height: 40, color: Colors.white30),
                        _buildInfoItem('Year', _student!.year.toString()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Attendance Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: _summary!.attendancePercentage >= 75
                              ? AppTheme.successGradient
                              : AppTheme.dangerGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (_summary!.attendancePercentage >= 75
                                      ? Colors.blue
                                      : Colors.red)
                                  .withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Overall Attendance',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${_summary!.attendancePercentage.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_summary!.presentCount} / ${_summary!.totalMarked} periods',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Present',
                              _summary!.presentCount.toString(),
                              Icons.check_circle,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Absent',
                              (_summary!.totalMarked - _summary!.presentCount).toString(),
                              Icons.cancel,
                              Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total Days',
                              _summary!.totalDays.toString(),
                              Icons.calendar_today,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Marked',
                              _summary!.totalMarked.toString(),
                              Icons.fact_check,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ANALYTICS TAB ====================
  Widget _buildAnalyticsTab() {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Monthly Analytics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: _monthlyData.isEmpty
                    ? const Center(child: Text('No data available'))
                    : ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          // Chart
                          Container(
                            height: 300,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          '${value.toInt()}%',
                                          style: const TextStyle(fontSize: 10),
                                        );
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value.toInt() >= 0 &&
                                            value.toInt() < _monthlyData.length) {
                                          final month = _monthlyData[value.toInt()].month;
                                          final parts = month.split('-');
                                          return Text(
                                            parts.length > 1 ? parts[1] : month,
                                            style: const TextStyle(fontSize: 10),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: _monthlyData
                                        .asMap()
                                        .entries
                                        .map((e) => FlSpot(
                                            e.key.toDouble(), e.value.percentage))
                                        .toList(),
                                    isCurved: true,
                                    color: const Color(0xFF667eea),
                                    barWidth: 3,
                                    dotData: FlDotData(show: true),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: const Color(0xFF667eea).withOpacity(0.2),
                                    ),
                                  ),
                                ],
                                minY: 0,
                                maxY: 100,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Monthly breakdown
                          ..._monthlyData.map((data) => _buildMonthCard(data)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthCard(MonthlyData data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: data.percentage >= 75
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${data.percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: data.percentage >= 75 ? Colors.green : Colors.red,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.month,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.presentCount} / ${data.totalMarked} periods present',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            data.percentage >= 75 ? Icons.trending_up : Icons.trending_down,
            color: data.percentage >= 75 ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  // ==================== NOTIFICATIONS TAB (ENHANCED) ====================
  Widget _buildNotificationsTab() {
    // Sort months by date (most recent first)
    final sortedMonths = _absenceHistory.entries.toList()
      ..sort((a, b) {
        final aDate = DateTime(a.value['year'] as int, a.value['month'] as int);
        final bDate = DateTime(b.value['year'] as int, b.value['month'] as int);
        return bDate.compareTo(aDate);
      });

    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Absence History',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${sortedMonths.length} months',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: sortedMonths.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.celebration,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No absences recorded! 🎉',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: sortedMonths.length,
                        itemBuilder: (context, index) {
                          final entry = sortedMonths[index];
                          final monthData = entry.value;
                          final year = monthData['year'] as int;
                          final month = monthData['month'] as int;
                          final fullDayAbsences = monthData['fullDayAbsences'] as List<AbsenceDetail>;
                          final partialAbsences = monthData['partialAbsences'] as List<AbsenceDetail>;

                          return _buildMonthAbsenceCard(
                            year: year,
                            month: month,
                            fullDayAbsences: fullDayAbsences,
                            partialAbsences: partialAbsences,
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthAbsenceCard({
    required int year,
    required int month,
    required List<AbsenceDetail> fullDayAbsences,
    required List<AbsenceDetail> partialAbsences,
  }) {
    final teluguMonth = teluguMonths[month] ?? 'Unknown';
    final hasAbsences = fullDayAbsences.isNotEmpty || partialAbsences.isNotEmpty;

    if (!hasAbsences) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_month,
                    color: Colors.red,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teluguMonth,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        year.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, thickness: 1.5),
          
          // Absence Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (fullDayAbsences.isNotEmpty) ...[
                  _buildAbsenceSectionHeader(
                    icon: Icons.event_busy,
                    label: 'పూర్తి రోజు అవుట్',
                    count: fullDayAbsences.length,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  ...fullDayAbsences.map((absence) => _buildAbsenceDateItem(absence)),
                  if (partialAbsences.isNotEmpty) const SizedBox(height: 16),
                ],
                
                if (partialAbsences.isNotEmpty) ...[
                  _buildAbsenceSectionHeader(
                    icon: Icons.access_time,
                    label: 'కొన్ని పీరియడ్లు అవుట్',
                    count: partialAbsences.length,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  ...partialAbsences.map((absence) => _buildAbsenceDateItem(absence)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsenceSectionHeader({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAbsenceDateItem(AbsenceDetail absence) {
    final dateFormat = DateFormat('dd MMMM, yyyy (EEEE)');
    final isFullDay = absence.type == 'full';
    
    // Get absent period numbers
    List<String> absentPeriodNumbers = [];
    for (int i = 0; i < absence.periods.length; i++) {
      if (absence.periods[i] == 0) {
        absentPeriodNumbers.add('P$i');
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFullDay ? Colors.red.withOpacity(0.05) : Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFullDay ? Colors.red.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isFullDay ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.calendar_today,
              size: 16,
              color: isFullDay ? Colors.red : Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateFormat.format(absence.date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                if (!isFullDay) ...[
                  Text(
                    'Absent periods: ${absentPeriodNumbers.join(', ')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${absence.absentPeriods} period${absence.absentPeriods > 1 ? 's' : ''} absent',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ] else ...[
                  Text(
                    'Full day absent',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PROFILE TAB ====================
  Widget _buildProfileTab() {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Profile Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  _student?.name.substring(0, 1).toUpperCase() ?? 'S',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _student?.name ?? 'Student',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Roll No: ${_student?.rollNo ?? 'N/A'}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            _buildProfileInfo('Class', _student?.sectionName ?? 'N/A'),
                            _buildProfileInfo('Year', _student?.year.toString() ?? 'N/A'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Settings
                      _buildSettingItem(
                        'Refresh Data',
                        Icons.refresh,
                        () => _loadData(),
                      ),
                      _buildSettingItem(
                        'Notification Settings',
                        Icons.notifications_active,
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notification settings coming soon!'),
                            ),
                          );
                        },
                      ),
                      _buildSettingItem(
                        'About',
                        Icons.info,
                        () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('About'),
                              content: const Text(
                                'Attendance Manager v1.0.0\n\n'
                                'Stay connected with your child\'s attendance in real-time.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      _buildSettingItem(
                        'Logout',
                        Icons.logout,
                        () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Logout'),
                              content: const Text('Are you sure you want to logout?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _logout();
                                  },
                                  child: const Text('Logout', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : const Color(0xFF667eea)),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDestructive ? Colors.red : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
