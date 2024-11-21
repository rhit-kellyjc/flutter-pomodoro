class UserStats {
  final int totalTasks;
  final int totalPomodoros;
  final int totalShortBreaks;
  final int totalLongBreaks;
  final int ranking;
  final int totalUsers;

  const UserStats({
    this.totalTasks = 0,
    this.totalPomodoros = 0,
    this.totalShortBreaks = 0,
    this.totalLongBreaks = 0,
    this.ranking = 0,
    this.totalUsers = 0,
  });

  UserStats copyWith({
    int? totalTasks,
    int? totalPomodoros,
    int? totalShortBreaks,
    int? totalLongBreaks,
    int? ranking,
    int? totalUsers,
  }) {
    return UserStats(
      totalTasks: totalTasks ?? this.totalTasks,
      totalPomodoros: totalPomodoros ?? this.totalPomodoros,
      totalShortBreaks: totalShortBreaks ?? this.totalShortBreaks,
      totalLongBreaks: totalLongBreaks ?? this.totalLongBreaks,
      ranking: ranking ?? this.ranking,
      totalUsers: totalUsers ?? this.totalUsers,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalTasks': totalTasks,
        'totalPomodoros': totalPomodoros,
        'totalShortBreaks': totalShortBreaks,
        'totalLongBreaks': totalLongBreaks,
        'ranking': ranking,
        'totalUsers': totalUsers,
      };

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
        totalTasks: json['totalTasks'] ?? 0,
        totalPomodoros: json['totalPomodoros'] ?? 0,
        totalShortBreaks: json['totalShortBreaks'] ?? 0,
        totalLongBreaks: json['totalLongBreaks'] ?? 0,
        ranking: json['ranking'] ?? 0,
        totalUsers: json['totalUsers'] ?? 0,
      );

  @override
  String toString() {
    return 'UserStats(totalTasks: $totalTasks, totalPomodoros: $totalPomodoros, '
        'totalShortBreaks: $totalShortBreaks, totalLongBreaks: $totalLongBreaks, '
        'ranking: $ranking, totalUsers: $totalUsers)';
  }
}
