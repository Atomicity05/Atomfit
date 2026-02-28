import '../models/exercise.dart';
import 'local_storage_service.dart';
import 'dart:math';

class WorkoutPlanner {
  final LocalStorageService storage;

  WorkoutPlanner(this.storage);

  final List<Exercise> allExercises = [
    Exercise(name: "Chair Pushups", type: ExerciseType.strength, bodyArea: "Upper Body", intensity: Intensity.low),
    Exercise(name: "Back Stretch", type: ExerciseType.flexibility, bodyArea: "Back", intensity: Intensity.low),
    Exercise(name: "Bug", type: ExerciseType.core, bodyArea: "Core", intensity: Intensity.low),
    Exercise(name: "Chair Step-ups", type: ExerciseType.strength, bodyArea: "Legs", intensity: Intensity.low),
    Exercise(name: "Dead Bug", type: ExerciseType.core, bodyArea: "Core", intensity: Intensity.low),
    /*Exercise(name: "Plank", type: ExerciseType.core, bodyArea: "Full Body", intensity: Intensity.medium),*/
    Exercise(name: "Sklony (Side Bends)", type: ExerciseType.core, bodyArea: "Obliques", intensity: Intensity.low),
    Exercise(name: "Sklony Half", type: ExerciseType.core, bodyArea: "Obliques", intensity: Intensity.low),
    Exercise(name: "Bicycle", type: ExerciseType.cardio, bodyArea: "Full Body", intensity: Intensity.medium),
    Exercise(name: "Bicycle Crunch", type: ExerciseType.core, bodyArea: "Abs", intensity: Intensity.medium),
    Exercise(name: "Brzuszki (Sit-ups)", type: ExerciseType.core, bodyArea: "Abs", intensity: Intensity.medium),
    Exercise(name: "But Up", type: ExerciseType.core, bodyArea: "Glutes", intensity: Intensity.medium),
    Exercise(name: "Crunch", type: ExerciseType.core, bodyArea: "Abs", intensity: Intensity.low),
    Exercise(name: "Leg Raiser", type: ExerciseType.core, bodyArea: "Lower Abs", intensity: Intensity.medium),
    Exercise(name: "Leg Twist Touch", type: ExerciseType.core, bodyArea: "Obliques", intensity: Intensity.medium),
    //Exercise(name: "Mostek (Bridge)", type: ExerciseType.core, bodyArea: "Glutes/Back", intensity: Intensity.low),
    Exercise(name: "Push-ups", type: ExerciseType.strength, bodyArea: "Upper Body", intensity: Intensity.medium),
    Exercise(name: "Scissors", type: ExerciseType.core, bodyArea: "Abs", intensity: Intensity.medium),
    Exercise(name: "Squats Weight", type: ExerciseType.strength, bodyArea: "Legs", intensity: Intensity.high),
    Exercise(name: "Twist Down", type: ExerciseType.core, bodyArea: "Obliques", intensity: Intensity.medium),
    Exercise(name: "Wypady Boki (Side Lunges)", type: ExerciseType.strength, bodyArea: "Legs", intensity: Intensity.medium),
    Exercise(name: "Wypady Front (Front Lunges)", type: ExerciseType.strength, bodyArea: "Legs", intensity: Intensity.medium),
    Exercise(name: "Jumping Jacks", type: ExerciseType.cardio, bodyArea: "Full Body", intensity: Intensity.low),
    Exercise(name: "Mountain Climbers", type: ExerciseType.cardio, bodyArea: "Full Body", intensity: Intensity.high),
    Exercise(name: "Przysiady (Deep Squats)", type: ExerciseType.strength, bodyArea: "Legs", intensity: Intensity.high),
    Exercise(name: "Pull-ups", type: ExerciseType.strength, bodyArea: "Upper Body", intensity: Intensity.high),
    Exercise(name: "Moderate Pace Run", type: ExerciseType.cardio, bodyArea: "Full Body", intensity: Intensity.medium),
    Exercise(name: "Stand-up Jump", type: ExerciseType.plyo, bodyArea: "Full Body", intensity: Intensity.medium),
    Exercise(name: "Swing Pull-up Weight", type: ExerciseType.strength, bodyArea: "Upper Body", intensity: Intensity.high),
    Exercise(name: "Swing Weight", type: ExerciseType.strength, bodyArea: "Full Body", intensity: Intensity.high),
  ];

