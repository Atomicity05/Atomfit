import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  static const String bmiKey = 'user_bmi';
  static const String historyKey = 'exercise_history';

  Future<void> saveBmi(double bmi) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble(bmiKey, bmi);
  }

  Future<double?> getBmi() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(bmiKey);
  }

  Future<void> saveExerciseHistory(List<String> recentExercises) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(historyKey, jsonEncode(recentExercises));
  }

  Future<List<String>> getExerciseHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(historyKey);
    if (data != null) {
      return List<String>.from(jsonDecode(data));
    }
    return [];
  }

  /// Retrieves the last date the app was opened.
  Future<DateTime?> getLastOpenDate() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt('last_open_date');
    return millis != null ? DateTime.fromMillisecondsSinceEpoch(millis) : null;
  }

  /// Stores the last date the app was opened.
  Future<void> setLastOpenDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_open_date', date.millisecondsSinceEpoch);
  }

  /// Retrieves the stored day count.
  Future<int?> getDayCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('day_count');
  }

  /// Stores the updated day count.
  Future<void> setDayCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('day_count', count);
  }
}
