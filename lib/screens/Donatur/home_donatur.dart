import 'package:flutter/material.dart';

class HomeDonatur extends StatefulWidget {
  const HomeDonatur({super.key});

  @override
  State<HomeDonatur> createState() => _HomeDonaturState();
}

class _HomeDonaturState extends State<HomeDonatur> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home donatur'),
      ),
    );
  }
}
