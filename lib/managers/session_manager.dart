import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pomodoro/models/pomodoro_session.dart';

class SessionManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  SessionManager({required this.userId});

  Future<void> saveSession(PomodoroSession session) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .doc(session.id)
        .set(session.toJson());
  }

  Future<List<PomodoroSession>> getTodaySessions() async {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .where('startTime', isGreaterThanOrEqualTo: today)
        .where('startTime', isLessThan: tomorrow)
        .get();

    return snapshot.docs
        .map((doc) => PomodoroSession.fromJson(doc.data()))
        .toList();
  }
}
