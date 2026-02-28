import 'package:flutter/material.dart';
import 'global_calories_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'screens/simple_screen.dart';
//import 'Workout_main.dart';
import 'Workout_part2.dart';
import 'Workout_part3.dart';
import 'Workout_part4.dart';
//import 'welcome_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'models/exercise.dart';
import 'services/workout_planner.dart';
import 'services/local_storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';

class AttractiveWorkoutPage extends StatefulWidget {
  const AttractiveWorkoutPage({Key? key}) : super(key: key);

  @override
  State<AttractiveWorkoutPage> createState() => _AttractiveWorkoutPage();
}

class _AttractiveWorkoutPage extends State<AttractiveWorkoutPage> {
  late final PageController _pageController;
  int _selectedExercise = 0;
  int currentDay = 1;
  int selectedExerciseSet = 1;
  int ExerciseNumber = 1;
  bool _isLoading = false;
  int _currentTabIndex = 0;
  double _todayCalories = 0;
  bool _dataReady = false;

  final List<Color> _exerciseBgColors = [
    Color(0xFFE94560), // Coral red
    Color(0xFF1A1A1A), // Neon black
    Color(0xFF1E3A8A), // Cobalt blue
    Color(0xFF0E8D8A), // Teal
    Color(0xFF1A1A1A), // Neon black
  ];

  final List<List<Color>> _gradients = [
    [Colors.deepPurple, Colors.blueAccent],
    [Colors.blueAccent, Colors.tealAccent],
    [Colors.tealAccent, Colors.purpleAccent],
  ];
  int _gradientIndex = 0;


