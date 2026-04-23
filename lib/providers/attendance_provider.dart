import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance.dart';
import '../models/student.dart';

class AttendanceProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Map<String, List<AttendanceRecord>> _attendanceByCourse = {};
  final Map<String, bool> _loadingByCourse = {};
  String? _error;

  List<AttendanceRecord> getAttendance(String courseId) =>
      _attendanceByCourse[courseId] ?? [];

  bool isLoading(String courseId) => _loadingByCourse[courseId] ?? false;

  String? get error => _error;

  CollectionReference _attendanceRef(String courseId) =>
      _db.collection('courses').doc(courseId).collection('attendance');

  void listenToAttendance(String courseId) {
    if (_loadingByCourse[courseId] == true) return;
    _loadingByCourse[courseId] = true;
    notifyListeners();

    _attendanceRef(courseId).orderBy('date', descending: true).snapshots().listen(
      (snapshot) {
        _attendanceByCourse[courseId] = snapshot.docs
            .map((doc) => AttendanceRecord.fromFirestore(doc))
            .toList();
        _loadingByCourse[courseId] = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _loadingByCourse[courseId] = false;
        notifyListeners();
      },
    );
  }

  Future<bool> saveAttendance(
      String courseId, DateTime date, Map<String, String> records) async {
    try {
      // Check if attendance already exists for this date
      final existing = await _attendanceRef(courseId)
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime(date.year, date.month, date.day)),
              isLessThan: Timestamp.fromDate(
                  DateTime(date.year, date.month, date.day + 1)))
          .get();

      if (existing.docs.isNotEmpty) {
        // Update existing record
        await existing.docs.first.reference.update({
          'date': Timestamp.fromDate(date),
          'records': records,
        });
      } else {
        // Create new record
        await _attendanceRef(courseId).add({
          'date': Timestamp.fromDate(date),
          'records': records,
        });
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Returns attendance for a specific date, or null if not found
  AttendanceRecord? getAttendanceForDate(String courseId, DateTime date) {
    final records = _attendanceByCourse[courseId] ?? [];
    try {
      return records.firstWhere(
        (r) =>
            r.date.year == date.year &&
            r.date.month == date.month &&
            r.date.day == date.day,
      );
    } catch (_) {
      return null;
    }
  }

  /// Compute summary for each student
  List<AttendanceSummary> getSummary(
      String courseId, List<Student> students) {
    final records = _attendanceByCourse[courseId] ?? [];
    final totalClasses = records.length;

    return students.map((student) {
      int presentCount = 0;
      for (final record in records) {
        if (record.records[student.id] == 'Present') {
          presentCount++;
        }
      }
      return AttendanceSummary(
        studentId: student.id,
        studentName: student.name,
        totalClasses: totalClasses,
        presentCount: presentCount,
      );
    }).toList();
  }
}
