import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/task.dart';

class TasksSection extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task) onTaskCompleted;
  final Function(Task) onTaskDeleted;
  final VoidCallback onAddPressed;
  final Function(int, int) onReorder;

  const TasksSection({
    super.key,
    required this.tasks,
    required this.onTaskCompleted,
    required this.onTaskDeleted,
    required this.onAddPressed,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tasks',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: onAddPressed,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildTasksList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList() {
    if (tasks.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.only(top: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Add tasks to be shown here',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      itemCount: tasks.length,
      onReorderStart: (_) => HapticFeedback.mediumImpact(),
      onReorderEnd: (_) => HapticFeedback.mediumImpact(),
      onReorder: onReorder,
      itemBuilder: (context, index) => _buildTaskItem(tasks[index]),
    );
  }

  Widget _buildTaskItem(Task task) {
    return Container(
      key: Key(task.id),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: IconButton(
            icon: Icon(
              task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
              color: Colors.white,
            ),
            onPressed: () => onTaskCompleted(task),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              color: Colors.white,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: task.notes != null
              ? Text(
                  task.notes!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                )
              : null,
          trailing: const Icon(
            Icons.drag_handle,
            color: Colors.white54,
          ),
        ),
      ),
    );
  }
}
