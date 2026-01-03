import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo.dart';
import '../services/notification_service.dart';

class TodoNotifier extends Notifier<List<Todo>> {
  late final Box<Todo> _box;
  final NotificationService _notificationService = NotificationService();

  @override
  List<Todo> build() {
    _box = Hive.box<Todo>('todos');
    return _box.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addTodo(Todo todo) async {
    await _box.put(todo.id, todo);
    state = [todo, ...state];
    
    if (todo.reminderTime != null) {
      await _notificationService.scheduleNotification(
        id: todo.id.hashCode,
        title: 'Task Reminder',
        body: todo.title,
        scheduledDate: todo.reminderTime!,
      );
    }
  }

  Future<void> toggleTodo(String id) async {
    final index = state.indexWhere((t) => t.id == id);
    if (index == -1) return;
    
    final todo = state[index];
    todo.isCompleted = !todo.isCompleted;
    await todo.save();
    
    state = [
      for (final t in state)
        if (t.id == id) todo else t
    ];
    
    if (todo.isCompleted) {
      await _notificationService.cancelNotification(todo.id.hashCode);
    } else if (todo.reminderTime != null) {
       await _notificationService.scheduleNotification(
        id: todo.id.hashCode,
        title: 'Task Reminder',
        body: todo.title,
        scheduledDate: todo.reminderTime!,
      );
    }
  }

  Future<void> deleteTodo(String id) async {
    await _box.delete(id);
    state = state.where((t) => t.id != id).toList();
    await _notificationService.cancelNotification(id.hashCode);
  }

  Future<void> updateTodo(Todo updatedTodo) async {
    await _box.put(updatedTodo.id, updatedTodo);
    state = [
      for (final t in state)
        if (t.id == updatedTodo.id) updatedTodo else t
    ];

    if (updatedTodo.reminderTime != null && !updatedTodo.isCompleted) {
      await _notificationService.scheduleNotification(
        id: updatedTodo.id.hashCode,
        title: 'Task Reminder',
        body: updatedTodo.title,
        scheduledDate: updatedTodo.reminderTime!,
      );
    } else {
      await _notificationService.cancelNotification(updatedTodo.id.hashCode);
    }
  }
}

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String query) => state = query;
}

class CategoryFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';
  void set(String category) => state = category;
}

// Optimization Providers
final todoProvider = NotifierProvider<TodoNotifier, List<Todo>>(() {
  return TodoNotifier();
});

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() {
  return SearchQueryNotifier();
});

final selectedCategoryProvider = NotifierProvider<CategoryFilterNotifier, String>(() {
  return CategoryFilterNotifier();
});

final filteredTodosProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoProvider);
  final search = ref.watch(searchQueryProvider).toLowerCase();
  final category = ref.watch(selectedCategoryProvider);

  return todos.where((todo) {
    final matchesSearch = todo.title.toLowerCase().contains(search) || 
                         todo.description.toLowerCase().contains(search);
    final matchesCategory = category == 'All' || todo.category == category;
    return matchesSearch && matchesCategory;
  }).toList()..sort((a, b) {
    if (a.isCompleted != b.isCompleted) {
      return a.isCompleted ? 1 : -1;
    }
    final priorityScore = b.priority.index.compareTo(a.priority.index);
    if (priorityScore != 0) return priorityScore;
    return b.createdAt.compareTo(a.createdAt);
  });
});

final categoryCountsProvider = Provider<Map<String, int>>((ref) {
  final todos = ref.watch(todoProvider);
  final counts = <String, int>{'All': todos.length};
  for (final todo in todos) {
    counts[todo.category] = (counts[todo.category] ?? 0) + 1;
  }
  return counts;
});
