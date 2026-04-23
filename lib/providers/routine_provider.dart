import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/routine.dart';
import '../models/course.dart';

class RoutineProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Routine> _routines = [];
  bool _loading = false;
  String? _error;

  List<Routine> get routines => _routines;
  bool get loading => _loading;
  String? get error => _error;

  CollectionReference get _routineRef => _db.collection('routine');

  void listenToRoutines(List<Course> courses) {
    _loading = true;
    notifyListeners();

    _routineRef.snapshots().listen(
      (snapshot) async {
        final List<Routine> result = [];
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final courseId = data['courseId'] ?? '';
          final courseName = courses
              .firstWhere(
                (c) => c.id == courseId,
                orElse: () => Course(id: '', name: 'Unknown', code: ''),
              )
              .name;
          result.add(Routine.fromFirestore(doc, courseName));
        }
        _routines = result;
        _sortRoutines();
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

  void _sortRoutines() {
    _routines.sort((a, b) {
      final dayOrder = kWeekDays.indexOf(a.day) - kWeekDays.indexOf(b.day);
      if (dayOrder != 0) return dayOrder;
      return a.time.compareTo(b.time);
    });
  }

  List<Routine> getRoutinesForDay(String day) {
    return _routines.where((r) => r.day == day).toList();
  }

  Future<bool> addRoutine(
      String courseId, String day, String time) async {
    try {
      await _routineRef.add({
        'courseId': courseId,
        'day': day,
        'time': time,
      });
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRoutine(
      String id, String courseId, String day, String time) async {
    try {
      await _routineRef.doc(id).update({
        'courseId': courseId,
        'day': day,
        'time': time,
      });
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRoutine(String id) async {
    try {
      await _routineRef.doc(id).delete();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
