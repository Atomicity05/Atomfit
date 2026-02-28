import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart';

class HealthifySetupScreen extends StatefulWidget {
  const HealthifySetupScreen({super.key});

  @override
  State<HealthifySetupScreen> createState() => _HealthifySetupScreenState();
}

class _HealthifySetupScreenState extends State<HealthifySetupScreen>
    with TickerProviderStateMixin {
  bool showStep1 = false;
  bool showStep2 = false;

  late AnimationController _dotController;

@override
void initState() {
  super.initState();

  _dotController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  Future.delayed(const Duration(milliseconds: 800), () {
    setState(() => showStep1 = true);
  });

  Future.delayed(const Duration(milliseconds: 1600), () {
    setState(() => showStep2 = true);
  });

  // ⭐ AFTER ANIMATION IS DONE → GO TO HOME SCREEN
  Future.delayed(const Duration(milliseconds: 2500), () {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HealthifyApp()),
      );
    }
  });
}

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
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
              const SizedBox(height: 60),

              const Text(
                "Setting-up Atomfit\nfor You",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              _AnimatedDots(controller: _dotController),

              const SizedBox(height: 48),

              AnimatedOpacity(
                opacity: showStep1 ? 1 : 0,
                duration: const Duration(milliseconds: 400),
                child: const ListTile(
                  leading: Icon(Icons.check_circle,
                      color: Color(0xFF1E7F5C)),
                  title: Text(
                    "Weight Loss",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              AnimatedOpacity(
                opacity: showStep2 ? 1 : 0,
                duration: const Duration(milliseconds: 400),
                child: const ListTile(
                  leading: Icon(Icons.monitor_weight,
                      color: Color(0xFF1E7F5C)),
                  title: Text(
                    "Setting Goal: Lose 24.1 kg",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedDots extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        int active = (controller.value * 3).floor();

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: index <= active
                    ? const Color(0xFF1E7F5C)
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