  Map<String, List<Exercise>> getExercisesByArea() {
    Map<String, List<Exercise>> areaMap = {
      'Full Body': [],
      'Legs': [],
      'Core': [],
      'Abs': [],
    };

    for (var e in allExercises) {
      switch (e.bodyArea.toLowerCase()) {
        case 'full body':
          areaMap['Full Body']!.add(e);
          break;
        case 'legs':
          areaMap['Legs']!.add(e);
          break;
        case 'core':
        case 'lower abs':
        case 'obliques':
          areaMap['Core']!.add(e);
          break;
        case 'abs':
          areaMap['Abs']!.add(e);
          break;
        default:
          // Assign nearest logical area
          if (e.bodyArea.toLowerCase().contains('upper') || e.bodyArea.toLowerCase().contains('back')) {
            areaMap['Core']!.add(e);
          } else if (e.bodyArea.toLowerCase().contains('glutes')) {
            areaMap['Legs']!.add(e);
          } else {
            areaMap['Full Body']!.add(e);
          }
          break;
      }
    }

    return areaMap;
  }

  /// Returns a random list of two distinct exercises from the full list.
  List<Exercise> getTwoRandomExercises() {
    final randomList = List<Exercise>.from(allExercises);
    randomList.shuffle();
    return randomList.take(2).toList();
  }

  Future<List<Exercise>> generateTodayWorkout() async {
    // final bmi = await storage.getBmi() ?? 22.0;
    final recentExercises = await storage.getExerciseHistory();

    // Randomly choose goal from available types
    final goals = ['burn', 'gain', 'balance'];
    final random = Random();
    final goal = goals[random.nextInt(goals.length)];

    final filtered = allExercises.where((e) => !recentExercises.contains(e.name)).toList();

    List<Exercise> strength = filtered.where((e) => e.type == ExerciseType.strength).toList();
    List<Exercise> cardio = filtered.where((e) => e.type == ExerciseType.cardio).toList();
    List<Exercise> core = filtered.where((e) => e.type == ExerciseType.core).toList();
    List<Exercise> flexibility = filtered.where((e) => e.type == ExerciseType.flexibility).toList();

    List<Exercise> today = [];

    if (goal == 'burn') {
      today.addAll(_pickRandom(cardio, 2));
      today.addAll(_pickRandom(core, 1));
      today.addAll(_pickRandom(strength, 1));
    } else if (goal == 'gain') {
      today.addAll(_pickRandom(strength, 2));
      today.addAll(_pickRandom(core, 1));
      today.addAll(_pickRandom(flexibility, 1));
    } else {
      today.addAll(_pickRandom(strength, 1));
      today.addAll(_pickRandom(cardio, 1));
      today.addAll(_pickRandom(core, 1));
      today.addAll(_pickRandom(flexibility, 1));
    }

    final history = [...recentExercises, ...today.map((e) => e.name)];
    final latest = history.reversed.toList().take(12).toList();
    await storage.saveExerciseHistory(latest);

    return today;
  }

  List<Exercise> _pickRandom(List<Exercise> list, int count) {
    final random = Random();
    list.shuffle(random);
    return list.take(count).toList();
  }
  
    /// Generates a custom workout with up to [count] exercises for the given [area].
    List<Exercise> generateCustomWorkout({required String area, required int count}) {
    // Get exercises for the selected area
    final areaMap = getExercisesByArea();
    final selected = <Exercise>[];
    final available = List<Exercise>.from(areaMap[area] ?? []);
    // Shuffle to randomize selection
    available.shuffle();

    // Take as many as possible from the chosen area
    final takeFromArea = available.take(count).toList();
    selected.addAll(takeFromArea);

    // If we need more, pull from other exercises
    if (selected.length < count) {
      final remainingNeeded = count - selected.length;
      // Build pool of all exercises excluding already selected
      final pool = List<Exercise>.from(allExercises)
        ..removeWhere((e) => selected.contains(e));
      pool.shuffle();
      selected.addAll(pool.take(remainingNeeded));
    }
    return selected;
  }
}
