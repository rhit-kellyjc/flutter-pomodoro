import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pomodoro/models/pomodoro_settings.dart';

class SettingsManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  SettingsManager({required this.userId});

  Future<void> saveSettings(PomodoroSettings settings) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('pomodoro')
        .set(settings.toJson());
  }

  Future<PomodoroSettings> getSettings() async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('pomodoro')
        .get();

    if (doc.exists) {
      return PomodoroSettings.fromJson(doc.data()!);
    }
    return PomodoroSettings();
  }
}
