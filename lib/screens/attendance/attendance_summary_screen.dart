import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course.dart';
import '../../models/attendance.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/student_provider.dart';

class AttendanceSummaryScreen extends StatefulWidget {
  final Course course;
  const AttendanceSummaryScreen({super.key, required this.course});

  @override
  State<AttendanceSummaryScreen> createState() =>
      _AttendanceSummaryScreenState();
}

class _AttendanceSummaryScreenState extends State<AttendanceSummaryScreen> {
  /*@override
  void initState() {
    super.initState();
    context.read<StudentProvider>().listenToStudents(widget.course.id);
    context.read<AttendanceProvider>().listenToAttendance(widget.course.id);
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
        title: Text('Summary — ${widget.course.code}'),
      ),
      body: Consumer2<AttendanceProvider, StudentProvider>(
        builder: (context, attendanceProvider, studentProvider, _) {
          final students = studentProvider.getStudents(widget.course.id);
          final records = attendanceProvider.getAttendance(widget.course.id);

          if (students.isEmpty) {
            return const Center(
              child: Text('No students enrolled'),
            );
          }

          final summaries =
              attendanceProvider.getSummary(widget.course.id, students);

          final totalClasses = records.length;

          return Column(
            children: [
              // Header card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withBlue(220),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bar_chart, color: Colors.white, size: 36),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Classes Held',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        Text(
                          '$totalClasses',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Students list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: summaries.length,
                  itemBuilder: (context, index) {
                    final summary = summaries[index];
                    return _SummaryCard(summary: summary);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final AttendanceSummary summary;
  const _SummaryCard({required this.summary});

  Color get _percentageColor {
    if (summary.percentage >= 75) return Colors.green;
    if (summary.percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  child: Text(
                    summary.studentName.isNotEmpty
                        ? summary.studentName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    summary.studentName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _percentageColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${summary.percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: _percentageColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: summary.totalClasses == 0
                    ? 0
                    : summary.presentCount / summary.totalClasses,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(_percentageColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _StatPill(
                  label: 'Present',
                  value: '${summary.presentCount}',
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                _StatPill(
                  label: 'Absent',
                  value: '${summary.totalClasses - summary.presentCount}',
                  color: Colors.red,
                ),
                const SizedBox(width: 8),
                _StatPill(
                  label: 'Total',
                  value: '${summary.totalClasses}',
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $value',
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
