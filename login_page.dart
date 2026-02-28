import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'menu_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool loading = false;

  void goToMenu() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MenuScreen()),
    );
  }

  // -----------------------------------------------------------
  // GOOGLE SIGN-IN
  // -----------------------------------------------------------
  Future<void> loginWithGoogle() async {
    try {
      setState(() => loading = true);

      final googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        setState(() => loading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      setState(() => loading = false);
      goToMenu();
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Login Failed: $e")),
      );
    }
  }

  // -----------------------------------------------------------
  // APPLE SIGN-IN (iOS)
  // -----------------------------------------------------------
  Future<void> loginWithApple() async {
    try {
      setState(() => loading = true);

      final appleProvider = AppleAuthProvider();
      await FirebaseAuth.instance.signInWithProvider(appleProvider);

      setState(() => loading = false);
      goToMenu();
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Apple Login Failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER AREA
              Container(
                height: 220,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF2F6D5C),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/logo.png", height: 60),
                    const SizedBox(height: 12),
                    const Text(
                      "Atomfit",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // MAIN CARD
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Login to Your Account",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text("continue with"),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // APPLE LOGIN
                        GestureDetector(
                          onTap: loginWithApple,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.grey.shade300)),
                            child: Image.asset("assets/apple.png", height: 32),
                          ),
                        ),

                        // GOOGLE LOGIN
                        GestureDetector(
                          onTap: loginWithGoogle,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.grey.shade300)),
                            child: Image.asset("assets/google.png", height: 28),
                          ),
                        ),
                      ],
                    ),

                    if (loading)
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  "By signing in, I agree to the Terms of Service and Privacy Policy.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
