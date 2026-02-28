import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class GlobalCaloriesManager {
  static final GlobalCaloriesManager instance = GlobalCaloriesManager._internal();

  factory GlobalCaloriesManager() {
    return instance;
  }

  GlobalCaloriesManager._internal();

  static const String todayCaloriesKey = 'todayCalories';
  static const String todayDateKey = 'todayDate';
  static const String pastCaloriesKey = 'pastCalories'; // List of last 7 days

  int _todayCalories = 0;
  String _todayDate = '';

  Future<void> initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _todayCalories = prefs.getInt(todayCaloriesKey) ?? 0;
    _todayDate = prefs.getString(todayDateKey) ?? _getCurrentDate();

    if (_todayDate != _getCurrentDate()) {
      await _shiftToHistory();
    }
  }

  Future<void> addCalories(int value) async {
    await initialize(); // Ensure everything is loaded

    if (_todayDate != _getCurrentDate()) {
      await _shiftToHistory();
    }

    _todayCalories += value;
    _todayDate = _getCurrentDate();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(todayCaloriesKey, _todayCalories);
    await prefs.setString(todayDateKey, _todayDate);
  }

  Future<void> _shiftToHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> past = prefs.getStringList(pastCaloriesKey) ?? List.generate(6, (_) => '0');

    past.add(_todayCalories.toString());
    if (past.length > 7) {
      past.removeAt(0);
    }

    await prefs.setStringList(pastCaloriesKey, past);
    _todayCalories = 0;
    _todayDate = _getCurrentDate();
    await prefs.setInt(todayCaloriesKey, 0);
    await prefs.setString(todayDateKey, _todayDate);
  }

  Future<List<double>> getLast7DaysCalories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> past = prefs.getStringList(pastCaloriesKey) ?? List.generate(6, (_) => '0');
    int today = prefs.getInt(todayCaloriesKey) ?? 0;
    past.add(today.toString());

    return past.map((e) => double.tryParse(e) ?? 0.0).toList();
  }

  String _getCurrentDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }
}

//GlobalCaloriesManager.instance.addCalories(100);
/*
                        onPressed: () async {
                          await GlobalCaloriesManager.instance.addCalories(100);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CaloriesPage()),
                          );
                        },
*/
