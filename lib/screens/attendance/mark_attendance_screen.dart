import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/course.dart';
import '../../providers/student_provider.dart';
import '../../providers/attendance_provider.dart';

class MarkAttendanceScreen extends StatefulWidget {
  final Course course;
  final DateTime date;

  const MarkAttendanceScreen({
    super.key,
    required this.course,
    required this.date,
  });

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  Map<String, String> _attendance = {}; // studentDocId -> "Present"/"Absent"
  bool _saving = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initAttendance();
      _initialized = true;
    }
  }

  void _initAttendance() {
    final attendanceProvider = context.read<AttendanceProvider>();
    final studentProvider = context.read<StudentProvider>();
    final existing =
        attendanceProvider.getAttendanceForDate(widget.course.id, widget.date);
    final students = studentProvider.getStudents(widget.course.id);

    if (existing != null) {
      _attendance = Map.from(existing.records);
    } else {
      // Default all to Present
      _attendance = {
        for (final s in students) s.id: 'Present',
      };
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final provider = context.read<AttendanceProvider>();
    final success = await provider.saveAttendance(
      widget.course.id,
      widget.date,
      _attendance,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save attendance')),
      );
    }
  }

  void _markAll(String status) {
    setState(() {
      for (final key in _attendance.keys) {
        _attendance[key] = status;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final students =
        context.watch<StudentProvider>().getStudents(widget.course.id);

    // Sync new students into attendance map
    for (final s in students) {
      _attendance.putIfAbsent(s.id, () => 'Present');
    }

    final presentCount = _attendance.values.where((v) => v == 'Present').length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Mark Attendance'),
            Text(
              DateFormat('EEE, MMM d, yyyy').format(widget.date),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          if (!_saving)
            IconButton(
              icon: const Icon(Icons.save_outlined),
              onPressed: _save,
              tooltip: 'Save',
            ),
        ],
      ),
      body: students.isEmpty
          ? const Center(
              child: Text('No students enrolled in this course'),
            )
          : Column(
              children: [
                // Summary bar
                Container(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.08),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$presentCount / ${students.length} Present',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _markAll('Present'),
                        child: const Text('All Present'),
                      ),
                      TextButton(
                        onPressed: () => _markAll('Absent'),
                        child: Text('All Absent',
                            style: TextStyle(color: Colors.red[600])),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final status = _attendance[student.id] ?? 'Present';
                      final isPresent = status == 'Present';
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: isPresent
                                ? Colors.green.withOpacity(0.15)
                                : Colors.red.withOpacity(0.15),
                            child: Icon(
                              isPresent ? Icons.check_circle : Icons.cancel,
                              color: isPresent ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(student.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text('ID: ${student.studentId}',
                              style: TextStyle(color: Colors.grey[600])),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _StatusChip(
                                label: 'P',
                                active: isPresent,
                                activeColor: Colors.green,
                                onTap: () => setState(
                                    () => _attendance[student.id] = 'Present'),
                              ),
                              const SizedBox(width: 6),
                              _StatusChip(
                                label: 'A',
                                active: !isPresent,
                                activeColor: Colors.red,
                                onTap: () => setState(
                                    () => _attendance[student.id] = 'Absent'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: students.isNotEmpty
          ? FloatingActionButton.extended(
              heroTag: null,
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save),
              label: const Text('Save Attendance'),
            )
          : null,
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: active ? activeColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? activeColor : Colors.grey[300]!,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.grey[500],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
