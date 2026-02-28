import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Disable recaptcha verification
  FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: false);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🔥 AUTO-LOGIN CHECK HERE
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // USER STILL LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // USER LOGGED IN → GO TO MENU
          if (snapshot.hasData) {
            return const MenuScreen();
          }

          // USER NOT LOGGED IN → SHOW LOGIN SCREEN
          return const SignUpScreen();
        },
      ),
    );
  }
}
