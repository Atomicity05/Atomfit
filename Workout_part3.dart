import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../global_calories_manager.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:async';
import 'package:health/health.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:lottie/lottie.dart';
//import 'Workout_main.dart';
import 'Workout_part2.dart';
import 'Workout_part3.dart';
import 'Workout_part4.dart';
import 'Leader_board.dart';
import 'dart:ui';

class CaloriesPage extends StatefulWidget {
  const CaloriesPage({Key? key}) : super(key: key);

  @override
  _CaloriesPageState createState() => _CaloriesPageState();
}

class _CaloriesPageState extends State<CaloriesPage> with WidgetsBindingObserver {
  List<double> dailyCalories = List.filled(7, 0);
  double averageCalories = 0;
  double averageSteps = 0;
  List<DateTime> last7Days = [];
  Timer? _healthTimer;
  // HealthKit integration
  bool _healthEnabled = false;
  int _stepsCount = 0;
  double _sleepHours = 0;
  int _calorieBurned = 0;

  // Required Health types
  final List<HealthDataType> _healthTypes = [
    HealthDataType.STEPS,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  // Explicit permissions aligned with the types above
  final List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ,  // STEPS
    HealthDataAccess.READ,  // SLEEP_ASLEEP
    HealthDataAccess.READ,  // ACTIVE_ENERGY_BURNED
  ];

