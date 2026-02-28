import 'package:flutter/material.dart';
import 'Workout_part2.dart';
import 'Workout_part3.dart';
import 'Workout_part4.dart';
import 'Leader_board.dart';
import 'Workout.dart';

void main() {
  runApp(const HealthifyApp());
}

class HealthifyApp extends StatelessWidget {
  const HealthifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Healthify Clone',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto', // Default, similar to system font
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00A884)),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // Custom Colors extracted from screenshots
    final Color primaryGreen = const Color(0xFF009688);
    final Color lightGreenBg = const Color(0xFFE0F2F1);
    final Color darkText = const Color(0xFF1D1D1D);
    final Color greyText = const Color(0xFF757575);

    return Scaffold(
      backgroundColor: primaryGreen, // Base color for the top part
      body: Stack(
        children: [
          // 1. Background Gradient and Top Content
          Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF00897B),
                  const Color(0xFF009688),
                ],
              ),
            ),
          ),
          
          // 2. Main Scrollable Content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Green Section Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "ATOMFIT\nExperience AR and AI",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Create Groups and track \n your friends progress!",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 15),
InkWell(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LeaderboardPage()),
    );
  },
  borderRadius: BorderRadius.circular(20),
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFFFD54F),
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Text(
      "create>",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),
  ),
),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // White Scrollable Sheet
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row (Avatar, Trial, Date)
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFF004D40),
                                  child: const Text("W", style: TextStyle(color: Colors.white)),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.emoji_events_outlined, size: 16, color: primaryGreen),
                                      const SizedBox(width: 4),
                                      const Text(
                                        "Free Trial Expired",
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    children: [
                                      Text("Today", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      Icon(Icons.keyboard_arrow_down, size: 16),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            Text("Your Trackers", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
                            const SizedBox(height: 16),
                            
                            _buildWorkoutTrackerCard(),
const SizedBox(height: 16),
_buildFoodTrackerCard(),

                            const SizedBox(height: 16),
                            
                            // Weight Loss Plan Link
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2F1).withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.card_giftcard, color: primaryGreen, size: 20),
                                  const SizedBox(width: 10),
                                  /*const Text("Your Weight Loss Plan is Ready!", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),*/
                                  const Spacer(),
                                  const Icon(Icons.arrow_forward, size: 18, color: Colors.grey),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // LIST OF TRACKERS
                            _buildTrackerTile(
                              icon: Icons.monitor_weight_outlined,
                              title: "Weight",
                              subtitle: "0 kg lost",
                              isAdd: true
                            ),
                            _buildTrackerTile(
                              icon: Icons.local_fire_department_outlined,
                              title: "Workout",
                              subtitle: "Goal: 323 cal",
                              isAdd: true
                            ),
                            _buildTrackerTile(
                              icon: Icons.directions_walk,
                              title: "Steps",
                              subtitle: "Set Up Auto-Tracking",
                              isArrow: true
                            ),
                            _buildTrackerTile(
                              icon: Icons.bedtime_outlined,
                              title: "Sleep",
                              subtitle: "Set Up Sleep Goal",
                              isArrow: true
                            ),
                            _buildTrackerTile(
                              icon: Icons.local_drink_outlined,
                              title: "Water",
                              subtitle: "Goal: 9 glasses",
                              isAdd: true
                            ),

                            const SizedBox(height: 16),
                            
                          /*  // Track More Button
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F2F1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.add, color: primaryGreen),
                                ),
                                const SizedBox(width: 12),
                                Text("Track More", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),*/

                            const SizedBox(height: 30),
                            
                            // TODAY'S LOGS SECTION
                            Center(
                              child: Icon(Icons.keyboard_arrow_up, color: Colors.grey.shade400),
                            ),
                            const SizedBox(height: 10),
                            Text("Today's Logs", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
                            const SizedBox(height: 16),

                            // Empty State Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Simplified illustration using icons
                                  SizedBox(
                                    height: 100,
                                    width: 150,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Positioned(
                                          left: 0,
                                          child: _buildCardIcon(Icons.directions_run, Colors.purple.shade100, Colors.purple),
                                        ),
                                        Positioned(
                                          right: 0,
                                          child: _buildCardIcon(Icons.nightlight_round, Colors.blue.shade100, Colors.blue),
                                        ),
                                        Positioned(
                                          top: -10,
                                          child: _buildCardIcon(Icons.restaurant, const Color(0xFFFFE0B2), Colors.orange, size: 60),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text("Nothing Tracked Yet!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Log your meal, workout, water or sleep & get detailed feedback & suggestions",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: greyText, fontSize: 13),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF264653), // Dark teal button
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    ),
                                    child: const Text("Track Now"),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 80), // Bottom padding for FAB
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Floating Sparkle Button (Bottom Right)
          Positioned(
            bottom: 80,
            right: 20,
            child: Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF00C853),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                   BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
                ]
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white),
            ),
          )
        ],
      ),
      
      // Bottom Navigation Bar
      floatingActionButton: SizedBox(
        height: 65,
        width: 65,
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: const Color(0xFF004D40),
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        height: 70,
        color: Colors.white,
        surfaceTintColor: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_filled, "Home", true),
            _buildNavItem(Icons.center_focus_weak, "Click", false),
            const SizedBox(width: 40), // Space for FAB
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LeaderboardPage()),
    );
  },
  child: _buildNavItem(Icons.emoji_events_outlined, "Leaderboard", false),
),

GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WorkoutCalendarPage()),
    );
  },
  child: _buildNavItem(Icons.bolt, "Streaks", false),
),

          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildCardIcon(IconData icon, Color bg, Color iconColor, {double size = 50}) {
    return Container(
      height: size,
      width: size * 0.8,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Icon(icon, color: iconColor),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isSelected ? const Color(0xFF009688) : Colors.grey, size: 26),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF009688) : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

Widget _buildWorkoutTrackerCard() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border.all(color: Colors.grey.shade100),
    ),
    child: Column(
      children: [
        // Header Row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center,
                color: Color(0xFF2E7D32),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Workout",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "Personalized for today",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        // CTA Banner
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AttractiveWorkoutPage(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: Color(0xFF00695C),
                ),
                SizedBox(width: 12),
                Text(
                  "generate workouts for today",
                  style: TextStyle(
                    color: Color(0xFF00695C),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: Color(0xFF00695C),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildFoodTrackerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.restaurant_menu, color: Colors.orange, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Track Food", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Eat 1,600 Cal", style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.camera_alt_outlined, color: Colors.black87),
              const SizedBox(width: 16),
              const Icon(Icons.add_circle_outline, color: Colors.orange),
            ],
          ),
          const SizedBox(height: 16),
          // Intermittent Fasting Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.access_time, size: 16, color: Color(0xFF009688)),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Want to start\nIntermittent Fasting?",
                  style: TextStyle(
                    color: Color(0xFF00695C),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward, size: 18, color: Color(0xFF00695C)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Macros
          Row(
            children: [
              Expanded(child: _buildMacroProgress("Protein", 0)),
              const SizedBox(width: 16),
              Expanded(child: _buildMacroProgress("Fats", 0)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMacroProgress("Carbs", 0)),
              const SizedBox(width: 16),
              Expanded(child: _buildMacroProgress("Fibre", 0)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroProgress(String label, double percent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("$label: 0%", style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 4,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(2),
          ),
        )
      ],
    );
  }

  Widget _buildTrackerTile({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isAdd = false,
    bool isArrow = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Icon(icon, size: 20, color: Colors.black87),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const Spacer(),
          if (isAdd)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, size: 16, color: Colors.black54),
            ),
          if (isArrow)
            const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
