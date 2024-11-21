import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../components/app_header.dart';
import '../components/add_task_modal.dart';
import '../components/background_picker.dart';
import '../components/timer_display.dart';
import '../components/settings_modal.dart';
import '../models/task.dart';
import '../models/pomodoro_session.dart';
import '../models/pomodoro_settings.dart';
import '../models/background_option.dart';
import '../managers/auth_manager.dart';
import '../managers/task_manager.dart';
import '../managers/settings_manager.dart';
import '../managers/stats_manager.dart';

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage>
    with SingleTickerProviderStateMixin {
  final AuthManager _authManager = AuthManager();
  final TaskManager _taskManager = TaskManager();
  late SettingsManager _settingsManager =
      SettingsManager(userId: _authManager.currentUser?.uid ?? 'default');
  late StatsManager _statsManager =
      StatsManager(userId: _authManager.currentUser?.uid ?? 'default');

  late Timer _timer;
  int _timeLeft = 25 * 60;
  bool _isRunning = false;
  SessionType _currentSessionType = SessionType.work;
  int _completedSessions = 0;

  final List<Task> _tasks = [];
  final _taskTitleController = TextEditingController();
  final _taskNotesController = TextEditingController();

  late PomodoroSettings _settings;

  late AnimationController _backgroundFadeController;
  late Animation<double> _backgroundFadeAnimation;
  int _selectedBackgroundIndex = 0;

  final List<BackgroundOption> _backgroundOptions = const [
    BackgroundOption(
      name: 'Deep Purple',
      color: Color(0xFF673AB7),
    ),
    BackgroundOption(
      name: 'Ocean Blue',
      color: Color(0xFF1565C0),
    ),
    BackgroundOption(
      name: 'Forest Green',
      color: Color(0xFF2E7D32),
    ),
    BackgroundOption(
      name: 'Midnight Blue',
      color: Color(0xFF1A237E),
    ),
    BackgroundOption(
      name: 'Sunset',
      imagePath: 'sunset.jpg',
    ),
    BackgroundOption(
      name: 'Night Sky',
      imagePath: 'night_sky.jpg',
    ),
    BackgroundOption(
      name: 'Beach',
      imagePath: 'beach.jpg',
    ),
    BackgroundOption(
      name: 'Rain',
      imagePath: 'rain.jpg',
    ),
    BackgroundOption(
      name: 'Prairie',
      imagePath: 'prairie.jpg',
    ),
    BackgroundOption(
      name: 'RHIT',
      imagePath: 'rose_hulman.jpeg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeSettings();
    _initializeTimer();
    _initializeBackgroundAnimation();
    _initializeAuthListener();
  }

  void _initializeSettings() {
    _settings = PomodoroSettings(
      workDuration: 25,
      shortBreakDuration: 5,
      longBreakDuration: 15,
      preferredTheme: 0,
    );
    _loadSettings();
  }

  void _initializeTimer() {
    _timer = Timer(Duration.zero, () {});
  }

  void _initializeBackgroundAnimation() {
    _backgroundFadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _backgroundFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _backgroundFadeController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _initializeAuthListener() async {
    _authManager.authStateChanges.listen((user) {
      if (user != null) {
        _settingsManager = SettingsManager(userId: user.uid);
        _statsManager = StatsManager(userId: user.uid);
        _loadUserData();
        _loadSettings();
      } else {
        _signInAnonymously();
      }
    });

    if (_authManager.currentUser == null) {
      await _signInAnonymously();
    }
  }

  Future<void> _signInAnonymously() async {
    try {
      await _authManager.signInAnonymously();
    } catch (e) {
      _showErrorSnackBar('Error signing in anonymously');
    }
  }

  Future<void> _loadSettings() async {
    if (_authManager.currentUser != null) {
      final settings = await _settingsManager.getSettings();
      setState(() {
        _settings = settings;
        _selectedBackgroundIndex = settings.preferredTheme;
        if (!_isRunning) {
          switch (_currentSessionType) {
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
      });
      _backgroundFadeController.forward(from: 0);
    }
  }

  Future<void> _loadUserData() async {
    if (_authManager.currentUser == null) return;

    try {
      final tasks = await _taskManager.getTasks(_authManager.currentUser!.uid);
      setState(() {
        _tasks.clear();
        _tasks.addAll(tasks);
      });
    } catch (e) {
      _showErrorSnackBar('Error loading tasks');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          timer.cancel();
          _isRunning = false;
          _onSessionComplete();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer.cancel();
    setState(() {
      _isRunning = false;
      switch (_currentSessionType) {
        case SessionType.work:
          _timeLeft = _settings.workDuration * 60;
          break;
        case SessionType.shortBreak:
          _timeLeft = _settings.shortBreakDuration * 60;
          break;
        case SessionType.longBreak:
          _timeLeft = _settings.longBreakDuration * 60;
          break;
      }
    });
  }

  Future<void> _onSessionComplete() async {
    if (_authManager.currentUser != null) {
      try {
        await _statsManager.updateStats(
          isPomodoro: _currentSessionType == SessionType.work,
          isShortBreak: _currentSessionType == SessionType.shortBreak,
          isLongBreak: _currentSessionType == SessionType.longBreak,
        );
      } catch (e) {
        _showErrorSnackBar('Error updating statistics');
      }
    }

    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.heavyImpact();

    if (_currentSessionType == SessionType.work) {
      _completedSessions++;
      if (_completedSessions % 4 == 0) {
        _setSessionType(SessionType.longBreak);
      } else {
        _setSessionType(SessionType.shortBreak);
      }
    } else {
      _setSessionType(SessionType.work);
    }
  }

  void _setSessionType(SessionType type) {
    if (_currentSessionType != type) {
      setState(() {
        _currentSessionType = type;
        switch (type) {
          case SessionType.work:
            _timeLeft = _settings.workDuration * 60;
            break;
          case SessionType.shortBreak:
            _timeLeft = _settings.shortBreakDuration * 60;
            break;
          case SessionType.longBreak:
            _timeLeft = _settings.longBreakDuration * 60;
            break;
        }
      });
    }
  }

  void _showBackgroundPicker() {
    BackgroundPickerModal.show(
      context,
      options: _backgroundOptions,
      selectedIndex: _selectedBackgroundIndex,
      onBackgroundSelected: (index) async {
        setState(() {
          _selectedBackgroundIndex = index;
        });
        if (_authManager.currentUser != null) {
          final newSettings = PomodoroSettings(
            workDuration: _settings.workDuration,
            shortBreakDuration: _settings.shortBreakDuration,
            longBreakDuration: _settings.longBreakDuration,
            preferredTheme: index,
          );
          await _settingsManager.saveSettings(newSettings);
          setState(() {
            _settings = newSettings;
          });
        }
        _backgroundFadeController.forward(from: 0);
      },
    );
  }

  void _showSettingsModal() {
    SettingsModal.show(
      context,
      initialSettings: _settings,
      themes: _backgroundOptions,
      onSettingsChanged: (newSettings) async {
        await _settingsManager.saveSettings(newSettings);
        setState(() {
          _settings = newSettings;
          _selectedBackgroundIndex = newSettings.preferredTheme;
          if (!_isRunning) {
            switch (_currentSessionType) {
              case SessionType.work:
                _timeLeft = newSettings.workDuration * 60;
                break;
              case SessionType.shortBreak:
                _timeLeft = newSettings.shortBreakDuration * 60;
                break;
              case SessionType.longBreak:
                _timeLeft = newSettings.longBreakDuration * 60;
                break;
            }
          }
        });
        _backgroundFadeController.forward(from: 0);
      },
    );
  }

  Future<void> _handleTaskAdded(Task task) async {
    setState(() => _tasks.add(task));

    if (_authManager.currentUser != null) {
      try {
        await _taskManager.saveTask(_authManager.currentUser!.uid, task);
      } catch (e) {
        _showErrorSnackBar('Error saving task');
      }
    }
  }

  Future<void> _handleTaskDeleted(Task task) async {
    setState(() {
      _tasks.removeWhere((t) => t.id == task.id);
    });

    if (_authManager.currentUser != null) {
      try {
        await _taskManager.deleteTask(_authManager.currentUser!.uid, task.id);
      } catch (e) {
        _showErrorSnackBar('Error deleting task');
      }
    }
  }

  Future<void> _handleTaskCompletionToggled(Task task) async {
    if (_authManager.currentUser == null) return;

    try {
      setState(() {
        task.isCompleted = !task.isCompleted;
      });

      await _statsManager.updateTaskStats(increment: true);

      await _taskManager.updateTaskCompletion(
        _authManager.currentUser!.uid,
        task.id,
        task.isCompleted,
      );

      if (task.isCompleted) {
        await Future.delayed(const Duration(milliseconds: 500));
        await _handleTaskDeleted(task);
      }

      HapticFeedback.selectionClick();
    } catch (e) {
      _showErrorSnackBar('Error updating task');
      task.isCompleted = !task.isCompleted;
      setState(() {});
    }
  }

  void _showAddTaskModal() {
    AddTaskModal.show(
      context,
      titleController: _taskTitleController,
      notesController: _taskNotesController,
      onTaskAdded: _handleTaskAdded,
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _taskTitleController.dispose();
    _taskNotesController.dispose();
    _backgroundFadeController.dispose();
    super.dispose();
  }

  Color _getBaseColor() {
    switch (_currentSessionType) {
      case SessionType.work:
        return const Color(0xFFBA4949);
      case SessionType.shortBreak:
        return const Color(0xFF38858A);
      case SessionType.longBreak:
        return const Color(0xFF397097);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedBackground = _backgroundOptions[_selectedBackgroundIndex];
    final baseColor = _getBaseColor();

    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundFadeAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: selectedBackground.color ?? baseColor,
              image: selectedBackground.imagePath != null
                  ? DecorationImage(
                      image: AssetImage(selectedBackground.imagePath!),
                      fit: BoxFit.cover,
                      opacity: _backgroundFadeAnimation.value,
                      colorFilter: ColorFilter.mode(
                        baseColor.withOpacity(0.5),
                        BlendMode.overlay,
                      ),
                    )
                  : null,
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              AppHeader(
                authManager: _authManager,
                onThemePressed: _showBackgroundPicker,
                currentBackground: selectedBackground,
              ),
              _buildTimerSection(baseColor),
              _buildTasksSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerSection(Color baseColor) {
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
            minutes: _timeLeft ~/ 60,
            seconds: _timeLeft % 60,
          ),
          const SizedBox(height: 24),
          _buildControlButtons(baseColor),
        ],
      ),
    );
  }

  Widget _buildSessionTypeButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSessionButton('Pomodoro', SessionType.work),
          const SizedBox(width: 8),
          _buildSessionButton('Short Break', SessionType.shortBreak),
          const SizedBox(width: 8),
          _buildSessionButton('Long Break', SessionType.longBreak),
        ],
      ),
    );
  }

  Widget _buildSessionButton(String title, SessionType type) {
    final isSelected = _currentSessionType == type;
    return TextButton(
      onPressed: () => _setSessionType(type),
      style: TextButton.styleFrom(
        backgroundColor:
            isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildControlButtons(Color baseColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetTimer,
            iconSize: 24,
            color: baseColor,
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: IconButton(
            icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
            onPressed: _isRunning ? _pauseTimer : _startTimer,
            iconSize: 24,
            color: baseColor,
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsModal,
            iconSize: 24,
            color: baseColor,
            padding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildTasksSection() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tasks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: _showAddTaskModal,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildTasksList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList() {
    if (_tasks.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.only(top: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Add tasks to be shown here',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      itemCount: _tasks.length,
      onReorderStart: (_) => HapticFeedback.mediumImpact(),
      onReorderEnd: (_) => HapticFeedback.mediumImpact(),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final task = _tasks.removeAt(oldIndex);
          _tasks.insert(newIndex, task);
        });
      },
      itemBuilder: (context, index) => _buildTaskItem(_tasks[index]),
    );
  }

  Widget _buildTaskItem(Task task) {
    return Container(
      key: Key(task.id),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                  color: Colors.white,
                ),
                onPressed: () => _handleTaskCompletionToggled(task),
              ),
            ],
          ),
          title: Text(
            task.title,
            style: TextStyle(
              color: Colors.white,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: task.notes != null
              ? Text(
                  task.notes!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                )
              : null,
          trailing: const Icon(
            Icons.drag_handle,
            color: Colors.white54,
          ),
        ),
      ),
    );
  }
}
