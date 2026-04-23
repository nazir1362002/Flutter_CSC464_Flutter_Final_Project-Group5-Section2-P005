import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/student.dart';
import '../../providers/student_provider.dart';

class AddEditStudentScreen extends StatefulWidget {
  final String courseId;
  final Student? student;

  const AddEditStudentScreen({
    super.key,
    required this.courseId,
    this.student,
  });

  @override
  State<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends State<AddEditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _idController;
  bool _saving = false;

  bool get isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.student?.name ?? '');
    _idController =
        TextEditingController(text: widget.student?.studentId ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final provider = context.read<StudentProvider>();
    bool success;

    if (isEditing) {
      success = await provider.updateStudent(
        widget.courseId,
        widget.student!.id,
        _nameController.text.trim(),
        _idController.text.trim(),
      );
    } else {
      success = await provider.addStudent(
        widget.courseId,
        _nameController.text.trim(),
        _idController.text.trim(),
      );
    }

    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save student')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Student' : 'Enroll Student'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Student Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'Student ID',
                  prefixIcon: Icon(Icons.badge_outlined),
                  hintText: 'e.g. 2024001',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'ID is required' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(isEditing ? 'Update Student' : 'Enroll Student'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
