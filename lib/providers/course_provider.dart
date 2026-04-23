import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course.dart';

class CourseProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Course> _courses = [];
  bool _loading = false;
  String? _error;

  List<Course> get courses => _courses;
  bool get loading => _loading;
  String? get error => _error;

  CollectionReference get _coursesRef => _db.collection('courses');

  void listenToCourses() {
    _loading = true;
    notifyListeners();

    _coursesRef.snapshots().listen(
      (snapshot) {
        _courses = snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList();
        _courses.sort((a, b) => a.name.compareTo(b.name));
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _loading = false;
        notifyListeners();
      },
    );
  }

  Future<String?> addCourse(String name, String code) async {
    try {
      final ref = await _coursesRef.add({'name': name, 'code': code});
      return ref.id;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateCourse(String id, String name, String code) async {
    try {
      await _coursesRef.doc(id).update({'name': name, 'code': code});
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCourse(String id) async {
    try {
      // Delete all subcollections first
      await _deleteCollection(_coursesRef.doc(id).collection('students'));
      await _deleteCollection(_coursesRef.doc(id).collection('attendance'));
      await _coursesRef.doc(id).delete();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> _deleteCollection(CollectionReference ref) async {
    final snapshot = await ref.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Course? getCourseById(String id) {
    try {
      return _courses.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
