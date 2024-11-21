class PomodoroSettings {
  final int workDuration;
  final int shortBreakDuration;
  final int longBreakDuration;
  final int preferredTheme;

  PomodoroSettings({
    this.workDuration = 25,
    this.shortBreakDuration = 5,
    this.longBreakDuration = 15,
    this.preferredTheme = 0,
  });

  Map<String, dynamic> toJson() => {
        'workDuration': workDuration,
        'shortBreakDuration': shortBreakDuration,
        'longBreakDuration': longBreakDuration,
        'preferredTheme': preferredTheme,
      };

  factory PomodoroSettings.fromJson(Map<String, dynamic> json) {
    return PomodoroSettings(
      workDuration: json['workDuration'] ?? 25,
      shortBreakDuration: json['shortBreakDuration'] ?? 5,
      longBreakDuration: json['longBreakDuration'] ?? 15,
      preferredTheme: json['preferredTheme'] ?? 0,
    );
  }
}
