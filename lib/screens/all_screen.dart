import 'package:flutter/material.dart';

class AllScreen extends StatelessWidget {
  const AllScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Troli Screen'),
      ),
      body: Center(
        child: Text('Troli Page'),
      ),
    );
  }
}