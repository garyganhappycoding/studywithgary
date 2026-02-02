import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../main.dart';
import '../models/study_session.dart';
import '../models/reward.dart';
import '../models/battle_session.dart';

class StudySessionScreen extends StatefulWidget {
  final VoidCallback? onStudyComplete;
  final BattleSession? battleSession;

  const StudySessionScreen({
    super.key,
    this.onStudyComplete,
    this.battleSession,
  });

  @override
  State<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends State<StudySessionScreen> {
  static const int _pomodoroDurationMinutes = 25;
  static const int _shortBreakDurationMinutes = 5;
  static const int _longBreakDurationMinutes = 15;
  static const int _pomodorosBeforeLongBreak = 4;

  Timer? _timer;
  int _secondsRemaining = _pomodoroDurationMinutes * 60;
  bool _isRunning = false;

  int _pomodoroCount = 0;
  bool _isBreak = false;
  bool _isLongBreak = false;
  DateTime? _sessionStartTime;

  // Tower tracking
  late bool _tower1Completed;
  late bool _tower2Completed;
  late bool _tower3Completed;
  late String _tower1Goal;
  late String _tower2Goal;
  late String _tower3Goal;

  // Reference to the battle session being worked on
  BattleSession? _currentBattleSession;

  @override
  void initState() {
    super.initState();
    _currentBattleSession = widget.battleSession;

    // Initialize tower data from battleSession
    if (_currentBattleSession != null) {
      _tower1Goal = _currentBattleSession!.tower1Goal;
      _tower2Goal = _currentBattleSession!.tower2Goal;
      _tower3Goal = _currentBattleSession!.tower3Goal;
      _tower1Completed = _currentBattleSession!.tower1Won > 0;
      _tower2Completed = _currentBattleSession!.tower2Won > 0;
      _tower3Completed = _currentBattleSession!.tower3Won > 0;
    } else {
      // Fallback or handle cases where no battleSession is passed
      _tower1Goal = "";
      _tower2Goal = "";
      _tower3Goal = "";
      _tower1Completed = false;
      _tower2Completed = false;
      _tower3Completed = false;
    }
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      if (_sessionStartTime == null) {
        _sessionStartTime = DateTime.now();
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        _handleTimerEnd();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsRemaining = _pomodoroDurationMinutes * 60;
      _pomodoroCount = 0;
      _isBreak = false;
      _isLongBreak = false;
      _sessionStartTime = null;
    });
  }

