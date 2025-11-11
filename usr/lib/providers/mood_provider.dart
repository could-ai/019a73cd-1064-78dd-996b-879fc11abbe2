import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mindmosaic/models/mood_entry.dart';

class MoodProvider with ChangeNotifier {
  List<MoodEntry> _moodEntries = [];

  List<MoodEntry> get moodEntries => _moodEntries;

  MoodProvider() {
    _loadMoodEntries();
  }

  void addMoodEntry(MoodEntry entry) {
    _moodEntries.add(entry);
    _saveMoodEntries();
    notifyListeners();
  }

  void _loadMoodEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? entriesJson = prefs.getString('moodEntries');
    if (entriesJson != null) {
      final List<dynamic> decoded = json.decode(entriesJson);
      _moodEntries = decoded.map((e) => MoodEntry.fromJson(e)).toList();
    }
    notifyListeners();
  }

  void _saveMoodEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String entriesJson = json.encode(_moodEntries.map((e) => e.toJson()).toList());
    prefs.setString('moodEntries', entriesJson);
  }
}