import 'package:flutter/material.dart';
//import 'progress_tracker_screen.dart';
import 'Workout_part4.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({Key? key}) : super(key: key);

  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_TutorialStep> _steps = [
    _TutorialStep(
      imageAsset: 'assets/instruction0.jpg',
      description: '1. Whenever user selects any excercise he will get two options. 1. Teach me 2. Track me',
    ),
    _TutorialStep(
      imageAsset: 'assets/instruction1.png',
      description: '2. Once you select “Teach me,” your back camera will turn on, and a digital trainer will appear in your real world and perform workouts.',
    ),
    _TutorialStep(
      imageAsset: 'assets/instruction2.png',
      description: '3.Once you select “Track me,” your front camera will turn on. Place your phone so that your full body is clearly visible. When the AI begins tracking you, start performing the exercise.',
    ),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atomfit Tutorial'),
        centerTitle: true,
        backgroundColor: const Color(0xFFFF6C00),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _steps.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final step = _steps[index];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Image.asset(
                          step.imageAsset,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        step.description,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6C00)),
                    onPressed: () => _goToPage(_currentPage - 1),
                    child: const Text('Back'),
                  )
                else
                  const SizedBox(width: 80),
                Row(
                  children: List.generate(
                    _steps.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      width: _currentPage == index ? 12 : 8,
                      height: _currentPage == index ? 12 : 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index ? Theme.of(context).primaryColor : Colors.grey,
                      ),
                    ),
                  ),
                ),
                if (_currentPage < _steps.length - 1)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6C00)),
                    onPressed: () => _goToPage(_currentPage + 1),
                    child: const Text('Next'),
                  )
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6C00)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                    },
                    child: const Text('Done'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorialStep {
  final String imageAsset;
  final String description;

  _TutorialStep({required this.imageAsset, required this.description});
}
