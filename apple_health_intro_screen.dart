import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'atomfit_setup_screen.dart';

class AppleHealthIntroScreen extends StatelessWidget {
  const AppleHealthIntroScreen({super.key});

  Future<void> _requestAppleHealthPermission(BuildContext context) async {
    final health = Health();

    final types = [
      HealthDataType.STEPS,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.WEIGHT,
    ];

    final permissions = [
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
    ];

    try {
      await health.requestAuthorization(
        types,
        permissions: permissions,
      );
    } catch (_) {
      // Ignore any errors – continue onboarding
    }

    // Navigate irrespective of permission result
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HealthifySetupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              Align(
                alignment: Alignment.topLeft,
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  label: const Text(
                    "Atomfit",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/apple_health_walk.png",
                      height: 260,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 32),

                    GestureDetector(
                      onTap: () => _requestAppleHealthPermission(context),
                      child: const Text(
                        "Let’s Auto-Track with Apple Health!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Sync all your health data around activity and sleep. "
                      "More access = faster path to your fitness goal!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.person, color: Color(0xFF1E7F5C)),
                  SizedBox(width: 8),
                  Text(
                    "On the next screen, tap “All categories on”",
                    style: TextStyle(
                      color: Color(0xFF1E7F5C),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _requestAppleHealthPermission(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Sync with Apple Health",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HealthifySetupScreen(),
      ),
    );
  },
  child: const Text(
    "No, I’ll Track Everything Manually",
    style: TextStyle(
      fontSize: 15,
      color: Colors.black,
    ),
  ),
),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
