import 'package:flutter/material.dart';
import 'package:pomodoro/models/background_option.dart';
import 'package:pomodoro/models/pomodoro_settings.dart';

class SettingsModal extends StatefulWidget {
  final PomodoroSettings initialSettings;
  final List<BackgroundOption> themes;
  final Function(PomodoroSettings) onSettingsChanged;

  const SettingsModal({
    super.key,
    required this.initialSettings,
    required this.themes,
    required this.onSettingsChanged,
  });

  static void show(
    BuildContext context, {
    required PomodoroSettings initialSettings,
    required List<BackgroundOption> themes,
    required Function(PomodoroSettings) onSettingsChanged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SettingsModal(
        initialSettings: initialSettings,
        themes: themes,
        onSettingsChanged: onSettingsChanged,
      ),
    );
  }

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  late int _workDuration;
  late int _shortBreakDuration;
  late int _longBreakDuration;
  late int _preferredTheme;

  @override
  void initState() {
    super.initState();
    _workDuration = widget.initialSettings.workDuration;
    _shortBreakDuration = widget.initialSettings.shortBreakDuration;
    _longBreakDuration = widget.initialSettings.longBreakDuration;
    _preferredTheme = widget.initialSettings.preferredTheme;
  }

  Widget _buildDurationSelector(
      String title, int value, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.white),
                onPressed: () => onChanged((value - 1).clamp(1, 60)),
              ),
              Expanded(
                child: Text(
                  '$value minutes',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () => onChanged((value + 1).clamp(1, 60)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Default Theme',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.themes.length,
            itemBuilder: (context, index) {
              final theme = widget.themes[index];
              final isSelected = index == _preferredTheme;
              return GestureDetector(
                onTap: () {
                  setState(() => _preferredTheme = index);
                },
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: theme.color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                    image: theme.imagePath != null
                        ? DecorationImage(
                            image: AssetImage(theme.imagePath!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: isSelected
                      ? const Center(
                          child:
                              Icon(Icons.check, color: Colors.white, size: 32))
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDurationSelector(
                    'Focus Duration',
                    _workDuration,
                    (value) => setState(() => _workDuration = value),
                  ),
                  const SizedBox(height: 24),
                  _buildDurationSelector(
                    'Short Break Duration',
                    _shortBreakDuration,
                    (value) => setState(() => _shortBreakDuration = value),
                  ),
                  const SizedBox(height: 24),
                  _buildDurationSelector(
                    'Long Break Duration',
                    _longBreakDuration,
                    (value) => setState(() => _longBreakDuration = value),
                  ),
                  const SizedBox(height: 24),
                  _buildThemeSelector(),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final newSettings = PomodoroSettings(
                    workDuration: _workDuration,
                    shortBreakDuration: _shortBreakDuration,
                    longBreakDuration: _longBreakDuration,
                    preferredTheme: _preferredTheme,
                  );
                  widget.onSettingsChanged(newSettings);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Settings',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