  // Master list of all 30 exercises (fill in with your full list)
  final List<Map<String, dynamic>> _allExercises = [
    {
      'name': 'Chair Pushups',
      'reps': 20,
      'sets': 4,
      'image': 'assets/images/Set_Chair_Pushups.png',
      'type': 'strength',
      'area': 'Upper Body',
      'intensity': 'medium'
    },
    {
      'name': 'Back Stretch',
      'reps': 20,
      'sets': 4,
      'image': 'assets/images/Set_Back_Stretch.png',
      'type': 'flexibility',
      'area': 'Full Body',
      'intensity': 'low'
    },
    {
      'name': 'Bug',
      'reps': 60,
      'sets': 3,
      //'image': 'assets/images/Set_Bug.png',
      'image': 'assets/images/jumping_jacks.png',
      'type': 'core',
      'area': 'Core',
      'intensity': 'medium'
    },
    {
      'name': 'Chair Step-ups',
      'reps': 10,
      'sets': 3,
      'image': 'assets/images/Set_Chair_Step_ups.png',
      'type': 'strength',
      'area': 'Lower Body',
      'intensity': 'medium'
    },
    {
      'name': 'Dead Bug',
      'reps': 20,
      'sets': 4,
      'image': 'assets/images/Set_Dead_Bug.png',
      'type': 'core',
      'area': 'Core',
      'intensity': 'medium'
    },
    {
      'name': 'Jumping Jacks',
      'reps': 20,
      'sets': 4,
      'image': 'assets/images/jumping_jacks.png',
      
      'type': 'cardio',
      'area': 'Full Body',
      'intensity': 'high'
    },
    {
      'name': 'Sklony (Side Bends)',
      'reps': 20,
      'sets': 4,
      'image': 'assets/images/Set_Sklony_Side_Bends.png',
      'type': 'flexibility',
      'area': 'Full Body',
      'intensity': 'low'
    },
    {
      'name': 'Sklony Half',
      'reps': 10,
      'sets': 3,
      'image': 'assets/images/Set_Sklony_Half.png',
      'type': 'flexibility',
      'area': 'Full Body',
      'intensity': 'low'
    },
    {
      'name': 'Bicycle',
      'reps': 10,
      'sets': 3,
      'image': 'assets/images/Set_Bicycle.png',
      'type': 'cardio',
      'area': 'Full Body',
      'intensity': 'high'
    },
    {
      'name': 'Bicycle Crunch',
      'reps': 15,
      'sets': 3,
      'image': 'assets/images/Set_Bicycle_Crunch.png',
      'type': 'core',
      'area': 'Core',
      'intensity': 'medium'
    },
    {
      'name': 'Brzuszki (Sit-ups)',
      'reps': 20,
      'sets': 4,
      //'image': 'assets/images/Set_Brzuszki_Sit_ups.png',
      'image': 'assets/images/jumping_jacks.png',
      'type': 'core',
      'area': 'Core',
      'intensity': 'medium'
    },
    {
      'name': 'But Up',
      'reps': 20,
      'sets': 3,
      'image': 'assets/images/Set_But_Up.png',
      'type': 'strength',
      'area': 'Lower Body',
      'intensity': 'medium'
    },
    {
      'name': 'Crunch',
      'reps': 10,
      'sets': 3,
      'image': 'assets/images/Set_Crunch.png',
      'type': 'core',
      'area': 'Core',
      'intensity': 'medium'
    },
    {
      'name': 'Leg Raiser',
      'reps': 20,
      'sets': 4,
      'image': 'assets/images/Set_legRaisesCount.png',
      'type': 'core',
      'area': 'Core',
      'intensity': 'medium'
    },
    {
      'name': 'Leg Twist Touch',
      'reps': 15,
      'sets': 3,
      'image': 'assets/images/Set_Leg_Twist_Touch.png',
      'type': 'core',
      'area': 'Core',
      'intensity': 'medium'
    },
    {
      'name': 'Jumping Jacks',
      'reps': 20,
      'sets': 4,
      'image': 'assets/images/jumping_jacks.png',
      'type': 'cardio',
      'area': 'Full Body',
      'intensity': 'high'
    },
    {
      'name': 'Push-ups',
      'reps': 20,
      'sets': 3,
      'image': 'assets/images/Set_Push_ups.png',
      'type': 'strength',
      'area': 'Upper Body',
      'intensity': 'medium'
    },
    {
      'name': 'Scissors',
      'reps': 30,
      'sets': 3,
      'image': 'assets/images/Set_Scissors.png',
      'type': 'core',
      'area': 'Core',
      'intensity': 'medium'
    },
    {
      'name': 'Squats Weight',
      'reps': 20,
      'sets': 4,
      'image': 'assets/images/Set_Squats_Weight.png',
      'type': 'strength',
      'area': 'Lower Body',
      'intensity': 'high'
    },
    {
      'name': 'Twist Down',
      'reps': 20,
      'sets': 4,
      'image': 'assets/images/Set_Twist_Down.png',
      'type': 'core',
      'area': 'Core',
      'intensity': 'medium'
    },
    {
      'name': 'Wypady Boki (Side Lunges)',
      'reps': 10,
      'sets': 3,
      'image': 'assets/images/wypady_boki_side_lunges.png',
      
      'type': 'strength',
      'area': 'Lower Body',
      'intensity': 'medium'
    },
    {
      'name': 'Wypady Front (Front Lunges)',
      'reps': 20,
      'sets': 4,
      'image': 'assets/images/wypady_front_lunges.png',
      
      'type': 'strength',
      'area': 'Lower Body',
      'intensity': 'medium'
    },
    {
      'name': 'Jumping Jacks',
      'reps': 20,
      'sets': 4,
      'image': 'assets/images/jumping_jacks.png',
      'type': 'cardio',
      'area': 'Full Body',
      'intensity': 'high'
    },
    {
      'name': 'Mountain Climbers',
      'reps': 20,
      'sets': 4,
      'image': 'assets/images/mountain_climbers.png',
      'type': 'cardio',
      'area': 'Full Body',
      'intensity': 'high'
    },
    {
      'name': 'Przysiady (Deep Squats)',
      'reps': 20,
      'sets': 4,
      'image': 'assets/images/Przysiady_Squats.png',
      'type': 'strength',
      'area': 'Lower Body',
      'intensity': 'high'
    },
    {
      'name': 'Pull-ups',
      'reps': 30,
      'sets': 3,
      'image': 'assets/images/Set_Pull_ups.png',
      'type': 'strength',
      'area': 'Upper Body',
      'intensity': 'high'
    },
    {
      'name': 'Moderate Pace Run',
      'reps': 10,
      'sets': 3,
      'image': 'assets/images/moderate_pace_run.png',
      'type': 'cardio',
      'area': 'Full Body',
      'intensity': 'high'
    },
    {
      'name': 'Stand-up Jump',
      'reps': 20,
      'sets': 3,
      'image': 'assets/images/stand_up_jump.png',
      'type': 'plyo',
      'area': 'Full Body',
      'intensity': 'high'
    },
    {
      'name': 'Swing Pull-up Weight',
      'reps': 10,
      'sets': 3,
      'image': 'assets/images/swing_Pullup_weight.png',
      'type': 'plyo',
      'area': 'Full Body',
      'intensity': 'high'
    },
    {
      'name': 'Swing Weight',
      'reps': 10,
      'sets': 3,
      'image': 'assets/images/Swing_Weight.png',
      'type': 'strength',
      'area': 'Upper Body',
      'intensity': 'medium'
    },
    // … add the remaining 29 exercise definitions here …
  ];

