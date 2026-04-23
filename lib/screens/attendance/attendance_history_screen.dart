import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/course.dart';
import '../../models/attendance.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/student_provider.dart';
import 'mark_attendance_screen.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  final Course course;
  const AttendanceHistoryScreen({super.key, required this.course});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  /*@override
  void initState() {
    super.initState();
    context.read<AttendanceProvider>().listenToAttendance(widget.course.id);
    context.read<StudentProvider>().listenToStudents(widget.course.id);
  }*/
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().listenToAttendance(widget.course.id);

      context.read<StudentProvider>().listenToStudents(widget.course.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History — ${widget.course.code}'),
      ),
      body: Consumer2<AttendanceProvider, StudentProvider>(
        builder: (context, attendanceProvider, studentProvider, _) {
          if (attendanceProvider.isLoading(widget.course.id)) {
            return const Center(child: CircularProgressIndicator());
          }
          final records = attendanceProvider.getAttendance(widget.course.id);
          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No attendance records yet',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            itemCount: records.length,
            itemBuilder: (context, index) {
              return _AttendanceHistoryCard(
                record: records[index],
                course: widget.course,
                students: studentProvider.getStudents(widget.course.id),
              );
            },
          );
        },
      ),
    );
  }
}

class _AttendanceHistoryCard extends StatelessWidget {
  final AttendanceRecord record;
  final Course course;
  final students;

  const _AttendanceHistoryCard({
    required this.record,
    required this.course,
    required this.students,
  });

  @override
  Widget build(BuildContext context) {
    final presentCount =
        record.records.values.where((v) => v == 'Present').length;
    final total = record.records.length;

    return Card(
      child: ExpansionTile(
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.calendar_today, color: Colors.indigo),
        ),
        title: Text(
          DateFormat('EEEE, MMMM d, yyyy').format(record.date),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          '$presentCount / $total Present',
          style: TextStyle(
            color: presentCount == total
                ? Colors.green
                : presentCount == 0
                    ? Colors.red
                    : Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MarkAttendanceScreen(
                    course: course,
                    date: record.date,
                  ),
                ),
              ),
              tooltip: 'Edit',
            ),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          ...students.map<Widget>((student) {
            final status = record.records[student.id];
            final isPresent = status == 'Present';
            final isAbsent = status == 'Absent';
            return ListTile(
              dense: true,
              leading: Icon(
                isPresent
                    ? Icons.check_circle
                    : isAbsent
                        ? Icons.cancel
                        : Icons.help_outline,
                color: isPresent
                    ? Colors.green
                    : isAbsent
                        ? Colors.red
                        : Colors.grey,
                size: 20,
              ),
              title: Text(student.name, style: const TextStyle(fontSize: 14)),
              subtitle: Text('ID: ${student.studentId}',
                  style: const TextStyle(fontSize: 12)),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPresent
                      ? Colors.green.withOpacity(0.12)
                      : isAbsent
                          ? Colors.red.withOpacity(0.12)
                          : Colors.grey.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status ?? 'N/A',
                  style: TextStyle(
                    color: isPresent
                        ? Colors.green
                        : isAbsent
                            ? Colors.red
                            : Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
