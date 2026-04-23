import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/routine.dart';
import '../../providers/routine_provider.dart';
import '../../providers/course_provider.dart';

class AddEditRoutineScreen extends StatefulWidget {
  final Routine? routine;
  const AddEditRoutineScreen({super.key, this.routine});

  @override
  State<AddEditRoutineScreen> createState() => _AddEditRoutineScreenState();
}

class _AddEditRoutineScreenState extends State<AddEditRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCourseId;
  String _selectedDay = kWeekDays[0];
  late final TextEditingController _timeController;
  bool _saving = false;
  TimeOfDay? _selectedTime;

  bool get isEditing => widget.routine != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _selectedCourseId = widget.routine!.courseId;
      _selectedDay = widget.routine!.day;
      _timeController =
          TextEditingController(text: widget.routine!.time);
    } else {
      _timeController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a course')),
      );
      return;
    }

    setState(() => _saving = true);
    final provider = context.read<RoutineProvider>();
    bool success;

    if (isEditing) {
      success = await provider.updateRoutine(
        widget.routine!.id,
        _selectedCourseId!,
        _selectedDay,
        _timeController.text.trim(),
      );
    } else {
      success = await provider.addRoutine(
        _selectedCourseId!,
        _selectedDay,
        _timeController.text.trim(),
      );
    }

    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save routine')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final courses = context.watch<CourseProvider>().courses;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Routine' : 'Add Routine'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              // Course Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCourseId,
                decoration: const InputDecoration(
                  labelText: 'Course',
                  prefixIcon: Icon(Icons.book_outlined),
                ),
                items: courses
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text('${c.name} (${c.code})'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCourseId = v),
                validator: (v) => v == null ? 'Select a course' : null,
                hint: courses.isEmpty
                    ? const Text('No courses available')
                    : const Text('Select course'),
              ),
              const SizedBox(height: 16),
              // Day Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedDay,
                decoration: const InputDecoration(
                  labelText: 'Day',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                items: kWeekDays
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedDay = v ?? kWeekDays[0]),
              ),
              const SizedBox(height: 16),
              // Time
              TextFormField(
                controller: _timeController,
                readOnly: true,
                onTap: _pickTime,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  prefixIcon: Icon(Icons.access_time),
                  hintText: 'Tap to pick time',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Time is required' : null,
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
                    : Text(isEditing ? 'Update Routine' : 'Add to Schedule'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
