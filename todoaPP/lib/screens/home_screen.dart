import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';
import '../widgets/add_todo_sheet.dart';
import '../services/ui_constants.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(filteredTodosProvider);
    final categoryCounts = ref.watch(categoryCountsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.surface,
              theme.colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar.large(
              floating: true,
              pinned: true,
              stretch: true,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              title: Text(
                'Super Tasker',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                  color: theme.colorScheme.onSurface,
                ),
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Hero(
                    tag: 'profile',
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (c, a, s) => const SettingsScreen(),
                          transitionsBuilder: (c, a, s, child) {
                            return FadeTransition(opacity: a, child: child);
                          },
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: appCategories[2].gradient),
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          backgroundImage: const AssetImage('assets/icon.png'),
                        ),
                      ),
                    ),
                  ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: TextField(
                    onChanged: (val) => ref.read(searchQueryProvider.notifier).set(val),
                    decoration: InputDecoration(
                      hintText: 'Search your magic list...',
                      prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
                      filled: true,
                      fillColor: theme.colorScheme.surface.withOpacity(0.8),
                      hoverColor: theme.colorScheme.primary.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: theme.colorScheme.primary.withOpacity(0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                    ),
                  ).animate().slideY(begin: 0.5, duration: 500.ms, curve: Curves.easeOutCubic),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: appCategories.length,
                  itemBuilder: (context, index) {
                    final meta = appCategories[index];
                    final count = categoryCounts[meta.name] ?? 0;
                    return _CategoryChip(
                      meta: meta,
                      isSelected: selectedCategory == meta.name,
                      count: count,
                      onTap: () => ref.read(selectedCategoryProvider.notifier).set(meta.name),
                    ).animate().scale(delay: (100 * index).ms, duration: 400.ms, curve: Curves.easeOutBack);
                  },
                ),
              ),
            ),
            if (todos.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/empty.png',
                      height: 250,
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .moveY(begin: -10, end: 10, duration: 2000.ms, curve: Curves.easeInOut),
                    const SizedBox(height: 24),
                    Text(
                      'All caught up!',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ).animate().fadeIn(delay: 300.ms),
                    Text(
                      'Enjoy your free time.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                    ).animate().fadeIn(delay: 500.ms),
                  ],
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final todo = todos[index];
                      return _TodoTile(key: ValueKey(todo.id), todo: todo)
                          .animate()
                          .fadeIn(duration: 400.ms, delay: (index * 50).ms)
                          .slideX(begin: 0.1, duration: 400.ms, curve: Curves.easeOutQuart);
                    },
                    childCount: todos.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddTodo(context),
          elevation: 10,
          highlightElevation: 15,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          icon: const Icon(Icons.add_rounded, size: 28),
          label: const Text('New Magic Task', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
         .shimmer(delay: 3000.ms, duration: 1500.ms, color: Colors.white24),
      ),
    );
  }

  void _showAddTodo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => const AddTodoSheet(),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final CategoryMeta meta;
  final bool isSelected;
  final int count;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.meta,
    required this.isSelected,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: 300.ms,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected ? LinearGradient(colors: meta.gradient) : null,
            color: isSelected ? null : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected 
              ? [BoxShadow(color: meta.gradient[0].withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
            border: Border.all(
              color: isSelected ? Colors.transparent : theme.colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                meta.icon,
                size: 18,
                color: isSelected ? Colors.white : theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                meta.name,
                style: TextStyle(
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white24 : theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TodoTile extends ConsumerWidget {
  final Todo todo;

  const _TodoTile({super.key, required this.todo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    final meta = appCategories.firstWhere((c) => c.name == todo.category, orElse: () => appCategories[0]);
    final priorityColor = switch (todo.priority) {
      TodoPriority.high => Colors.redAccent,
      TodoPriority.medium => Colors.orangeAccent,
      TodoPriority.low => Colors.blueAccent,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: todo.isCompleted 
                      ? [theme.colorScheme.outline.withOpacity(0.5), theme.colorScheme.outline]
                      : [priorityColor.withOpacity(0.7), priorityColor],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => ref.read(todoProvider.notifier).toggleTodo(todo.id),
                        child: AnimatedContainer(
                          duration: 400.ms,
                          height: 32,
                          width: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: todo.isCompleted ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.3),
                              width: 2,
                            ),
                            color: todo.isCompleted ? theme.colorScheme.primary : Colors.transparent,
                          ),
                          child: todo.isCompleted 
                            ? const Icon(Icons.check, size: 20, color: Colors.white).animate().scale()
                            : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              todo.title,
                              style: TextStyle(
                                decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                                decorationColor: theme.colorScheme.primary.withOpacity(0.5),
                                decorationThickness: 2,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: todo.isCompleted ? theme.colorScheme.outline : theme.colorScheme.onSurface,
                              ),
                            ),
                            if (todo.description.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  todo.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _Tag(
                                  icon: meta.icon,
                                  label: todo.category,
                                  gradient: meta.gradient,
                                ),
                                const SizedBox(width: 8),
                                if (todo.reminderTime != null)
                                  _Tag(
                                    icon: Icons.alarm_rounded,
                                    label: DateFormat('MMM d, HH:mm').format(todo.reminderTime!),
                                    color: theme.colorScheme.primary,
                                  ),
                                const Spacer(),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(Icons.delete_sweep_outlined, color: theme.colorScheme.error.withOpacity(0.5), size: 20),
                                  onPressed: () => _confirmDelete(context, ref),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (context, a1, a2) => Container(),
      transitionBuilder: (context, a1, a2, child) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Discard Task?', style: TextStyle(fontWeight: FontWeight.w900)),
              content: const Text('This magic task will disappear forever.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Keep it')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                  onPressed: () {
                    ref.read(todoProvider.notifier).deleteTodo(todo.id);
                    Navigator.pop(context);
                  },
                  child: const Text('Destroy'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color>? gradient;
  final Color? color;

  const _Tag({required this.icon, required this.label, this.gradient, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: gradient != null ? LinearGradient(colors: gradient!.map((c) => c.withOpacity(0.15)).toList()) : null,
        color: color?.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: gradient?[0] ?? color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: gradient?[0] ?? color,
            ),
          ),
        ],
      ),
    );
  }
}
