import 'package:flutter/material.dart';

class AddPostingan extends StatefulWidget {
  const AddPostingan({super.key});

  @override
  State<AddPostingan> createState() => _AddPostinganState();
}

class _AddPostinganState extends State<AddPostingan> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('add postingan'),
      ),
    );
  }
}
