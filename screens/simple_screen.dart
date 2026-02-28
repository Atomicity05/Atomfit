import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:video_player/video_player.dart';
import '../global_calories_manager.dart';
import '../home_screen.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoAsset;
  const VideoPlayerWidget({Key? key, required this.videoAsset}) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoAsset)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
    bool hasCompleted = false;
    _controller.addListener(() {
      if (_controller.value.isInitialized &&
          !_controller.value.isPlaying &&
          _controller.value.position >= _controller.value.duration &&
          !hasCompleted) {
        hasCompleted = true;
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? VideoPlayer(_controller)
        : const Center(child: CircularProgressIndicator());
  }
}

enum UIScreen { options, next }

class SimpleScreen extends StatefulWidget {
  final int exerciseNumber;
  const SimpleScreen({
    Key? key,
    required this.exerciseNumber,
  }) : super(key: key);

  @override
  State<SimpleScreen> createState() => _SimpleScreenState();
}

class _SimpleScreenState extends State<SimpleScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AudioPlayer _player = AudioPlayer();

  // ─── Loading overlay ────────────────────────────────────────
  bool _showLoading = true;
  late final AnimationController _loadingController;

  // ─── Block UI after continue flag ───────────────────────────
  bool _blockUIAfterContinue = false;

  // ─── Unity ready flag ───────────────────────────────────────
  bool _isUnityReady = false;

  // ─── Existing state ────────────────────────────────────────
  UIScreen _currentScreen = UIScreen.options;
  int _selectedOption = 1;
  UnityWidgetController? _unityWidgetController;
  int _caloriesFromUnity = 0;

  // ─── Option history flags ──────────────────────────────────
  bool _teachPressedEver = false;
  bool _trackPressedEver = false;
  bool _trackSessionStarted = false;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    debugPrint("▶️ SimpleScreen initState - audio player initialized");
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showLoading = false;
      });
      _loadingController.stop();
    });
    _loadOptionHistory();
  }

  Future<void> _loadOptionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    _teachPressedEver = prefs.getBool('pressed_teach_me') ?? false;
    _trackPressedEver = prefs.getBool('pressed_track_me') ?? false;
    _trackSessionStarted = prefs.getBool('track_session_started') ?? false;

    // Force selection based on history
    if (!_teachPressedEver && !_trackPressedEver) {
      // First ever visit: force Teach Me
      _selectedOption = 1;
    } else if (_teachPressedEver && !_trackPressedEver) {
      // Has used Teach Me, never used Track Me: force Track Me
      _selectedOption = 0;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _player.stop();
    debugPrint("🔇 Audio stopped on dispose");
    _player.dispose();
    _loadingController.dispose();
    _unityWidgetController?.dispose();
    super.dispose();
  }

  void onUnityCreated(UnityWidgetController controller) {
    _unityWidgetController = controller;
    _isUnityReady = true;
    setState(() => _showLoading = false);
  }

  void sendMessageToUnity() {
    if (!_isUnityReady || _unityWidgetController == null) return;
    int valueToSend;
    if (_selectedOption == -1) {
      valueToSend = -1;
    } else if (_selectedOption == 1) {
      valueToSend = widget.exerciseNumber;
      if (valueToSend == 6) valueToSend = 23;
    } else {
      valueToSend = widget.exerciseNumber + 100;
      if (valueToSend == 106) valueToSend = 123;
    }
    debugPrint("📤 Sending to Unity: $valueToSend");
    _unityWidgetController?.postMessage(
      'UnityMessageManager',
      'onMessage',
      valueToSend.toString(),
    );
  }

  void onUnityMessage(dynamic rawMessage) {
    final rawString = rawMessage.toString();
    final jsonStart = rawString.indexOf('{');
    if (jsonStart < 0) return;
    final payload = rawString.substring(jsonStart);
    Map<String, dynamic> msg;
    try {
      msg = jsonDecode(payload) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Failed to decode Unity message: $e');
      return;
    }
    if (msg['name'] == 'calories') {
      final dynamic data = msg['data'];
      final int? calories =
          data is int ? data : int.tryParse(data.toString());
      if (calories != null) {
        setState(() => _caloriesFromUnity = calories);
        GlobalCaloriesManager.instance.addCalories(calories);
      }
    }
  }

  Future<void> checkAndPlayIntroVideo() async {
    final prefs = await SharedPreferences.getInstance();

    // Mark that this option has been pressed at least once
    if (_selectedOption == 1) {
      await prefs.setBool('pressed_teach_me', true);
      _teachPressedEver = true;
    } else if (_selectedOption == 0) {
      await prefs.setBool('pressed_track_me', true);
      _trackPressedEver = true;
    }
    if (_selectedOption == 0) {
      _trackSessionStarted = true;
      await prefs.setBool('track_session_started', true);
    }

    final hasSeenIntro = prefs.getBool('hasSeenIntroVideo_$_selectedOption') ?? false;

    if (!hasSeenIntro) {
      String videoAsset = _selectedOption == 0
          ? 'assets/videos/track_me.mp4'
          : 'assets/videos/teach_me.mp4';

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                Center(child: VideoPlayerWidget(videoAsset: videoAsset)),
              ],
            ),
          ),
        ),
      );

      await prefs.setBool('hasSeenIntroVideo_$_selectedOption', true);
    }

    sendMessageToUnity();
    setState(() {
      _currentScreen = UIScreen.next;
      _blockUIAfterContinue = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _blockUIAfterContinue = false);
      }
    });
  }

  Widget _buildOptionsOverlay() {
    if (_selectedOption == -1) {
      _selectedOption = 1;
    }
    // Determine disabled options and title based on history
    final bool disableTrack = !_teachPressedEver && !_trackPressedEver; // first visit: disable Track Me
    final bool disableTeach = _teachPressedEver && !_trackPressedEver;  // Teach used, Track never: disable Teach Me
    final String appBarTitle = (!_teachPressedEver && !_trackPressedEver) ? 'Tutorial' : 'AtomFlex';
    final bool showDoneButton = _trackSessionStarted;
    // _blockUIAfterContinue = true; // (REMOVE THIS LINE)
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00A884),
        elevation: 0,
        title: Text(appBarTitle, style: const TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              "Choose an Option",
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: disableTeach ? null : () => setState(() => _selectedOption = 1),
                    child: IgnorePointer(
                      ignoring: disableTeach,
                      child: Opacity(
                        opacity: disableTeach ? 0.4 : 1.0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedOption == 1 ? Colors.blue : Colors.grey,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'AR',
                                style: GoogleFonts.poppins(
                                  fontSize: 60,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  shadows: const [
                                    Shadow(offset: Offset(3, 3), blurRadius: 3, color: Colors.black54),
                                    Shadow(offset: Offset(-3, -3), blurRadius: 3, color: Colors.white70),
                                  ],
                                ),
                              ),
                              Image.asset(
                                'assets/Teach_me.png',
                                height: 300,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Teach Me",
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  color: _selectedOption == 1 ? Colors.blue : Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: disableTrack ? null : () => setState(() => _selectedOption = 0),
                    child: IgnorePointer(
                      ignoring: disableTrack,
                      child: Opacity(
                        opacity: disableTrack ? 0.4 : 1.0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedOption == 0 ? Colors.blue : Colors.grey,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'AI',
                                style: GoogleFonts.poppins(
                                  fontSize: 60,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  shadows: const [
                                    Shadow(offset: Offset(3, 3), blurRadius: 3, color: Colors.black54),
                                    Shadow(offset: Offset(-3, -3), blurRadius: 3, color: Colors.white70),
                                  ],
                                ),
                              ),
                              Image.asset(
                                'assets/Track_me.png',
                                height: 300,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Track Me",
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  color: _selectedOption == 0 ? Colors.blue : Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: const Color(0xFF00A884),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _selectedOption != -1
                  ? () async {
                      checkAndPlayIntroVideo();
                    }
                  : null,
              child: Text(
                "Continue",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            if (showDoneButton)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HealthifyApp()),
                  );
                },
                child: Text(
                  "Done",
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Offstage(
            offstage: _currentScreen == UIScreen.options,
            child: UnityWidget(
              onUnityCreated: onUnityCreated,
              onUnityMessage: onUnityMessage,
            ),
          ),
          if (_currentScreen == UIScreen.options)
            _buildOptionsOverlay()
          else
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _selectedOption = 0;
                      sendMessageToUnity();
                      setState(() {
                        _currentScreen = UIScreen.options;
                        _blockUIAfterContinue = true;
                      });
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) {
                          setState(() => _blockUIAfterContinue = false);
                        }
                      });
                    },
                    child: const Text('Done'),
                  ),
                ),
              ),
            ),

          // Loading overlay
          if (_showLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RotationTransition(
                      turns: _loadingController,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color(0xFF6E8AFF),
                              Color(0xFF8AB2FF),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedTextKit(
                      animatedTexts: [
                        FadeAnimatedText(
                          'Loading...',
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          duration: const Duration(milliseconds: 1200),
                        ),
                      ],
                      isRepeatingAnimation: true,
                    ),
                  ],
                ),
              ),
            ),
          // Block UI after continue overlay
          if (_blockUIAfterContinue)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RotationTransition(
                      turns: _loadingController,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [Color(0xFF6E8AFF), Color(0xFF8AB2FF)],
                          ),
                        ),
                        child: const Icon(Icons.fitness_center, size: 40, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Preparing...',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
