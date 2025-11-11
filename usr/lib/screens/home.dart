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
              const Color(0xFFB2F5EA).withOpacity(0.5),
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
              if (_controller.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _showAIResponse(context, _controller.text);
              }
            },
            child: const Text('Reflect'),
          ),
        ],
      ),
    );
  }

  void _showAIResponse(BuildContext context, String userInput) {
    String response = _generateReflection(userInput);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mindful Reflection'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You shared:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '"$userInput"',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                response,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _generateReflection(String userInput) {
    final input = userInput.toLowerCase();
    
    // Positive emotions
    if (input.contains('happy') || input.contains('joy') || input.contains('excited')) {
      return 'It\'s wonderful to hear you\'re feeling happy! 😊 These moments of joy are precious. Take a moment to savor this feeling and notice what brought it to you. You deserve this happiness.';
    }
    if (input.contains('grateful') || input.contains('thankful') || input.contains('blessed')) {
      return 'Gratitude is such a beautiful emotion. 🙏 The fact that you\'re noticing and acknowledging what you\'re grateful for shows real mindfulness. This practice can bring even more positivity into your life.';
    }
    if (input.contains('calm') || input.contains('peaceful') || input.contains('relaxed')) {
      return 'Finding moments of calm in our busy lives is so valuable. 😌 You\'ve created space for peace, and that\'s something to honor. Carry this tranquility with you.';
    }
    if (input.contains('proud') || input.contains('accomplished') || input.contains('achieved')) {
      return 'Celebrate your achievements! 🌟 Taking time to recognize your progress, no matter how small, builds confidence and motivation. You should feel proud of yourself.';
    }
    if (input.contains('love') || input.contains('loved') || input.contains('connected')) {
      return 'Connection and love are at the heart of our wellbeing. ❤️ Whether it\'s love for others or self-love, nurturing these feelings enriches your life in beautiful ways.';
    }
    
    // Challenging emotions
    if (input.contains('sad') || input.contains('down') || input.contains('depressed')) {
      return 'I hear that you\'re feeling sad. 💙 It\'s okay to not be okay sometimes. Your feelings are valid. Remember to be gentle with yourself, and know that this feeling won\'t last forever. Small steps forward count.';
    }
    if (input.contains('anxious') || input.contains('worried') || input.contains('nervous')) {
      return 'Anxiety can feel overwhelming. 🌊 Thank you for acknowledging it. Try taking a few deep breaths right now. Remember, worrying about the future takes away from the present moment. You\'re doing better than you think.';
    }
    if (input.contains('stressed') || input.contains('overwhelmed') || input.contains('pressure')) {
      return 'Feeling stressed is your mind\'s way of saying you need care. 🌿 It\'s okay to pause and breathe. Break things down into smaller steps. You don\'t have to do everything at once. Be kind to yourself.';
    }
    if (input.contains('angry') || input.contains('frustrated') || input.contains('mad')) {
      return 'Anger is a valid emotion, and you\'re allowed to feel it. 🔥 What\'s important is acknowledging it without judgment. Take some time to understand what triggered this feeling. You have the power to respond rather than react.';
    }
    if (input.contains('tired') || input.contains('exhausted') || input.contains('drained')) {
      return 'Exhaustion is your body asking for rest. 😴 It\'s not weakness—it\'s a signal. Honor your need for recovery. Even a few minutes of rest or a gentle walk can help restore your energy. You deserve to recharge.';
    }
    if (input.contains('lonely') || input.contains('alone') || input.contains('isolated')) {
      return 'Feeling lonely can be really difficult. 🤗 Remember that reaching out, even in small ways, can help. You\'re not truly alone—your feelings matter, and there are people who care. This moment will pass.';
    }
    if (input.contains('confused') || input.contains('lost') || input.contains('uncertain')) {
      return 'Not knowing what to feel or where to go is part of being human. 🧭 It\'s okay to sit with uncertainty. Clarity often comes when we stop forcing it. Trust that you\'ll find your way, one small step at a time.';
    }
    if (input.contains('scared') || input.contains('afraid') || input.contains('fear')) {
      return 'Fear is uncomfortable, but it shows you care about something important. 💜 Acknowledge your fear without letting it control you. You\'re braver than you think, and you\'ve overcome challenges before.';
    }
    
    // Neutral or general
    if (input.contains('okay') || input.contains('fine') || input.contains('alright')) {
      return 'Sometimes "okay" is enough, and that\'s perfectly valid. 💭 Not every day needs to be extraordinary. You\'re showing up, and that matters. Keep taking things one moment at a time.';
    }
    if (input.contains('don\'t know') || input.contains('not sure') || input.contains('mixed')) {
      return 'It\'s completely normal to have mixed or unclear feelings. 🌈 Emotions can be complex and layered. Give yourself permission to feel whatever comes up without needing to label or fix it right away.';
    }
    
    // Default personalized response
    return 'Thank you for sharing what\'s on your mind. 💭 Your feelings matter, and taking time to express them is a meaningful act of self-care. Whatever you\'re experiencing right now, know that it\'s okay to feel it. Be gentle with yourself today.';
  }
}
