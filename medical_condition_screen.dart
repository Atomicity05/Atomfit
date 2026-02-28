import 'package:flutter/material.dart';
import 'auto_track_meal_screen.dart';

class MedicalConditionScreen extends StatefulWidget {
  const MedicalConditionScreen({super.key});

  @override
  State<MedicalConditionScreen> createState() =>
      _MedicalConditionScreenState();
}

class _MedicalConditionScreenState extends State<MedicalConditionScreen> {
  final Set<String> selectedConditions = {};

  final List<String> conditions = [
    "None",
    "Diabetes",
    "Pre-Diabetes",
    "Cholesterol",
    "Hypertension",
    "PCOS",
    "Thyroid",
    "Physical Injury",
    "Excessive stress/anxiety",
    "Sleep issues",
    "Depression",
    "Anger issues",
    "Loneliness",
    "Relationship stress",
  ];

  bool get isValid => selectedConditions.isNotEmpty;

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
                value: 1.0,
                minHeight: 6,
                backgroundColor: Colors.grey.shade300,
                valueColor:
                    const AlwaysStoppedAnimation(Color(0xFF1E7F5C)),
              ),
            ),
            const SizedBox(height: 40),

            const Text(
              "Any Medical Condition we should be aware of?",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              "This info will help us guide you to your fitness goals safely and quickly.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            Expanded(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: conditions.map((condition) {
                  final selected =
                      selectedConditions.contains(condition);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (condition == "None") {
                          selectedConditions.clear();
                          selectedConditions.add("None");
                        } else {
                          selectedConditions.remove("None");
                          selected
                              ? selectedConditions.remove(condition)
                              : selectedConditions.add(condition);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF1E7F5C)
                              : Colors.grey.shade400,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
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
                          const SizedBox(width: 10),
                          Text(
                            condition,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isValid
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AutoTrackMealsScreen(),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isValid
                      ? const Color(0xFF1E7F5C)
                      : Colors.grey.shade300,
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