  // Holds the 3 randomly selected exercises for today
  late List<Map<String, dynamic>> _selectedExercises;

  // Stores the original master-list indices for the 4 selected exercises
  late List<int> _selectedExerciseIndices;

  Future<void> _generateSmartExercises() async {
    try {
      final planner = WorkoutPlanner(LocalStorageService());
      final aiExercises = await planner.generateTodayWorkout();

      // Map AI exercises back to _allExercises using name matching and set reps/sets by intensity
      _selectedExercises = aiExercises.map<Map<String, dynamic>>((aiEx) {
        // Debug print for aiEx.type
        debugPrint('AI Exercise: ${aiEx.name}, type: ${aiEx.type}, type.name: ${aiEx.type.name}');
        final match = _allExercises.firstWhere(
          (entry) =>
              entry['name'].toString().toLowerCase().contains(aiEx.name.toLowerCase()),
          orElse: () => {},
        );
        if (match.isEmpty) {
          debugPrint('No match found for AI exercise: ${aiEx.name}');
          // Fallback: create a placeholder with basic info, so all fields are present
          return {
            'name': aiEx.name,
            'reps': 12,
            'sets': 3,
            'image': 'assets/images/placeholder.png',
            'type': aiEx.type.name,
            'area': aiEx.bodyArea ?? 'Full Body',
            'intensity': aiEx.intensity.name,
          };
        }
        int reps;
        int sets;
        switch (aiEx.intensity) {
          case Intensity.low:
            reps = 10;
            sets = 2;
            break;
          case Intensity.medium:
            reps = 15;
            sets = 3;
            break;
          case Intensity.high:
            reps = 20;
            sets = 4;
            break;
          default:
            reps = 12;
            sets = 3;
        }
        return {
          'name': aiEx.name,
          'reps': reps,
          'sets': sets,
          'image': match['image'] ?? 'assets/images/placeholder.png',
          'type': aiEx.type.name,
          'area': aiEx.bodyArea ?? 'Full Body',
          'intensity': aiEx.intensity.name,
        };
      }).where((e) => e.isNotEmpty).toList();

      _selectedExerciseIndices = _selectedExercises.map((e) {
        // Try to find the index in _allExercises by name
        return _allExercises.indexWhere((entry) =>
            entry['name'].toString().toLowerCase() ==
            e['name'].toString().toLowerCase());
      }).toList();

      // Fallback if AI didn't return valid 3 entries
      if (_selectedExercises.isEmpty) {
        final allIndices = List<int>.generate(_allExercises.length, (i) => i)..shuffle();
        _selectedExerciseIndices = allIndices.sublist(0, 3);
        _selectedExercises = _selectedExerciseIndices.map((i) => _allExercises[i]).toList();
      }
    } catch (e) {
      debugPrint('Exception in _generateSmartExercises: $e');
      final allIndices = List<int>.generate(_allExercises.length, (i) => i)..shuffle();
      _selectedExerciseIndices = allIndices.sublist(0, 3);
      _selectedExercises = _selectedExerciseIndices.map((i) => _allExercises[i]).toList();
    }
  }

