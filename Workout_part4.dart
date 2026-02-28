import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_auth/firebase_auth.dart';
//import 'Workout_main.dart';
//import 'Workout.dart';
import 'Workout_part2.dart';
import 'Workout_part3.dart';
import 'Leader_board.dart';
import 'tutorial_page_setting.dart';
import 'login_page.dart';
import 'dart:ui';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  StreamSubscription<User?>? _authSub;
  String name = 'Buddy';
  String? imagePath;

  @override
  void initState() {
    super.initState();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) async {
      await _loadPreferences();
    });
    _loadPreferences();
  }
  Future<void> _signIn() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed in')),
      );
      await _loadPreferences();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: $e')),
      );
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed out')),
      );
      setState(() {
        name = 'Buddy';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign out failed: $e')),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This will permanently delete your account. This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await user.delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted')),
      );
      setState(() {
        name = 'Buddy';
      });
    } on FirebaseAuthException catch (e) {
      String msg = e.code;
      if (e.code == 'requires-recent-login') {
        msg = 'Please sign in again and try deleting your account.';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $msg')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }


  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // 1) Load saved name
    final savedName = prefs.getString('userName') ?? 'Buddy';

    // 2) Validate stored image path
    final storedPath = prefs.getString('userImage') ?? '';
    String? validImagePath;
    if (storedPath.isNotEmpty) {
      final file = File(storedPath);
      if (await file.exists()) {
        validImagePath = storedPath;
      }
    }

    String displayName = savedName;
    // 3) If signed in, try to fetch Firestore name
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null) {
            if (data['name'] != null && (data['name'] as String).trim().isNotEmpty) {
              displayName = data['name'];
            } else if (data['displayName'] != null && (data['displayName'] as String).trim().isNotEmpty) {
              displayName = data['displayName'];
            }
          }
        }
      } catch (e) {
        // Ignore Firestore errors, fallback to savedName
      }
    }

    // 4) Update state once
    setState(() {
      name = displayName;
      imagePath = validImagePath;
    });
  }

  Future<void> _saveName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', newName);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {
            'displayName': newName,
            'name': newName,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
    } catch (e) {
      // Non-fatal: keep local value; can retry later
      debugPrint('Failed to update name in Firestore: $e');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(pickedImage.path);
      final localImage = await File(pickedImage.path).copy('${appDir.path}/$fileName');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userImage', localImage.path);
      setState(() {
        imagePath = localImage.path;
      });
    }
  }

  ImageProvider<Object> get _avatarImage {
    if (imagePath != null && imagePath!.isNotEmpty) {
      final file = File(imagePath!);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    return const AssetImage('assets/images/default_profile.png');
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6C00),
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text('Atomfit', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.black, size: 40),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WorkoutCalendarPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.transparent,
                backgroundImage: _avatarImage,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black, fontSize: 20),
              controller: TextEditingController(text: 'Hi $name'),
              onChanged: (value) {
                if (value.startsWith('Hi ')) {
                  final newName = value.substring(3);
                  _saveName(newName);
                  setState(() {
                    name = newName;
                  });
                }
              },
              decoration: const InputDecoration(border: InputBorder.none),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.black),
              title: const Text('Language', style: TextStyle(color: Colors.black)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.school, color: Colors.black),
              title: const Text('View Tutorial', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TutorialPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip, color: Colors.black),
              title: const Text('Privacy Policy', style: TextStyle(color: Colors.black)),
              onTap: () => launchUrl(Uri.parse('https://atomicity.in/privacy-policy')),
            ),
            ListTile(
              leading: const Icon(Icons.apps, color: Colors.black),
              title: const Text('More Apps from Atomicity', style: TextStyle(color: Colors.black)),
              onTap: () => launchUrl(Uri.parse('https://atomicity.in/download')),
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.black),
              title: const Text('Share', style: TextStyle(color: Colors.black)),
              onTap: () {
                Share.share(
                  'Hey! Check out this AI and AR powered Fitness app "Atomfit" from Atomicity. https://apps.apple.com/in/app/atomfit/id6747727915',
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.black),
              title: const Text('Rate us', style: TextStyle(color: Colors.black)),
              onTap: () => launchUrl(Uri.parse('https://apps.apple.com/in/app/atomfit/id6747727915')),
            ),
            ...(() {
              final isSignedIn = FirebaseAuth.instance.currentUser != null;
              if (isSignedIn) {
                return [
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.black),
                    title: const Text('Sign out', style: TextStyle(color: Colors.black)),
                    onTap: _signOut,
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text('Delete account', style: TextStyle(color: Colors.red)),
                    onTap: _deleteAccount,
                  ),
                ];
              } else {
                return [
                  ListTile(
                    leading: const Icon(Icons.login, color: Colors.black),
                    title: const Text('Sign in', style: TextStyle(color: Colors.black)),
                    // onTap: _signIn,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SignUpScreen()),
                      );
                    },
                  ),
                ];
              }
            })(),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Follow us:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Image.asset('assets/icons/instagram.jpg', width: 32, height: 32),
                  onPressed: () => _launchUrl('https://www.instagram.com/atomicity_solution/'),
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: Image.asset('assets/icons/x.jpg', width: 32, height: 32),
                  onPressed: () => _launchUrl('https://x.com/Atomicity_IND'),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Color(0xFFFF6C00), width: 2),
                borderRadius: BorderRadius.circular(35),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 1. Workout page icon
                  IconButton(
                    icon: Icon(Icons.fitness_center, size: 56, color: Colors.white),
                    onPressed: () {
                    },
                  ),
                  // 2. Calories page icon
                  IconButton(
                    icon: Icon(Icons.local_fire_department, size: 56, color: Colors.white),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const CaloriesPage()),
                      );
                    },
                  ),
                  // 3. Leaderboard icon (bigger and elevated)
                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: IconButton(
                      icon: const Icon(Icons.emoji_events, size: 72, color: Colors.white),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LeaderboardPage()),
                        );
                      },
                    ),
                  ),
                  // 4. Profile page icon
                  IconButton(
                    icon: Icon(Icons.person, size: 56, color: Color(0xFFFF6C00)),
                    onPressed: () {
                     /* Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );*/
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
