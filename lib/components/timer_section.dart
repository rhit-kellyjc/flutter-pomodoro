import 'package:flutter/material.dart';
import '../models/pomodoro_session.dart';
import '../models/pomodoro_settings.dart';
import 'timer_display.dart';

class TimerSection extends StatelessWidget {
  final SessionType currentSessionType;
  final bool isRunning;
  final int timeLeft;
  final PomodoroSettings settings;
  final Function(SessionType) onSessionTypeChanged;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;
  final VoidCallback onSettingsPressed;
  final Color baseColor;

  const TimerSection({
    super.key,
    required this.currentSessionType,
    required this.isRunning,
    required this.timeLeft,
    required this.settings,
    required this.onSessionTypeChanged,
    required this.onStart,
    required this.onPause,
    required this.onReset,
    required this.onSettingsPressed,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSessionTypeButtons(),
          const SizedBox(height: 32),
          TimerDisplay(
            minutes: timeLeft ~/ 60,
            seconds: timeLeft % 60,
          ),
          const SizedBox(height: 24),
          _buildControlButtons(),
        ],
      ),
    );
  }

  Widget _buildSessionTypeButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSessionButton('Pomodoro', SessionType.work),
        const SizedBox(width: 12),
        _buildSessionButton('Short Break', SessionType.shortBreak),
        const SizedBox(width: 12),
        _buildSessionButton('Long Break', SessionType.longBreak),
      ],
    );
  }

  Widget _buildSessionButton(String title, SessionType type) {
    final isSelected = currentSessionType == type;
    return TextButton(
      onPressed: () => onSessionTypeChanged(type),
      style: TextButton.styleFrom(
        backgroundColor:
            isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton(
          icon: Icons.refresh,
          onPressed: onReset,
        ),
        const SizedBox(width: 16),
        _buildControlButton(
          icon: isRunning ? Icons.pause : Icons.play_arrow,
          onPressed: isRunning ? onPause : onStart,
        ),
        const SizedBox(width: 16),
        _buildControlButton(
          icon: Icons.settings,
          onPressed: onSettingsPressed,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        iconSize: 24,
        color: baseColor,
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}
