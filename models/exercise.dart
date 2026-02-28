enum ExerciseType { cardio, strength, core, flexibility, plyo }
enum Intensity { low, medium, high }

class Exercise {
  final String name;
  final ExerciseType type;
  final String bodyArea;
  final Intensity intensity;

  Exercise({
    required this.name,
    required this.type,
    required this.bodyArea,
    required this.intensity,
  });
}
