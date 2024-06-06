import 'package:flutter/material.dart';

class DonasiMasuk extends StatefulWidget {
  const DonasiMasuk({super.key});

  @override
  State<DonasiMasuk> createState() => _DonasiMasukState();
}

class _DonasiMasukState extends State<DonasiMasuk> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('donasi masuk'),
      ),
    );
  }
}
