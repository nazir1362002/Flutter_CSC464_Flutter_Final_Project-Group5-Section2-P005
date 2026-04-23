import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/course.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/student_provider.dart';
import 'mark_attendance_screen.dart';
import 'attendance_history_screen.dart';

class AttendanceScreen extends StatefulWidget {
  final Course course;
  const AttendanceScreen({super.key, required this.course});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
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
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance — ${widget.course.code}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AttendanceOptionCard(
              icon: Icons.edit_calendar_outlined,
              color: Colors.teal,
              title: 'Mark Today\'s Attendance',
              subtitle: DateFormat('EEEE, MMMM d, yyyy').format(now),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MarkAttendanceScreen(
                    course: widget.course,
                    date: now,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _AttendanceOptionCard(
              icon: Icons.calendar_month_outlined,
              color: Colors.purple,
              title: 'Mark for a Past Date',
              subtitle: 'Select any previous date',
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: now,
                  firstDate: DateTime(now.year - 1),
                  lastDate: now,
                );
                if (picked != null && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MarkAttendanceScreen(
                        course: widget.course,
                        date: picked,
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            _AttendanceOptionCard(
              icon: Icons.history_outlined,
              color: Colors.deepOrange,
              title: 'Attendance History',
              subtitle: 'View all recorded attendance',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AttendanceHistoryScreen(course: widget.course),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceOptionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AttendanceOptionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
