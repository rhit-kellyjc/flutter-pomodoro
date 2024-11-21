import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_stats.dart';

class StatsManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  StatsManager({required this.userId});

  Future<void> updateTaskStats({required bool increment}) async {
    try {
      print('Starting stats update for user: $userId');
      final userRef = _firestore.doc('users/$userId');

      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        final currentStats = UserStats.fromJson(userDoc.data() ?? {});
        print('Current total tasks: ${currentStats.totalTasks}');

        final updatedStats = currentStats.copyWith(
          totalTasks: currentStats.totalTasks + (increment ? 1 : -1),
        );
        print('Updated total tasks: ${updatedStats.totalTasks}');

        transaction.set(userRef, updatedStats.toJson());
      });
      print('Stats update successful');
    } catch (e) {
      print('Error updating stats: $e');
      rethrow;
    }
  }

  Future<void> updateStats({
    bool isPomodoro = false,
    bool isShortBreak = false,
    bool isLongBreak = false,
  }) async {
    try {
      final userRef = _firestore.doc('users/$userId');

      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        final currentStats = UserStats.fromJson(userDoc.data() ?? {});

        final updatedStats = currentStats.copyWith(
          totalPomodoros: currentStats.totalPomodoros + (isPomodoro ? 1 : 0),
          totalShortBreaks:
              currentStats.totalShortBreaks + (isShortBreak ? 1 : 0),
          totalLongBreaks: currentStats.totalLongBreaks + (isLongBreak ? 1 : 0),
        );

        transaction.set(userRef, updatedStats.toJson());
      });
    } catch (e) {
      print('Error updating stats: $e');
      rethrow;
    }
  }

  Future<UserStats> getUserStats() async {
    try {
      print('Getting stats for user: $userId');
      final userDoc = await _firestore.doc('users/$userId').get();
      final userStats = UserStats.fromJson(userDoc.data() ?? {});

      final allUsersSnapshot = await _firestore.collection('users').get();

      final activeUsers = allUsersSnapshot.docs
          .map((doc) {
            final stats = UserStats.fromJson(doc.data());
            final totalScore = (stats.totalPomodoros * 2) +
                stats.totalTasks +
                stats.totalShortBreaks +
                (stats.totalLongBreaks * 1.5).round();
            return (stats, totalScore, doc.id);
          })
          .where((item) => item.$2 > 0)
          .toList();

      if (activeUsers.isEmpty) {
        return userStats.copyWith(ranking: 1, totalUsers: 1);
      }

      activeUsers.sort((a, b) => b.$2.compareTo(a.$2));

      int ranking = 1;
      int currentRank = 1;
      int previousScore = activeUsers[0].$2;

      for (var item in activeUsers) {
        if (item.$2 < previousScore) {
          currentRank = ranking;
          previousScore = item.$2;
        }
        if (item.$3 == userId) {
          break;
        }
        ranking++;
      }

      print(
          'User $userId ranked $currentRank out of ${activeUsers.length} active users');
      print(
          'Total score: ${activeUsers.firstWhere((item) => item.$3 == userId).$2}');

      return userStats.copyWith(
        ranking: currentRank,
        totalUsers: activeUsers.length,
      );
    } catch (e) {
      print('Error getting user stats: $e');
      return UserStats();
    }
  }

  Future<void> initializeUserStats() async {
    try {
      final userRef = _firestore.doc('users/$userId');
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        print('Initializing stats for new user: $userId');
        await userRef.set(const UserStats().toJson());
      }
    } catch (e) {
      print('Error initializing user stats: $e');
      rethrow;
    }
  }
}
