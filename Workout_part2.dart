import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'Workout.dart';
import 'Workout_part3.dart';
import 'Workout_part4.dart';
import 'global_calories_manager.dart';

class WorkoutCalendarPage extends StatefulWidget {
  const WorkoutCalendarPage({super.key});

  @override
  State<WorkoutCalendarPage> createState() => _WorkoutCalendarPageState();
}

class _WorkoutCalendarPageState extends State<WorkoutCalendarPage> {
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  Set<DateTime> usedDates = {}; // Track app usage dates
  int dayStreak = 0; // Track current day streak
  int personalBest = 0; // Track personal best streak

  @override
  void initState() {
    super.initState();
    _loadPersonalBest();
    _loadUsedDates(); // Load used dates from SharedPreferences
  }

  void _calculateStreak() {
    DateTime today = DateTime.now();
    int streak = 0;

    for (int i = 0; i < 30; i++) {
      DateTime dateToCheck = today.subtract(Duration(days: i));
      if (usedDates.any((d) => isSameDay(d, dateToCheck))) {
        streak++;
      } else {
        break;
      }
    }

    setState(() {
      dayStreak = streak;
    });

    if (streak > personalBest) {
      setState(() {
        personalBest = streak;
      });
      _updatePersonalBest(streak);
      showCelebration();
    }
  }

  void _loadPersonalBest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      personalBest = prefs.getInt('personalBest') ?? 0;
    });
  }

  void _updatePersonalBest(int newBest) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('personalBest', newBest);
  }

  void showCelebration() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("🎉 New Personal Best!"),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveUsedDates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> dates = usedDates.map((date) => date.toIso8601String()).toList();
    prefs.setStringList('usedDates', dates);
  }

  void _loadUsedDates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? dates = prefs.getStringList('usedDates');
    if (dates != null) {
      setState(() {
        usedDates = dates.map((date) => DateTime.parse(date)).toSet();
      });
    }

    _calculateStreak();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
        appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color(0xFF00A884),
        elevation: 0,
        title: const Text('Atomfit', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      
      
      body: SafeArea(
        child: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 300),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                const SizedBox(height: 10),
                const SizedBox(height: 10),
                const Text('Calendar',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: TableCalendar(
                    key: ValueKey<DateTime>(focusedDay), // Key for AnimatedSwitcher
                    calendarFormat: CalendarFormat.month,
                    focusedDay: focusedDay,
                    firstDay: DateTime(2020),
                    lastDay: DateTime(2030),
                    selectedDayPredicate: (day) => isSameDay(day, selectedDay),
                    onDaySelected: (selected, focused) {
                      setState(() {
                        selectedDay = selected;
                        focusedDay = focused;
                        usedDates.add(selected); // Track usage on selected day
                        _saveUsedDates(); // Save used dates to SharedPreferences
                        _calculateStreak(); // Recalculate streak on day selection
                      });
                    },
                    calendarStyle: CalendarStyle(
                      defaultTextStyle: TextStyle(color: Colors.black),
                      weekendTextStyle: TextStyle(color: Colors.red),
                      outsideTextStyle: TextStyle(color: Colors.grey),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, date, focusedDay) {
                        if (date.isAfter(DateTime.now())) {
                          return null; // Do not decorate future dates
                        }
                        final isToday = isSameDay(date, DateTime.now());
                        final used = usedDates.any((d) => isSameDay(d, date));
                        Color bgColor;
                        Color textColor = Colors.white;
                        if (isToday) {
                          bgColor = Colors.blue;
                          textColor = Colors.white;
                        } else if (used) {
                          bgColor = Colors.green;
                          textColor = Colors.white;
                        } else {
                          bgColor = Colors.red;
                          textColor = Colors.white;
                        }
                        return Container(
                          decoration: BoxDecoration(
                            color: bgColor,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${date.day}',
                            style: TextStyle(color: textColor),
                          ),
                        );
                      },
                    ),
                    headerStyle: const HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      titleTextStyle: TextStyle(color: Colors.black, fontSize: 16),
                      leftChevronIcon:
                          Icon(Icons.chevron_left, color: Colors.grey),
                      rightChevronIcon:
                          Icon(Icons.chevron_right, color: Colors.grey),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(color: Colors.black),
                        weekendStyle: TextStyle(color: Colors.red)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.deepOrange),
                    const SizedBox(width: 6),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text('$dayStreak Day Streak',
                          key: ValueKey<int>(dayStreak), // Key for AnimatedSwitcher
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text('Personal Best: $personalBest', // Display personal best
                      key: ValueKey<int>(personalBest), // Key for AnimatedSwitcher
                      style: const TextStyle(color: Colors.grey, fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