  @override
  void initState() {
    super.initState();
    final prefsFuture = SharedPreferences.getInstance();
    prefsFuture.then((prefs) {
      String todayStr = DateFormat('dd-MM-yyyy').format(DateTime.now());
      String? lastShownDate = prefs.getString('exercisePopupDate');

      if (lastShownDate != todayStr) {
        List<String> imagePaths = _allExercises.map((e) => e['image'] as String).toSet().toList();
        int index = 0;
        Timer? animationTimer;
        bool dialogClosed = false;

        BuildContext? dialogContext;

Future.any([
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      dialogContext = ctx; // ✅ store dialog context
      return StatefulBuilder(
        builder: (context, setState) {
          animationTimer ??= Timer.periodic(
            const Duration(seconds: 1),
            (timer) {
              setState(() {
                index = (index + 1) % imagePaths.length;
              });
            },
          );
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Generating Exercises for Today'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(imagePaths[index], height: 150),
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
              ],
            ),
          );
        },
      );
    },
  ).then((_) {
    dialogClosed = true;
  }),
  Future.delayed(const Duration(seconds: 8), () {
    if (!dialogClosed &&
        dialogContext != null &&
        Navigator.of(dialogContext!).canPop()) {
      Navigator.of(dialogContext!).pop(); // ✅ closes dialog ONLY
    }
  }),
]).then((_) {
  animationTimer?.cancel();
});

        prefs.setString('exercisePopupDate', todayStr);
      }
    });
    _dataReady = false;
    _initializeDayValue().then((_) {
      setState(() {
        _dataReady = true;
      });
    });
    _initializeExerciseSetValue();
    Timer.periodic(const Duration(seconds: 5), (_) {
      setState(() {
        _gradientIndex = (_gradientIndex + 1) % _gradients.length;
      });
    });
    _pageController = PageController(
      initialPage: _selectedExercise > 0 ? _selectedExercise - 1 : 0,
      viewportFraction: 0.5,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializeDayValue() async {
    final prefs = await SharedPreferences.getInstance();
    String todayStr = DateFormat('dd-MM-yyyy').format(DateTime.now());
    String? savedDate = prefs.getString('lastDate');
    // Log loaded date and today
    print('Loaded savedDate = $savedDate; today = $todayStr');

    await _checkForAppUpdateOncePerDay(todayStr, prefs);

    if (savedDate == null || savedDate != todayStr) {
      // New day: update date and generate a fresh set
      await prefs.setString('lastDate', todayStr);
      print('Saved todayStr = $todayStr to prefs');
      await _generateSmartExercises();
      // Persist the selected exercises as a single JSON string
      await prefs.setString(
        'selectedExercisesData',
        json.encode(_selectedExercises),
      );
    } else {
      // Same day: load the stored set if available
      final storedString = prefs.getString('selectedExercisesData');
      bool validStored = false;
      if (storedString != null) {
        try {
          final decoded = json.decode(storedString);
          if (decoded is List && decoded.length == 3) {
            print('Loaded stored exercises from prefs');
            validStored = true;
            _selectedExercises = List<Map<String, dynamic>>.from(decoded);
            _selectedExerciseIndices = _selectedExercises.map((e) {
              return _allExercises.indexWhere((entry) =>
                  entry['name'].toString().toLowerCase() ==
                  e['name'].toString().toLowerCase());
            }).toList();
          }
        } catch (e) {
          print('Error decoding stored exercises: $e');
        }
      }
      if (!validStored) {
        // Fallback if missing or invalid
        await _generateSmartExercises();
        await prefs.setString(
          'selectedExercisesData',
          json.encode(_selectedExercises),
        );
      }
    }
    // Increment day counter
    int savedDay = prefs.getInt('currentDay') ?? 0;
    savedDay++;
    await prefs.setInt('currentDay', savedDay);
    setState(() {
      currentDay = savedDay;
    });
  }

  Future<void> _initializeExerciseSetValue() async {
    final prefs = await SharedPreferences.getInstance();
    int? savedSet = prefs.getInt('selectedExerciseSet');
    if (savedSet != null &&
        savedSet >= 1 &&
        savedSet <= _allExercises.length) {
      selectedExerciseSet = savedSet;
    } else {
      selectedExerciseSet = 1;
      await prefs.setInt('selectedExerciseSet', selectedExerciseSet);
    }
    setState(() {});
  }

  Widget _buildExerciseContainer(
      String exerciseName, int reps, int sets, String imagePath, int index) {
    final Color baseColor = _exerciseBgColors[(index - 1) % _exerciseBgColors.length];
    final Color backgroundColor = baseColor;
    final Color borderColor = Colors.blueAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      //height: 675,
      //width: 300,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: Duration(milliseconds: 600),
        child: AnimatedSlide(
          duration: Duration(milliseconds: 600),
          offset: Offset(0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                exerciseName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return SizedBox(
                      height: 100,
                      child: Center(
                        child: Text(
                          'Image not found',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Reps: $reps   Sets: $sets',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              // --- Begin new info widgets ---
              const SizedBox(height: 8),
              Text(
                'Type: ${_selectedExercises[index - 1]['type'] ?? "Unknown"}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(
                'Area: ${_selectedExercises[index - 1]['area'] ?? "Full Body"}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Intensity: ', style: TextStyle(color: Colors.white, fontSize: 16)),
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (_selectedExercises[index - 1]['intensity'] == 'low')
                          ? Colors.green
                          : (_selectedExercises[index - 1]['intensity'] == 'medium')
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                  Text(
                    _selectedExercises[index - 1]['intensity']
                            ?.toString()
                            .replaceFirstMapped(RegExp(r'^\w'), (m) => m[0]!.toUpperCase()) ??
                        "Medium",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              // --- End new info widgets ---
            ],
          ),
        ),
      ),
    );
  }


  // --- Begin moved methods ---
  Future<void> _checkForAppUpdateOncePerDay(String todayStr, SharedPreferences prefs) async {
    final lastCheckedDate = prefs.getString('lastUpdateCheckDate');
    if (lastCheckedDate == todayStr) return; // Already checked today

    // Simulate update check logic
    bool isUpdateAvailable = await _isUpdateAvailable();
    if (isUpdateAvailable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Close any existing dialog such as exercise generation popup
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        showDialog(
          context: context,
          barrierDismissible: false, // prevent dismissing the dialog
          builder: (_) => AlertDialog(
            title: Text('Update Available'),
            content: Text('A new version of Atomfit is available. For the best experience, please update.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Allow user to continue
                },
                child: Text('Later'),
              ),
              TextButton(
                onPressed: () async {
                  const url = 'https://apps.apple.com/us/app/atomfit/id6747727915';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  }
                },
                child: Text('Update Now'),
              ),
            ],
          ),
        );
      });
    }

    await prefs.setString('lastUpdateCheckDate', todayStr);
  }

  Future<bool> _isUpdateAvailable() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version;

      // Replace with your real App Store ID
      final appStoreId = '6747727915';
      final url = 'https://itunes.apple.com/lookup?id=$appStoreId';

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'];
        if (results != null && results.length > 0) {
          final latestVersion = results[0]['version'];
          // Compare version numbers properly
          List<int> parseVersion(String version) =>
              version.split('.').map((e) => int.tryParse(e) ?? 0).toList();

          final local = parseVersion(currentVersion);
          final store = parseVersion(latestVersion);

          for (int i = 0; i < max(local.length, store.length); i++) {
            final lv = (i < local.length) ? local[i] : 0;
            final sv = (i < store.length) ? store[i] : 0;
            if (sv > lv) return true;
            if (sv < lv) return false;
          }

          return false;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  // --- End moved methods ---

  @override
  Widget build(BuildContext context) {
    if (!_dataReady) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final currentExercises = _selectedExercises;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
     /* bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Daily',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Me',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _currentTabIndex,
        selectedItemColor: Color(0xFFFF6C00),
        unselectedItemColor: Colors.white,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
          // handle navigation
          if (index == 0) {
            /*Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AttractiveWorkoutPage()),
            );*/
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkoutCalendarPage()),
            );
          } else if (index == 2) {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkoutPage()),
            );
          }
        },
      ),*/
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  height: 50,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Exercises Generated for Today',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: const Text(
                    'Perform each exercise for 2 sets of 10 repetitions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 700, // half of previous card height (350 / 2)
              child: PageView.builder(
                scrollDirection: Axis.vertical,
                controller: _pageController,
                itemCount: currentExercises.length,
                onPageChanged: (page) {
                  setState(() {
                    _selectedExercise = page + 1;
                  });
                },
                itemBuilder: (context, idx) {
                  debugPrint('PageView index $idx → master-list index ${_selectedExerciseIndices[idx]}');
                  final ex = currentExercises[idx];
                  final bool isInFocus = (_pageController.hasClients
                          ? (_pageController.page ?? _pageController.initialPage)
                          : _pageController.initialPage)
                      .round() == idx;
                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.95, end: isInFocus ? 1 : 0.9),
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedExercise = idx + 1;
                          });

                          final selectedEx = _selectedExercises[idx];
                          final String normalizedArea = normalizeArea(selectedEx['area'] ?? '');
                          final String frontImage = 'assets/images/muscle_front_$normalizedArea.png';
                          final String backImage = 'assets/images/muscle_back_$normalizedArea.png';

                          showDialog(
  context: context,
  barrierDismissible: false,
  builder: (dialogCtx) => AlertDialog(
    title: const Text('Muscles Targeted'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('This exercise targets your ${selectedEx['area']}.'),
        const SizedBox(height: 10),
        Image.asset(frontImage, height: 100),
        Image.asset(backImage, height: 100),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(dialogCtx).pop(); // ✅ ONLY closes dialog

          Future.delayed(const Duration(milliseconds: 200), () {
            final exerciseName =
                _selectedExercises[idx]['name'].toString().toLowerCase();

            final exerciseNumber =
                _allExercises.indexWhere((e) =>
                        e['name'].toString().toLowerCase() == exerciseName) +
                    1;

            SharedPreferences.getInstance().then(
              (prefs) => prefs.setInt(
                'selectedExerciseSet',
                selectedExerciseSet,
              ),
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    SimpleScreen(exerciseNumber: exerciseNumber),
              ),
            );
          });
        },
        child: const Text('OK'),
      ),
    ],
  ),
);
                        },
                        child: SizedBox(
                          width: 125,
                          height: 175,
                          child: _buildExerciseContainer(
                            ex['name'],
                            ex['reps'],
                            ex['sets'],
                            ex['image'],
                            idx + 1,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}


  // Area normalization for muscle images
  String normalizeArea(String area) {
    area = area.toLowerCase();
    if (area.contains('abs') || area.contains('core') || area.contains('obliques') || area.contains('back')) {
      return 'core';
    } else if (area.contains('glutes') || area.contains('legs') || area.contains('lower')) {
      return 'lower_body';
    } else if (area.contains('upper') || area.contains('arms') || area.contains('shoulder')) {
      return 'upper_body';
    } else if (area.contains('back')) {
      return 'back';
    } else {
      return 'full_body'; // default fallback
    }
  }
