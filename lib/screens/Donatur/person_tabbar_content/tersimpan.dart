import 'package:flutter/material.dart';

class Tersimpan extends StatefulWidget {
  const Tersimpan({super.key});

  @override
  State<Tersimpan> createState() => _TersimpanState();
}

class _TersimpanState extends State<Tersimpan> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('tersimpan')),
    );
  }
}
