// lib/providers/student_provider.dart
import 'package:flutter/foundation.dart';
import '../models/student.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class StudentProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocalStorageService _storage = LocalStorageService();

  StudentProfile? _studentProfile;
  bool _isLoading = false;
  String? _error;

  // Getters
  StudentProfile? get studentProfile => _studentProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasStudent => _studentProfile != null;

  // Get student basic info
  Student? get student => _studentProfile?.student;

  /// Load student profile from server
  Future<bool> loadStudentProfile() async {
    final studentId = _storage.getStudentId();
    if (studentId == null) {
      _error = 'No student registered';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getStudentProfile(studentId);

      if (response.success) {
        _studentProfile = response.data;

        // Save student details locally
        if (_studentProfile != null) {
          await _storage.saveStudentDetails(
            id: _studentProfile!.student.id,
            rollNo: _studentProfile!.student.rollNo,
            name: _studentProfile!.student.name,
            year: _studentProfile!.student.year,
            sectionName: _studentProfile!.student.sectionName ?? '',
          );
        }

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
      _error = 'Failed to load profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Search student by roll number and set as current student
  Future<bool> searchAndSetStudent(String rollNo) async {
    if (rollNo.trim().isEmpty) {
      _error = 'Please enter roll number';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.searchStudent(rollNo.trim());

      if (response.success && response.data!.isNotEmpty) {
        final student = response.data!.first;

        // Save student ID
        await _storage.saveStudentId(student.id);

        // Load full profile
        await loadStudentProfile();

        return true;
      } else {
        _error = 'Student not found with roll number: $rollNo';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Search failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Refresh student profile
  Future<void> refreshProfile() async {
    await loadStudentProfile();
  }

  /// Clear current student data
  void clearStudent() {
    _studentProfile = null;
    _error = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get student name from local storage (fast access)
  String? getCachedStudentName() {
    return _storage.getStudentName();
  }

  /// Get student roll number from local storage (fast access)
  String? getCachedRollNo() {
    return _storage.getStudentRollNo();
  }

  /// Check if student data is available locally
  bool hasLocalData() {
    return _storage.getStudentId() != null;
  }
}
