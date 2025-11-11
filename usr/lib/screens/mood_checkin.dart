import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mindmosaic/providers/mood_provider.dart';
import 'package:mindmosaic/models/mood_entry.dart';

class MoodCheckInScreen extends StatefulWidget {
  const MoodCheckInScreen({super.key});

  @override
  State<MoodCheckInScreen> createState() => _MoodCheckInScreenState();
}

class _MoodCheckInScreenState extends State<MoodCheckInScreen> {
  String? _selectedMood;
  int _rating = 3;

  final Map<String, String> _moods = {
    'happy': '😊',
    'calm': '😌',
    'neutral': '😐',
    'sad': '😢',
    'anxious': '😰',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Check-in'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.mintAccent.shade100.withOpacity(0.5),
              Colors.blue.shade100.withOpacity(0.5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How are you feeling right now?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _moods.entries.map((entry) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMood = entry.key),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _selectedMood == entry.key
                            ? Colors.deepPurple.shade200
                            : Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(entry.value, style: const TextStyle(fontSize: 30)),
                          const SizedBox(height: 5),
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 14,
                              color: _selectedMood == entry.key ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              const Text(
                'Rate your energy level (1-5)',
                style: TextStyle(fontSize: 18),
              ),
              Slider(
                value: _rating.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: _rating.toString(),
                onChanged: (value) => setState(() => _rating = value.toInt()),
              ),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: _selectedMood != null ? _saveMood : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Save Check-in'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveMood() {
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    final entry = MoodEntry(
      date: DateTime.now(),
      mood: _selectedMood!,
      rating: _rating,
    );
    moodProvider.addMoodEntry(entry);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mood check-in saved!')),
    );
  }
}