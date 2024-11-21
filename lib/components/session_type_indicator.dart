import 'package:flutter/material.dart';
import '../models/pomodoro_session.dart';

class SessionTypeIndicator extends StatelessWidget {
  final SessionType type;

  const SessionTypeIndicator({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getTypeColor(type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getTypeText(type),
        style: TextStyle(
          color: _getTypeColor(type),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getTypeColor(SessionType type) {
    switch (type) {
      case SessionType.work:
        return Colors.red;
      case SessionType.shortBreak:
        return Colors.green;
      case SessionType.longBreak:
        return Colors.blue;
    }
  }

  String _getTypeText(SessionType type) {
    switch (type) {
      case SessionType.work:
        return 'Focus Time';
      case SessionType.shortBreak:
        return 'Short Break';
      case SessionType.longBreak:
        return 'Long Break';
    }
  }
}
