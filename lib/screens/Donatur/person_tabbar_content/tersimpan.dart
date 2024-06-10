import 'package:flutter/material.dart';
import 'package:anti/pustaka.dart';

class Tersimpan extends StatefulWidget {
  const Tersimpan({super.key});

  @override
  State<Tersimpan> createState() => _TersimpanState();
}

class _TersimpanState extends State<Tersimpan> {
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
