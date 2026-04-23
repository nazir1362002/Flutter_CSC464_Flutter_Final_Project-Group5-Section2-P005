import 'package:cloud_firestore/cloud_firestore.dart';

class Routine {
  final String id;
  final String courseId;
  final String courseName;
  final String day;
  final String time;

  Routine({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.day,
    required this.time,
  });

  factory Routine.fromFirestore(DocumentSnapshot doc, String courseName) {
    final data = doc.data() as Map<String, dynamic>;
    return Routine(
      id: doc.id,
      courseId: data['courseId'] ?? '',
      courseName: courseName,
      day: data['day'] ?? '',
      time: data['time'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'day': day,
      'time': time,
    };
  }
}

const List<String> kWeekDays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
