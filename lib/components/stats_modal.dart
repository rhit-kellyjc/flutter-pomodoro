import 'package:flutter/material.dart';
import '../models/user_stats.dart';

class StatsModal extends StatefulWidget {
  final UserStats stats;

  const StatsModal({
    super.key,
    required this.stats,
  });

  @override
  StatsModalState createState() => StatsModalState();
}

class StatsModalState extends State<StatsModal> {
  late UserStats stats;

  @override
  void initState() {
    super.initState();
    stats = widget.stats;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1a237e),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(),
          const SizedBox(height: 16),
          const Text(
            'Your Statistics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 24),
          _buildMainStats(),
          const SizedBox(height: 16),
          _buildDetailedStats(),
          const SizedBox(height: 24),
          _buildCloseButton(context),
        ],
      ),
    );
  }

  Widget _buildMainStats() {
    return Column(
      children: [
        Row(
          children: [
            _buildStatCard(
              icon: Icons.timer,
              title: 'Focus Sessions',
              value: stats.totalPomodoros,
              color: Colors.red.shade300,
              subtitle: 'Completed pomodoros',
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              icon: Icons.leaderboard,
              title: 'Ranking',
              value: stats.ranking,
              total: stats.ranking > stats.totalUsers
                  ? stats.totalUsers
                  : stats.totalUsers + 1,
              color: Colors.amber.shade300,
              subtitle: 'Ranking among active users',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard(
              icon: Icons.task_alt,
              title: 'Tasks Done',
              value: stats.totalTasks,
              color: Colors.blue.shade300,
              subtitle: 'Completed tasks',
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              icon: Icons.coffee,
              title: 'Breaks Taken',
              value: stats.totalShortBreaks + stats.totalLongBreaks,
              color: Colors.green.shade300,
              subtitle: 'Short + Long breaks',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildDetailedStats() {
    final totalBreaks = stats.totalShortBreaks + stats.totalLongBreaks;
    final breakRatio =
        totalBreaks > 0 ? stats.totalShortBreaks / totalBreaks * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detailed Breakdown',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Short Breaks',
            stats.totalShortBreaks,
            '${breakRatio.toStringAsFixed(1)}%',
            Colors.green.shade300,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Long Breaks',
            stats.totalLongBreaks,
            '${(100 - breakRatio).toStringAsFixed(1)}%',
            Colors.teal.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      String label, int value, String percentage, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            Text(
              '$value ($percentage)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required int value,
    int? total,
    required Color color,
    String? subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              total != null ? '$value / $total' : value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 12,
        ),
      ),
      child: const Text(
        'Close',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
      ),
    );
  }
}
