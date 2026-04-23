import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course.dart';
import '../../providers/student_provider.dart';
import '../../providers/attendance_provider.dart';
import '../students/students_screen.dart';
import '../attendance/attendance_screen.dart';
import '../attendance/attendance_summary_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
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
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.course.name),
            Text(
              widget.course.code,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            _MenuCard(
              icon: Icons.people_outlined,
              color: Colors.indigo,
              title: 'Student Enrollment',
              subtitle: 'Manage enrolled students',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentsScreen(course: widget.course),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _MenuCard(
              icon: Icons.check_circle_outlined,
              color: Colors.teal,
              title: 'Mark Attendance',
              subtitle: 'Take attendance for today or any date',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AttendanceScreen(course: widget.course),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _MenuCard(
              icon: Icons.bar_chart_outlined,
              color: Colors.orange,
              title: 'Attendance Summary',
              subtitle: 'View class-wise attendance percentage',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AttendanceSummaryScreen(course: widget.course),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
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
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
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
