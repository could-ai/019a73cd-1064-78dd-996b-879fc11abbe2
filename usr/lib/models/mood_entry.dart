class MoodEntry {
  final DateTime date;
  final String mood; // e.g., 'happy', 'sad', etc.
  final int rating; // 1-5 scale
  final String? reflection;

  MoodEntry({
    required this.date,
    required this.mood,
    required this.rating,
    this.reflection,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'mood': mood,
      'rating': rating,
      'reflection': reflection,
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      date: DateTime.parse(json['date']),
      mood: json['mood'],
      rating: json['rating'],
      reflection: json['reflection'],
    );
  }
}