  void _handleTimerEnd() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!_isBreak) {
      _pomodoroCount++;
      userProvider.addArenaPoints(10);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
          Text("Pomodoro #$_pomodoroCount completed! +10 Arena Points!"),
          backgroundColor: Colors.green,
        ),
      );

      if (_pomodoroCount % _pomodorosBeforeLongBreak == 0) {
        _startLongBreak();
      } else {
        _startShortBreak();
      }
      _saveStudySession(userProvider, _pomodoroDurationMinutes);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Break over! Time to study."),
          backgroundColor: Colors.blue,
        ),
      );
      _startPomodoro();
    }
  }

  void _startPomodoro() {
    setState(() {
      _isBreak = false;
      _isLongBreak = false;
      _secondsRemaining = _pomodoroDurationMinutes * 60;
    });
    _startTimer();
  }

  void _startShortBreak() {
    setState(() {
      _isBreak = true;
      _isLongBreak = false;
      _secondsRemaining = _shortBreakDurationMinutes * 60;
    });
    _startTimer();
  }

  void _startLongBreak() {
    setState(() {
      _isBreak = true;
      _isLongBreak = true;
      _secondsRemaining = _longBreakDurationMinutes * 60;
    });
    _startTimer();
  }

  void _saveStudySession(UserProvider userProvider, int durationMinutes) {
    if (_sessionStartTime != null) {
      final session = StudySession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cardId: _currentBattleSession?.id ?? 'default-card',
        cardTitle: _currentBattleSession?.opponentName ?? 'Study Session',
        startTime: _sessionStartTime!,
        endTime: DateTime.now(),
        durationMinutes: durationMinutes,
        completed: true,
        correctAnswers: _pomodoroCount,
        totalQuestions: _pomodoroCount * 5,
      );
      userProvider.addStudySession(session);
      _sessionStartTime = null;
    }
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // Check if all towers are completed
  bool _areAllTowersCompleted() {
    return _tower1Completed && _tower2Completed && _tower3Completed;
  }

  // Handle tower completion and update the provider
  void _toggleTower(int towerNumber) {
    if (_currentBattleSession == null) return; // Safety check

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    bool changed = false;

    setState(() {
      if (towerNumber == 1) {
        _tower1Completed = !_tower1Completed;
        _currentBattleSession!.tower1Won = _tower1Completed ? 1 : 0;
        changed = true;
      } else if (towerNumber == 2) {
        _tower2Completed = !_tower2Completed;
        _currentBattleSession!.tower2Won = _tower2Completed ? 1 : 0;
        changed = true;
      } else if (towerNumber == 3) {
        _tower3Completed = !_tower3Completed;
        _currentBattleSession!.tower3Won = _tower3Completed ? 1 : 0;
        changed = true;
      }
    });

    if (changed) {
      // If a tower's state actually changed, update the provider
      userProvider.updateBattleSession(_currentBattleSession!);

      // Check if all towers are completed
      if (_areAllTowersCompleted()) {
        _timer?.cancel();
        _isRunning = false;

        // Set completedAt for the battle session
        _currentBattleSession!.completedAt = true;
        userProvider.updateBattleSession(_currentBattleSession!);

        // Generate chest and show success message
        _showBattleWonDialog(userProvider);
      }
    }
  }

  // Show battle won dialog
  void _showBattleWonDialog(UserProvider userProvider) {
    final rewardData =
    userProvider.getRandomRewardAndType(RewardType.common);

    userProvider.addChest(
      rewardData['reward'] as String,
      rewardData['type'] as RewardType,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Battle Won!'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'All towers defeated!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('You received a chest! 🎁'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _endBattle();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _endBattle() {
    _timer?.cancel();
    if (_currentBattleSession != null) {
      if (_areAllTowersCompleted() && !_currentBattleSession!.completedAt) {
        _currentBattleSession!.completedAt = true;
      }
      Provider.of<UserProvider>(context, listen: false)
          .updateBattleSession(_currentBattleSession!);
    }
    widget.onStudyComplete?.call();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    String currentMode;
    if (_isBreak && _isLongBreak) {
      currentMode = "Long Break";
    } else if (_isBreak) {
      currentMode = "Short Break";
    } else {
      currentMode = "Focus Time";
    }

    return WillPopScope(
      onWillPop: () async {
        _timer?.cancel();
        if (_currentBattleSession != null) {
          Provider.of<UserProvider>(context, listen: false)
              .updateBattleSession(_currentBattleSession!);
        }
        widget.onStudyComplete?.call();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Study Session"),
          leading: BackButton(
            onPressed: () {
              _timer?.cancel();
              if (_currentBattleSession != null) {
                Provider.of<UserProvider>(context, listen: false)
                    .updateBattleSession(_currentBattleSession!);
              }
              widget.onStudyComplete?.call();
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Towers Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Battle Towers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTowerCheckbox(
                        'Tower 1',
                        'Goal: $_tower1Goal',
                        _tower1Completed,
                            () => _toggleTower(1),
                      ),
                      const SizedBox(height: 8),
                      _buildTowerCheckbox(
                        'Tower 2',
                        'Goal: $_tower2Goal',
                        _tower2Completed,
                            () => _toggleTower(2),
                      ),
                      const SizedBox(height: 8),
                      _buildTowerCheckbox(
                        'Tower 3',
                        'Goal: $_tower3Goal',
                        _tower3Completed,
                            () => _toggleTower(3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                // Timer Section
                Text(
                  currentMode,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _isBreak ? Colors.green : Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _formatTime(_secondsRemaining),
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: ElevatedButton.icon(
                        onPressed: _isRunning ? null : _startTimer,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text("Start"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: ElevatedButton.icon(
                        onPressed: _isRunning ? _pauseTimer : null,
                        icon: const Icon(Icons.pause),
                        label: const Text("Pause"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: ElevatedButton.icon(
                        onPressed: _resetTimer,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Reset"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text(
                  "Pomodoros Completed: $_pomodoroCount",
                  style: const TextStyle(fontSize: 18, color: Colors.blueGrey),
                ),
                const SizedBox(height: 10),
                Text(
                  "Arena Points: ${userProvider.arenaPoints}",
                  style: const TextStyle(fontSize: 18, color: Colors.deepPurple),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: _endBattle,
                  icon: const Icon(Icons.check_circle),
                  label: const Text("End Battle"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build tower checkbox widget
  Widget _buildTowerCheckbox(
      String title,
      String description,
      bool isCompleted,
      VoidCallback onToggle,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isCompleted ? Colors.green : Colors.black,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: isCompleted,
            onChanged: (_) => onToggle(),
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }
}
