import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../services/ui_constants.dart';

class AddTodoSheet extends ConsumerStatefulWidget {
  const AddTodoSheet({super.key});

  @override
  ConsumerState<AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends ConsumerState<AddTodoSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedTime;
  CategoryMeta _selectedCategory = appCategories[0];
  TodoPriority _selectedPriority = TodoPriority.low;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;

    final todo = Todo(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      reminderTime: _selectedTime,
      category: _selectedCategory.name,
      priority: _selectedPriority,
    );

    ref.read(todoProvider.notifier).addTodo(todo);
    Navigator.pop(context);
  }

  Future<void> _pickTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _selectedTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, -10))],
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Row(
              children: [
                Text(
                  'Create New Task',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
                ),
                const Spacer(),
                IconButton.filledTonal(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ).animate().fadeIn().slideY(begin: 0.1),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              autofocus: true,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'What magic will you do?',
                prefixIcon: const Icon(Icons.auto_awesome_rounded),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
            ).animate().fadeIn(delay: 200.ms).slideX(),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Extra details...',
                prefixIcon: const Icon(Icons.notes_rounded),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
            ).animate().fadeIn(delay: 300.ms).slideX(),
            const SizedBox(height: 24),
            const Text('Priority Level', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Row(
              children: TodoPriority.values.map((p) {
                final isSelected = _selectedPriority == p;
                final color = switch (p) {
                   TodoPriority.high => Colors.redAccent,
                   TodoPriority.medium => Colors.orangeAccent,
                   TodoPriority.low => Colors.blueAccent,
                };
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPriority = p),
                    child: AnimatedContainer(
                      duration: 300.ms,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? color : color.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? color : color.withOpacity(0.3), width: 2),
                      ),
                      child: Center(
                        child: Text(
                          p.name.toUpperCase(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : color,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 24),
            const Text('Choose Category', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: appCategories.length,
                itemBuilder: (context, index) {
                  final meta = appCategories[index];
                  final isSelected = _selectedCategory.name == meta.name;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(meta.name),
                      avatar: Icon(meta.icon, size: 16, color: isSelected ? Colors.white : meta.gradient[0]),
                      selected: isSelected,
                      onSelected: (val) => setState(() => _selectedCategory = meta),
                      selectedColor: meta.gradient[0],
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                      side: BorderSide(color: meta.gradient[0].withOpacity(0.3)),
                    ),
                  );
                },
              ),
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickTime,
                    icon: Icon(_selectedTime == null ? Icons.alarm_add_rounded : Icons.alarm_on_rounded),
                    label: Text(
                      _selectedTime == null ? 'Set Reminder' : DateFormat('MMM d, HH:mm').format(_selectedTime!),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 6,
                      shadowColor: theme.colorScheme.primary.withOpacity(0.5),
                    ),
                    child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }
}
