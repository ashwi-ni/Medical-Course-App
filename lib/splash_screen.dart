import 'package:flutter/material.dart';
import 'OnboardingScreen.dart';
//import 'OnboardingScreen.dart';
class SplashScreen extends StatefulWidget {
  final void Function(Locale locale)? onLocaleChange; // ✅ Added this

  const SplashScreen({super.key, this.onLocaleChange});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the Onboarding screen after a delay
    _navigateToOnboarding();
  }

  // Function to navigate to the Onboarding Screen after 2 seconds
  _navigateToOnboarding() {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  OnboardingScreen(
          onLocaleChange: widget.onLocaleChange,
        )),
      );
    }
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Splash screen background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logos.png', height:300,width:500), // Your logo image

          ],
        ),
      ),
    );
  }
}
