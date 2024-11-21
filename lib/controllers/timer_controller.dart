import 'dart:async';
import 'package:flutter/material.dart';
import '../models/pomodoro_session.dart';
import '../models/pomodoro_settings.dart';

class TimerController extends ChangeNotifier {
  Timer? _timer;
  int _timeLeft;
  bool _isRunning = false;
  SessionType _currentSessionType = SessionType.work;
  int _completedSessions = 0;
  PomodoroSettings settings;

  TimerController({required this.settings})
      : _timeLeft = settings.workDuration * 60;

  int get timeLeft => _timeLeft;
  bool get isRunning => _isRunning;
  SessionType get currentSessionType => _currentSessionType;

  void startTimer() {
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        _timeLeft--;
        notifyListeners();
      } else {
        _timer?.cancel();
        _isRunning = false;
        _onSessionComplete();
        notifyListeners();
      }
    });
    notifyListeners();
  }

  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    _setSessionDuration(_currentSessionType);
    notifyListeners();
  }

  void setSessionType(SessionType type) {
    _currentSessionType = type;
    if (!_isRunning) {
      _setSessionDuration(type);
    }
    notifyListeners();
  }

  void _setSessionDuration(SessionType type) {
    switch (type) {
      case SessionType.work:
        _timeLeft = settings.workDuration * 60;
        break;
      case SessionType.shortBreak:
        _timeLeft = settings.shortBreakDuration * 60;
        break;
      case SessionType.longBreak:
        _timeLeft = settings.longBreakDuration * 60;
        break;
    }
  }

  void _onSessionComplete() {
    if (_currentSessionType == SessionType.work) {
      _completedSessions++;
      if (_completedSessions % 4 == 0) {
        setSessionType(SessionType.longBreak);
      } else {
        setSessionType(SessionType.shortBreak);
      }
    } else {
      setSessionType(SessionType.work);
    }
  }

  void updateSettings(PomodoroSettings newSettings) {
    settings = newSettings;
    if (!_isRunning) {
      _setSessionDuration(_currentSessionType);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
