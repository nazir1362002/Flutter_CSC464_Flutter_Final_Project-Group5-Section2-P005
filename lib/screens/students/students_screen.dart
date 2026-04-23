import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course.dart';
import '../../models/student.dart';
import '../../providers/student_provider.dart';
import 'add_edit_student_screen.dart';

class StudentsScreen extends StatefulWidget {
  final Course course;
  const StudentsScreen({super.key, required this.course});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  /*@override
  void initState() {
    super.initState();
    context.read<StudentProvider>().listenToStudents(widget.course.id);
  }*/
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().listenToStudents(widget.course.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.course.name} — Students'),
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading(widget.course.id)) {
            return const Center(child: CircularProgressIndicator());
          }
          final students = provider.getStudents(widget.course.id);
          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No students enrolled',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text('Tap + to enroll students',
                      style: TextStyle(color: Colors.grey[400])),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return _StudentCard(student: student, courseId: widget.course.id);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddEditStudentScreen(courseId: widget.course.id),
          ),
        ),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Enroll Student'),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final Student student;
  final String courseId;
  const _StudentCard({required this.student, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<StudentProvider>();
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          child: Text(
            student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(student.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('ID: ${student.studentId}',
            style: TextStyle(color: Colors.grey[600])),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditStudentScreen(
                    courseId: courseId,
                    student: student,
                  ),
                ),
              );
            } else if (value == 'delete') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Remove Student'),
                  content: Text('Remove "${student.name}" from this course?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Remove',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await provider.deleteStudent(courseId, student.id);
              }
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
