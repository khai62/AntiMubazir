import 'package:flutter/material.dart';
import 'package:anti/pustaka.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: Image.asset(
              'assets/images/logo.png',
              width: 250,
              height: 250,
            )),
            const SizedBox(
              height: 5,
            ),
            const CircularProgressIndicator(
              color: Color(0xFF96B12D),
            )
          ],
        ),
      ),
    );
  }

  
}
