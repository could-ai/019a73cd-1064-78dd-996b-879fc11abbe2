import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mindmosaic/providers/mood_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final entries = moodProvider.moodEntries;

    // Calculate average rating and mood distribution
    final totalEntries = entries.length;
    final averageRating = totalEntries > 0
        ? entries.map((e) => e.rating).reduce((a, b) => a + b) / totalEntries
        : 0.0;

    final moodCounts = <String, int>{};
    for (final entry in entries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          child: totalEntries == 0
              ? const Center(
                  child: Text(
                    'No data yet. Start with a mood check-in!',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView(
                  children: [
                    const Text(
                      'Your Progress',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              'Average Energy Level',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 36, color: Colors.deepPurple),
                            ),
                            LinearProgressIndicator(
                              value: averageRating / 5,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              'Mood Distribution',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 200,
                              child: PieChart(
                                PieChartData(
                                  sections: moodCounts.entries.map((entry) {
                                    final percentage = (entry.value / totalEntries) * 100;
                                    return PieChartSectionData(
                                      value: entry.value.toDouble(),
                                      title: '${entry.key}\n${percentage.toStringAsFixed(1)}%',
                                      color: _getMoodColor(entry.key),
                                      radius: 60,
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Recent Entries',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ...entries.take(5).map((entry) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text('${entry.mood} (${entry.rating}/5)'),
                        subtitle: Text(entry.date.toString().split(' ')[0]),
                      ),
                    )),
                  ],
                ),
        ),
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'happy':
        return Colors.yellow;
      case 'calm':
        return Colors.green;
      case 'neutral':
        return Colors.grey;
      case 'sad':
        return Colors.blue;
      case 'anxious':
        return Colors.red;
      default:
        return Colors.purple;
    }
  }
}