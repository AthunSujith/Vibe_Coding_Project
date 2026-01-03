import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'todo.g.dart';

@HiveType(typeId: 1)
enum TodoPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high
}

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime? reminderTime;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  final String category;

  @HiveField(7)
  final TodoPriority priority;

  Todo({
    String? id,
    required this.title,
    this.description = '',
    DateTime? createdAt,
    this.reminderTime,
    this.isCompleted = false,
    this.category = 'General',
    this.priority = TodoPriority.low,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Todo copyWith({
    String? title,
    String? description,
    DateTime? reminderTime,
    bool? isCompleted,
    String? category,
    TodoPriority? priority,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      reminderTime: reminderTime ?? this.reminderTime,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      priority: priority ?? this.priority,
    );
  }
}