  final Health health = Health();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final today = DateTime.now();
    last7Days = List.generate(7, (index) => today.subtract(Duration(days: 6 - index)));
    _loadCaloriesData();
    if (Platform.isIOS) {
      health.configure();
      _checkPermissions();
      _healthTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
        _fetchHealthData();
      });
    }
  }
  
  @override
  void dispose() {
    _healthTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _healthTimer?.cancel();
      _checkPermissions(); // verify on resume
      _fetchHealthData();
      _healthTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
        _fetchHealthData();
      });
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _healthTimer?.cancel();
    }
  }

  Future<void> _loadCaloriesData() async {
    dailyCalories = await GlobalCaloriesManager.instance.getLast7DaysCalories();
    averageCalories = dailyCalories.reduce((a, b) => a + b) / dailyCalories.length;
    final today = DateTime.now();
    last7Days = List.generate(7, (index) => today.subtract(Duration(days: 6 - index)));
    setState(() {});
  }

  /// Explicit permission check/request without conflating with data availability
  Future<void> _checkPermissions() async {
    try {
      // Check current permission status for required types
      final hasPerms = await health.hasPermissions(_healthTypes, permissions: _permissions) ?? false;

      bool granted = hasPerms;
      if (!hasPerms) {
        // Request only if not already granted
        granted = await health.requestAuthorization(_healthTypes, permissions: _permissions);
      }

      setState(() => _healthEnabled = granted);

      if (granted) {
        // Fetch immediately when permission is confirmed
        await _fetchHealthData();
      } else {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Permission Needed'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 120,
                  child: Lottie.asset('assets/lottie/health_permission.json'),
                ),
                const SizedBox(height: 12),
                const Text(
                  'To access your health data, open the Health app → Profile → Apps → Atomfit, and enable all categories.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Health permission check failed: $e');
      setState(() => _healthEnabled = false);
    }
  }

  /// Fetch last 24h of steps, sleep, and calories
  Future<void> _fetchHealthData() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      // Calculate weekly average calories from HealthKit
      final weekStart = startOfDay.subtract(const Duration(days: 6));
      final weekPoints = await health.getHealthDataFromTypes(
        startTime: weekStart,
        endTime: now,
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
      );
      double weekTotalCalories = 0;
      for (var p in weekPoints) {
        final v = double.tryParse(p.value.toString());
        if (v != null) weekTotalCalories += v;
      }
      final avgWeekCalories = weekTotalCalories / 7;
      final weekStepsTotal = (await health.getTotalStepsInInterval(weekStart, now)) ?? 0;
      final avgWeekSteps = weekStepsTotal / 7;

      final points = await health.getHealthDataFromTypes(
        startTime: startOfDay,
        endTime: now,
        types: _healthTypes,
      );

      // Fetch total steps directly
      final steps = (await health.getTotalStepsInInterval(startOfDay, now)) ?? 0;

      // NOTE: We no longer treat (no data) as (no permission)
      double sleepSec = 0, calories = 0;
      for (var p in points) {
        final val = double.tryParse(p.value.toString());
        if (val == null) continue;
        if (p.type == HealthDataType.SLEEP_ASLEEP) {
          sleepSec += val;
        } else if (p.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
          calories += val;
        }
      }

      debugPrint('[Fetch] Steps: $steps | SleepSec: $sleepSec | Calories: $calories');
      if (!mounted) return;
      setState(() {
        _stepsCount = steps;
        _sleepHours = sleepSec / 3600; // convert to hours
        _calorieBurned = calories.toInt();
        // Add HealthKit calories to today's global calories
        final lastIndex = dailyCalories.length - 1;
        dailyCalories[lastIndex] = dailyCalories[lastIndex] + calories;
        // Recalculate averageCalories using HealthKit weekly average
        averageCalories = avgWeekCalories;
        averageSteps = avgWeekSteps;
      });
      debugPrint('[Updated State] StepsCount: $_stepsCount | SleepHours: $_sleepHours | CalorieBurned: $_calorieBurned');
    } catch (e) {
      debugPrint('Health fetch failed: $e');
      // Keep permissions state as-is; optionally show a non-blocking message/toast if needed.
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('d');
    final rangeFormatter = DateFormat('MMM d');
    final monthYearFormatter = DateFormat('MMM yyyy');

    final dateLabels = last7Days.map((date) => dateFormatter.format(date)).toList();
    final rangeLabel = '${rangeFormatter.format(last7Days.first)} – ${rangeFormatter.format(last7Days.last)}';
    final monthYearLabel = monthYearFormatter.format(last7Days.first);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Hide the back button as per instructions
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFFF6C00),
        elevation: 0,
        title: const Text('Atomfit', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
         /* IconButton(
            icon: const Icon(
              Icons.local_fire_department,
              color: Colors.black,
              size: 40,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CaloriesPage()),
              );
            },
          ),*/
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Platform.isIOS) ...[
              !_healthEnabled
                ? Center(
                    child: ElevatedButton(
                      onPressed: _checkPermissions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF6C00),
                      ),
                      child: const Text("Connect with Apple Health"),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: HealthGoalCard(
                            label: 'STEPS',
                            icon: Icons.directions_walk,
                            value: _stepsCount,
                            goal: 8000,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: HealthGoalCard(
                            label: 'CALORIES',
                            icon: Icons.local_fire_department,
                            value: _calorieBurned,
                            goal: 2000,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: HealthGoalCard(
                            label: 'SLEEP',
                            icon: Icons.bedtime,
                            value: _sleepHours.toInt(),
                            goal: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(dateLabels[value.toInt()], style: const TextStyle(color: Colors.red)),
                        );
                      }),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(value.toInt().toString(), style: const TextStyle(color: Colors.pink)),
                        );
                      }),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(7, (index) => FlSpot(index.toDouble(), dailyCalories[index])),
                      isCurved: true,
                      color: Colors.yellow,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rangeLabel,
                    style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: 7,
                          itemBuilder: (context, index) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  width: 10,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade700,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  ["M", "T", "W", "T", "F", "S", "S"][index],
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            averageCalories.toStringAsFixed(0),
                            style: TextStyle(color: Colors.yellow, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Average (kcal)",
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            averageSteps.toStringAsFixed(0),
                            style: TextStyle(color: Colors.yellow, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Average steps",
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              monthYearLabel,
              style: TextStyle(color: Colors.green, fontSize: 16),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Color(0xFFFF6C00), width: 2),
                borderRadius: BorderRadius.circular(35),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 1. Workout page icon
                  IconButton(
                    icon: Icon(Icons.fitness_center, size: 56, color: Colors.white),
                    onPressed: () {
                    },
                  ),
                  // 2. Calories page icon
                  IconButton(
                    icon: Icon(Icons.local_fire_department, size: 56, color: Color(0xFFFF6C00)),
                    onPressed: () {
                      /*Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const CaloriesPage()),
                      );*/
                    },
                  ),
                  // 3. Leaderboard icon (bigger and elevated)
                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: IconButton(
                      icon: const Icon(Icons.emoji_events, size: 72, color: Colors.white),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LeaderboardPage()),
                        );
                      },
                    ),
                  ),
                  // 4. Profile page icon
                  IconButton(
                    icon: Icon(Icons.person, size: 56, color: Colors.white),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HealthGoalCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final int value;
  final int goal;

  const HealthGoalCard({
    Key? key,
    required this.label,
    required this.icon,
    required this.value,
    required this.goal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color iconColor;
    if (label == 'STEPS') {
      iconColor = Colors.green;
    } else if (label == 'CALORIES') {
      iconColor = Colors.red;
    } else if (label == 'SLEEP') {
      iconColor = Colors.yellow;
    } else {
      iconColor = Colors.white;
    }
    double percent = goal > 0 ? (value / goal).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 6,
                  color: const Color(0xFF0A84FF),
                  backgroundColor: Colors.grey.shade800,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: iconColor),
                  const SizedBox(height: 4),
                  Text(
                    '$value',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text('/$goal', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
