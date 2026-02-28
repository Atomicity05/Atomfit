import 'package:flutter/material.dart';
import 'auto_track_enable_system.dart';
import 'apple_health_intro_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class AutoTrackMealsScreen extends StatelessWidget {
  const AutoTrackMealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, size: 28),
                onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const AppleHealthIntroScreen(),
    ),
  );
},
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: const [
                  Text(
                    "Snap and Auto-Track Meals\nwith AI",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Just snap a pic from your phone. We will auto-track food photos. Like magic!",
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

            const SizedBox(height: 24),

            // Image / preview card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              height: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8787)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 30,
                    right: 30,
                    child: _foodImagePlaceholder(),
                  ),
                  Positioned(
                    top: 120,
                    left: 40,
                    child: _foodImagePlaceholder(),
                  ),
                  Positioned(
                    bottom: 40,
                    right: 60,
                    child: _foodImagePlaceholder(),
                  ),
                ],
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      children: [
                        TextSpan(text: "Your data is secure and private to you. "),
                        TextSpan(
                          text: "Know More",
                          style: TextStyle(
                            color: Color(0xFF1E7F5C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
  onPressed: () async {
    PermissionStatus status = await Permission.photos.request();

    if (status.isGranted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AutoTrackEnabledScreen(),
        ),
      );
    } else {
    // Permission denied → move to Apple Health flow
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AppleHealthIntroScreen(),
      ),
    );
  }
  },                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E7F5C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Enable Auto-Track from Gallery",
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
          ],
        ),
      ),
    );
  }

  static Widget _foodImagePlaceholder() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
