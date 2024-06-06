import 'package:flutter/material.dart';
import 'package:anti/pustaka.dart';

class JualanSaya extends StatefulWidget {
  const JualanSaya({super.key});

  @override
  State<JualanSaya> createState() => _JualanSayaState();
}

class _JualanSayaState extends State<JualanSaya> {
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ElevatedButton(
        onPressed: () async {
          await _auth.signout();
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LoginScreen()));
        },
        child: const Text('keluar'),
      )),
    );
  }
}
