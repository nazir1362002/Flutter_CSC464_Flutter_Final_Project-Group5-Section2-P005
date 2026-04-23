import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  final String id;
  final DateTime date;
  final Map<String, String> records; // studentId -> "Present" or "Absent"

  AttendanceRecord({
    required this.id,
    required this.date,
    required this.records,
  });

  factory AttendanceRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final Timestamp timestamp = data['date'];
    final Map<String, dynamic> rawRecords =
        Map<String, dynamic>.from(data['records'] ?? {});
    final Map<String, String> records =
        rawRecords.map((k, v) => MapEntry(k, v.toString()));

    return AttendanceRecord(
      id: doc.id,
      date: timestamp.toDate(),
      records: records,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'records': records,
    };
  }
}

class AttendanceSummary {
  final String studentId;
  final String studentName;
  final int totalClasses;
  final int presentCount;

  AttendanceSummary({
    required this.studentId,
    required this.studentName,
    required this.totalClasses,
    required this.presentCount,
  });

  double get percentage =>
      totalClasses == 0 ? 0 : (presentCount / totalClasses) * 100;
}
