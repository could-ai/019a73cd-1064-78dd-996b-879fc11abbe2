import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> with TickerProviderStateMixin {
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;
  Timer? _timer;
  int _secondsRemaining = 60;
  bool _isPlaying = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _selectedExercise = 'deep';

  final Map<String, Map<String, dynamic>> _exercises = {
    'deep': {
      'name': 'Deep Breathing',
      'description': 'Breathe in as it grows, out as it shrinks.',
      'duration': 60,
      'cycleDuration': 8,
      'color': Colors.deepPurple,
      'instruction': 'Inhale deeply through your nose, exhale slowly through your mouth.',
    },
    'box': {
      'name': 'Box Breathing',
      'description': 'Inhale, hold, exhale, hold - 4 counts each.',
      'duration': 60,
      'cycleDuration': 16,
      'color': Colors.blue,
      'instruction': 'Breathe in for 4, hold for 4, out for 4, hold for 4.',
    },
    '478': {
      'name': '4-7-8 Breathing',
      'description': 'A calming breath for anxiety relief.',
      'duration': 60,
      'cycleDuration': 19,
      'color': Colors.teal,
      'instruction': 'Inhale for 4, hold for 7, exhale for 8.',
    },
    'calm': {
      'name': 'Calm Breathing',
      'description': 'Slow, gentle breaths for instant relaxation.',
      'duration': 60,
      'cycleDuration': 6,
      'color': Colors.green,
      'instruction': 'Breathe slowly and naturally, focusing on the rhythm.',
    },
    'energize': {
      'name': 'Energizing Breath',
      'description': 'Quick breathing to boost energy and focus.',
      'duration': 45,
      'cycleDuration': 4,
      'color': Colors.orange,
      'instruction': 'Take quick, energizing breaths to awaken your mind.',
    },
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _breatheController = AnimationController(
      duration: Duration(seconds: _exercises[_selectedExercise]!['cycleDuration']),
      vsync: this,
    )..repeat(reverse: true);
    _breatheAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _changeExercise(String exerciseKey) {
    setState(() {
      _selectedExercise = exerciseKey;
      _secondsRemaining = _exercises[exerciseKey]!['duration'];
      _isPlaying = false;
    });
    _timer?.cancel();
    _breatheController.dispose();
    _initializeAnimation();
  }

  void _startExercise() {
    setState(() {
      _isPlaying = true;
      _secondsRemaining = _exercises[_selectedExercise]!['duration'];
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _stopExercise();
        }
      });
    });
  }

  void _stopExercise() {
    setState(() {
      _isPlaying = false;
    });
    _timer?.cancel();
    _audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = _exercises[_selectedExercise]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Breathing Exercises'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFE6E6FA),
              Colors.blue.shade100,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Exercise selector
            Container(
              height: 120,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  final key = _exercises.keys.elementAt(index);
                  final exercise = _exercises[key]!;
                  final isSelected = _selectedExercise == key;

                  return GestureDetector(
                    onTap: () => _changeExercise(key),
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? exercise['color'].withOpacity(0.3)
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected ? exercise['color'] : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.air,
                              color: exercise['color'],
                              size: 30,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              exercise['name'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Main exercise area
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentExercise['name'],
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        currentExercise['instruction'],
                        style: const TextStyle(fontSize: 16, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),
                    AnimatedBuilder(
                      animation: _breatheAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 150 * _breatheAnimation.value,
                          height: 150 * _breatheAnimation.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentExercise['color'].withOpacity(0.3),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    Text(
                      '${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _isPlaying ? _stopExercise : _startExercise,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentExercise['color'],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(_isPlaying ? 'Stop' : 'Start'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
