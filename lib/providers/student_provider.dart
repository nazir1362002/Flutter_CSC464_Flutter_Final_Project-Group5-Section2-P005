import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class StudentProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Map<String, List<Student>> _studentsByCourse = {};
  final Map<String, bool> _loadingByCourse = {};
  String? _error;

  List<Student> getStudents(String courseId) =>
      _studentsByCourse[courseId] ?? [];

  bool isLoading(String courseId) => _loadingByCourse[courseId] ?? false;

  String? get error => _error;

  CollectionReference _studentsRef(String courseId) =>
      _db.collection('courses').doc(courseId).collection('students');

  void listenToStudents(String courseId) {
    if (_loadingByCourse[courseId] == true) return;
    _loadingByCourse[courseId] = true;
    notifyListeners();

    _studentsRef(courseId).snapshots().listen(
      (snapshot) {
        _studentsByCourse[courseId] =
            snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList();
        _studentsByCourse[courseId]!
            .sort((a, b) => a.name.compareTo(b.name));
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

  Future<bool> addStudent(
      String courseId, String name, String studentId) async {
    try {
      await _studentsRef(courseId).add({'name': name, 'studentId': studentId});
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStudent(
      String courseId, String docId, String name, String studentId) async {
    try {
      await _studentsRef(courseId)
          .doc(docId)
          .update({'name': name, 'studentId': studentId});
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteStudent(String courseId, String docId) async {
    try {
      await _studentsRef(courseId).doc(docId).delete();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
