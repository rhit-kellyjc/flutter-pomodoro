enum SessionType { work, shortBreak, longBreak }

class PomodoroSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final SessionType type;
  final bool completed;

  PomodoroSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.type,
    this.completed = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'type': type.toString(),
        'completed': completed,
      };

  factory PomodoroSession.fromJson(Map<String, dynamic> json) =>
      PomodoroSession(
        id: json['id'],
        startTime: DateTime.parse(json['startTime']),
        endTime:
            json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
        type: SessionType.values.firstWhere(
          (e) => e.toString() == json['type'],
        ),
        completed: json['completed'],
      );
}
