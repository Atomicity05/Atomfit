import 'package:flutter/material.dart';
import 'activity_level_screen.dart';

class GoalsSelectionScreen extends StatefulWidget {
  const GoalsSelectionScreen({super.key});

  @override
  State<GoalsSelectionScreen> createState() => _GoalsSelectionScreenState();
}

class _GoalsSelectionScreenState extends State<GoalsSelectionScreen> {
  final Set<String> selectedGoals = {};

  final List<Map<String, dynamic>> goals = [
    {"label": "SNAP", "icon": Icons.camera_alt_outlined},
    {"label": "Diet Plan", "icon": Icons.restaurant_menu},
    {"label": "Weight Loss", "icon": Icons.monitor_weight_outlined},
    {"label": "GLP-1", "icon": Icons.medication_outlined},
    {"label": "Intermittent Fasting", "icon": Icons.timer_outlined},
    {"label": "Calorie Tracker", "icon": Icons.local_fire_department_outlined},
    {"label": "Muscle Gain", "icon": Icons.fitness_center},
    {"label": "Workouts and Yoga", "icon": Icons.directions_run},
    {"label": "Healthy Foods", "icon": Icons.shopping_bag_outlined},
    {"label": "CGM (Pro)", "icon": Icons.circle_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: 0.5,
                minHeight: 6,
                backgroundColor: Colors.grey.shade300,
                valueColor:
                    const AlwaysStoppedAnimation(Color(0xFF1E7F5C)),
              ),
            ),
            const SizedBox(height: 40),

            const Text(
              "What are you looking for?",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              "Selecting one or more options would help us tailor your experience.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            Expanded(
              child: ListView.separated(
                itemCount: goals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  final selected = selectedGoals.contains(goal["label"]);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selected
                            ? selectedGoals.remove(goal["label"])
                            : selectedGoals.add(goal["label"]);
                      });
                    },
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Icon(goal["icon"], color: Colors.black),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              goal["label"],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 16),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFF1E7F5C)
                                    : Colors.grey,
                                width: 2,
                              ),
                              color: selected
                                  ? const Color(0xFF1E7F5C)
                                  : Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: selectedGoals.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ActivityLevelScreen(),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedGoals.isEmpty
                      ? Colors.grey.shade300
                      : const Color(0xFF1E7F5C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
