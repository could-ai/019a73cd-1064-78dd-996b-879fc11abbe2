import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mindmosaic/providers/theme_provider.dart';
import 'package:mindmosaic/screens/mood_checkin.dart';
import 'package:mindmosaic/screens/exercise.dart';
import 'package:mindmosaic/screens/insights.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MindMosaic'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
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
                'Good morning!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'How are you feeling today?',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  children: [
                    _buildCard(
                      context,
                      'Mood Check-in',
                      Icons.mood,
                      Colors.green.shade200,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MoodCheckInScreen()),
                      ),
                    ),
                    _buildCard(
                      context,
                      'Breathing Exercise',
                      Icons.air,
                      Colors.blue.shade200,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ExerciseScreen()),
                      ),
                    ),
                    _buildCard(
                      context,
                      'Daily Reflection',
                      Icons.self_improvement,
                      Colors.purple.shade200,
                      () => _showReflectionDialog(context),
                    ),
                    _buildCard(
                      context,
                      'Insights',
                      Icons.analytics,
                      Colors.orange.shade200,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const InsightsScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showReflectionDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share how you feel'),
        content: TextField(
          controller: _controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Type a sentence about your feelings...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showAIResponse(context, _controller.text);
              },
              child: const Text('Reflect'),
            ),
        ],
      ),
    );
  }

  void _showAIResponse(BuildContext context, String userInput) {
    // Mock AI response
    String response = 'Thank you for sharing. It\'s okay to feel this way. Remember to be kind to yourself today.';
    if (userInput.toLowerCase().contains('happy')) {
      response = 'That\'s wonderful! Cherish those moments of joy.';
    } else if (userInput.toLowerCase().contains('sad')) {
      response = 'I\'m sorry you\'re feeling down. Small steps can help.';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mindful Reflection'),
        content: Text(response),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}