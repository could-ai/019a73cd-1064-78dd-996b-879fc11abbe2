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

    // Calculate statistics
    final totalEntries = entries.length;
    final averageRating = totalEntries > 0
        ? entries.map((e) => e.rating).reduce((a, b) => a + b) / totalEntries
        : 0.0;

    // Mood distribution
    final moodCounts = <String, int>{};
    for (final entry in entries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    // Calculate weekly trends
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final weeklyRatings = <double>[];
    final weeklyLabels = <String>[];
    
    for (final day in last7Days) {
      final dayEntries = entries.where((e) => 
        e.date.year == day.year && 
        e.date.month == day.month && 
        e.date.day == day.day
      ).toList();
      
      final avgRating = dayEntries.isEmpty 
        ? 0.0 
        : dayEntries.map((e) => e.rating).reduce((a, b) => a + b) / dayEntries.length;
      
      weeklyRatings.add(avgRating);
      weeklyLabels.add(_getDayLabel(day));
    }

    // Find most common mood
    String? mostCommonMood;
    int maxCount = 0;
    moodCounts.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommonMood = mood;
      }
    });

    // Calculate streak
    int currentStreak = 0;
    if (entries.isNotEmpty) {
      final sortedEntries = List.from(entries)..sort((a, b) => b.date.compareTo(a.date));
      DateTime checkDate = DateTime.now();
      
      for (final entry in sortedEntries) {
        final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
        final compareDate = DateTime(checkDate.year, checkDate.month, checkDate.day);
        
        if (entryDate == compareDate || entryDate == compareDate.subtract(const Duration(days: 1))) {
          currentStreak++;
          checkDate = entry.date;
        } else {
          break;
        }
      }
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
                    
                    // Quick stats row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Check-ins',
                            totalEntries.toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            'Streak',
                            '$currentStreak days',
                            Icons.local_fire_department,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    // Average energy level
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Average Energy Level',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  averageRating.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 28, color: Colors.deepPurple, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: averageRating / 5,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getRatingColor(averageRating),
                              ),
                              minHeight: 10,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _getEnergyInsight(averageRating),
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Weekly trend line chart
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Weekly Energy Trend',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 200,
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(show: true, drawVerticalLine: false),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 30,
                                        interval: 1,
                                        getTitlesWidget: (value, meta) {
                                          if (value % 1 == 0 && value >= 1 && value <= 5) {
                                            return Text(
                                              value.toInt().toString(),
                                              style: const TextStyle(fontSize: 12),
                                            );
                                          }
                                          return const SizedBox();
                                        },
                                      ),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          if (value.toInt() >= 0 && value.toInt() < weeklyLabels.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                weeklyLabels[value.toInt()],
                                                style: const TextStyle(fontSize: 10),
                                              ),
                                            );
                                          }
                                          return const SizedBox();
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  minX: 0,
                                  maxX: 6,
                                  minY: 0,
                                  maxY: 5,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: weeklyRatings.asMap().entries.map((e) {
                                        return FlSpot(e.key.toDouble(), e.value);
                                      }).toList(),
                                      isCurved: true,
                                      color: Colors.deepPurple,
                                      barWidth: 3,
                                      dotData: FlDotData(show: true),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: Colors.deepPurple.withOpacity(0.2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _getWeeklyTrendInsight(weeklyRatings),
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Mood distribution pie chart
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
                            if (mostCommonMood != null)
                              Text(
                                'Most common: ${_getMoodEmoji(mostCommonMood!)} ${_capitalize(mostCommonMood!)} ($maxCount times)',
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                              ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 200,
                              child: PieChart(
                                PieChartData(
                                  sections: moodCounts.entries.map((entry) {
                                    final percentage = (entry.value / totalEntries) * 100;
                                    return PieChartSectionData(
                                      value: entry.value.toDouble(),
                                      title: '${percentage.toStringAsFixed(0)}%',
                                      color: _getMoodColor(entry.key),
                                      radius: 60,
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    );
                                  }).toList(),
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 40,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              alignment: WrapAlignment.center,
                              children: moodCounts.entries.map((entry) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: _getMoodColor(entry.key),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${_getMoodEmoji(entry.key)} ${_capitalize(entry.key)} (${entry.value})',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Recent entries
                    const Text(
                      'Recent Entries',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ...entries.reversed.take(5).map((entry) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        leading: Text(
                          _getMoodEmoji(entry.mood),
                          style: const TextStyle(fontSize: 30),
                        ),
                        title: Text(
                          '${_capitalize(entry.mood)} - Energy: ${entry.rating}/5',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(_formatDate(entry.date)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getMoodColor(entry.mood).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getRatingLabel(entry.rating),
                            style: TextStyle(
                              color: _getMoodColor(entry.mood),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayLabel(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return '${date.month}/${date.day}/${date.year}';
  }

  String _capitalize(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }

  String _getMoodEmoji(String mood) {
    const emojis = {
      'happy': '😊',
      'calm': '😌',
      'excited': '🤩',
      'grateful': '🙏',
      'neutral': '😐',
      'tired': '😴',
      'stressed': '😤',
      'sad': '😢',
      'anxious': '😰',
      'overwhelmed': '😵',
      'angry': '😠',
      'lonely': '😔',
    };
    return emojis[mood] ?? '😐';
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'happy':
      case 'excited':
        return Colors.yellow.shade700;
      case 'calm':
      case 'grateful':
        return Colors.green;
      case 'neutral':
        return Colors.grey;
      case 'tired':
        return Colors.blue.shade300;
      case 'sad':
      case 'lonely':
        return Colors.blue.shade700;
      case 'anxious':
      case 'stressed':
      case 'overwhelmed':
        return Colors.orange;
      case 'angry':
        return Colors.red;
      default:
        return Colors.purple;
    }
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4) return Colors.green;
    if (rating >= 3) return Colors.blue;
    if (rating >= 2) return Colors.orange;
    return Colors.red;
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 5: return 'Excellent';
      case 4: return 'Good';
      case 3: return 'Okay';
      case 2: return 'Low';
      case 1: return 'Very Low';
      default: return 'N/A';
    }
  }

  String _getEnergyInsight(double average) {
    if (average >= 4.0) {
      return 'You\'re maintaining great energy! Keep up the positive momentum.';
    } else if (average >= 3.0) {
      return 'Your energy is steady. Consider breathing exercises when you need a boost.';
    } else if (average >= 2.0) {
      return 'Your energy has been lower lately. Try taking short breaks and practicing self-care.';
    } else {
      return 'Your energy has been quite low. Be gentle with yourself and reach out for support if needed.';
    }
  }

  String _getWeeklyTrendInsight(List<double> ratings) {
    if (ratings.length < 2) return 'Keep logging to see your trends!';
    
    final recentAvg = ratings.sublist(ratings.length - 3).where((r) => r > 0).toList();
    final earlierAvg = ratings.sublist(0, ratings.length - 3).where((r) => r > 0).toList();
    
    if (recentAvg.isEmpty || earlierAvg.isEmpty) {
      return 'Log daily to see your progress patterns!';
    }
    
    final recentMean = recentAvg.reduce((a, b) => a + b) / recentAvg.length;
    final earlierMean = earlierAvg.reduce((a, b) => a + b) / earlierAvg.length;
    
    if (recentMean > earlierMean + 0.5) {
      return '📈 Your energy is trending up! You\'re doing great!';
    } else if (recentMean < earlierMean - 0.5) {
      return '📉 Your energy has dipped recently. Take time for self-care.';
    } else {
      return '➡️ Your energy has been consistent this week.';
    }
  }
}
