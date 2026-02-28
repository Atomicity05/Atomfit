import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:google_fonts/google_fonts.dart';

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

class _SimpleScreenState extends State<SimpleScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Controls which UI overlay to display
  UIScreen _currentScreen = UIScreen.options;
  int _selectedOption = 1; // Teach Me selected by default

  UnityWidgetController? _unityWidgetController;

  @override
  void dispose() {
    _unityWidgetController?.dispose();
    super.dispose();
  }

  /// Called when Unity is created; obtains the controller
  void onUnityCreated(UnityWidgetController controller) {
    _unityWidgetController = controller;
  }

  /// Sends a numeric message (as a string) to Unity
  void sendMessageToUnity() {
           int valueToSend;
           
             if(_selectedOption == -1)
             {
                      valueToSend = -1;
}
  else if(_selectedOption == 1)
  {
         valueToSend = widget.exerciseNumber;
   }else{
         valueToSend = widget.exerciseNumber + 100;
}
    
    _unityWidgetController?.postMessage(
      'UnityMessageManager',
      'onMessage',
      valueToSend.toString(),
    );
  }
  

  /// -------------------------
  /// 1) Overlay: Options Screen
  /// -------------------------
  Widget _buildOptionsOverlay() {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          elevation: 0,
          title: const Text(
            'Atomicity',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
        ),
      backgroundColor: Colors.transparent, // Transparent so Unity is behind it (offstage).
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
                // "Teach Me" on the left
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedOption = 1;
                      });
                    },
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
                          Image.asset(
                            'assets/Teach_me.png',
                            height: 400,
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
                const SizedBox(width: 16),
                // "Track Me" on the right
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedOption = 0;
                      });
                    },
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
                          Image.asset(
                            'assets/Track_me.png',
                            height: 400,
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
              ],
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: const Color(0xFF6E8AFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _selectedOption != -1
                  ? () {
                      // Optionally, communicate with Unity before continuing
                      if (_selectedOption == 0 || _selectedOption == 1) {
                        sendMessageToUnity();
                      }
                      setState(() {
                        _currentScreen = UIScreen.next;
                      });
                    }
                  : null,
              child: Text(
                "Continue",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// -------------------------
  /// 2) Overlay: Next Screen
  /// -------------------------
  Widget _buildNextOverlay() {
    return Scaffold(
      key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blueAccent,
          elevation: 0,
          title: const Text(
            'Atomicity',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
        ),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          // The Expanded widget here ensures the button is pinned to the bottom
          children: [
                   
            // This fills remaining space, letting Unity show through behind
            Expanded(
              child: Container(color: Colors.transparent),

            ),
            // Button pinned at bottom
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  
                  onPressed: () {
  sendMessageToUnity();
  setState(() {
    _currentScreen = UIScreen.options;
  });
},
                  child: const Text('Done'),
                  
                  
                  
                ),
              ),
            ),
            /*
            //const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: const Color(0xFF6E8AFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
                            //_selectedOption = -1;
              onPressed: _selectedOption == -1
                  ? () {
                      // Optionally, communicate with Unity before continuing
                      
                        sendMessageToUnity();
                      
                      setState(() {
                        _currentScreen = UIScreen.options;
                      });
                    }
                  : null,
              child: Text(
                "Continue",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
              ),
            ),*/
            
          ],
        ),
      ),
    );
  }

  /// -------------------------
  /// Main build method
  /// -------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Unity widget in the background (Offstage if on options screen)
          Offstage(
            offstage: _currentScreen == UIScreen.options,
            child: UnityWidget(onUnityCreated: onUnityCreated),
          ),

          // Overlay the UI on top of Unity
          _currentScreen == UIScreen.options
              ? _buildOptionsOverlay()
              : _buildNextOverlay(),
        ],
      ),
    );
  }
}
