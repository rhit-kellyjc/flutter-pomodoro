import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveTask(String userId, Task task) async {
    try {
      final taskDoc = _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(task.id);

      final taskData = {
        'id': task.id,
        'title': task.title,
        'notes': task.notes,
        'isCompleted': task.isCompleted,
        'createdAt': Timestamp.fromDate(task.createdAt),
      };

      await taskDoc.set(taskData);
    } catch (e) {
      throw 'Failed to save task: $e';
    }
  }

  Future<List<Task>> getTasks(String userId) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      final userSnapshot = await userDoc.get();

      if (!userSnapshot.exists) {
        await userDoc.set({'createdAt': Timestamp.now()});
      }

      final snapshot = await userDoc
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Task(
          id: data['id'] as String,
          title: data['title'] as String,
          notes: data['notes'] as String?,
          isCompleted: data['isCompleted'] as bool? ?? false,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      throw 'Failed to load tasks: $e';
    }
  }

  Future<void> updateTaskCompletion(
    String userId,
    String taskId,
    bool isCompleted,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(taskId)
          .update({'isCompleted': isCompleted});
    } catch (e) {
      throw 'Failed to update task completion: $e';
    }
  }

  Future<void> deleteTask(String userId, String taskId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(taskId)
          .delete();
    } catch (e) {
      throw 'Failed to delete task: $e';
    }
  }

  Future<void> reorderTasks(String userId, List<Task> tasks) async {
    try {
      final batch = _firestore.batch();

      for (var i = 0; i < tasks.length; i++) {
        final task = tasks[i];
        final taskRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('tasks')
            .doc(task.id);

        batch.update(taskRef, {
          'order': i,
        });
      }

      await batch.commit();
    } catch (e) {
      throw 'Failed to reorder tasks: $e';
    }
  }
}
