import 'package:flutter/material.dart';

class TimerDisplay extends StatelessWidget {
  final int minutes;
  final int seconds;

  const TimerDisplay({
    super.key,
    required this.minutes,
    required this.seconds,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final baseFontSize = screenWidth * 0.2;
    final fontSize = baseFontSize.clamp(48.0, 120.0);
    final horizontalPadding = screenWidth * 0.08;
    final verticalPadding = screenHeight * 0.03;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTimeSegment(minutes.toString().padLeft(2, '0'), fontSize),
          _buildSeparator(fontSize),
          _buildTimeSegment(seconds.toString().padLeft(2, '0'), fontSize),
        ],
      ),
    );
  }

  Widget _buildTimeSegment(String value, double fontSize) {
    return Text(
      value,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 1,
        letterSpacing: 2,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildSeparator(double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: Colors.white.withOpacity(0.8),
          height: 1,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}
