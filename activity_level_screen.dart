import 'package:flutter/material.dart';
import 'age_selection_screen.dart';

class ActivityLevelScreen extends StatefulWidget {
  const ActivityLevelScreen({super.key});

  @override
  State<ActivityLevelScreen> createState() => _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends State<ActivityLevelScreen> {
  String? selectedLevel;

  final List<Map<String, dynamic>> activityLevels = [
    {
      "title": "Mostly Sitting",
      "subtitle": "Seated work, low movement.",
      "icon": Icons.chair_alt_outlined,
      "value": "sitting",
    },
    {
      "title": "Often Standing",
      "subtitle": "Standing work, occasional walking.",
      "icon": Icons.directions_walk_outlined,
      "value": "standing",
    },
    {
      "title": "Regularly Walking",
      "subtitle": "Frequent walking, steady activity.",
      "icon": Icons.directions_run_outlined,
      "value": "walking",
    },
    {
      "title": "Physically Intense Work",
      "subtitle": "Heavy labor, high exertion.",
      "icon": Icons.construction_outlined,
      "value": "intense",
    },
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
                value: 0.7,
                minHeight: 6,
                backgroundColor: Colors.grey.shade300,
                valueColor:
                    const AlwaysStoppedAnimation(Color(0xFF1E7F5C)),
              ),
            ),
            const SizedBox(height: 40),

            const Text(
              "How active are you?",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              "Based on your lifestyle, we can assess your daily calorie requirements.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            Expanded(
              child: ListView.separated(
                itemCount: activityLevels.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final level = activityLevels[index];
                  final selected = selectedLevel == level["value"];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedLevel = level["value"];
                      });
                    },
                    child: Container(
                      height: 76,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF1E7F5C)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Icon(level["icon"], color: Colors.black),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  level["title"],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  level["subtitle"],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 16),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
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
                onPressed: selectedLevel == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AgeSelectionScreen(),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedLevel == null
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
