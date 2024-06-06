import 'package:flutter/material.dart';

class PenerimaDonasi extends StatefulWidget {
  const PenerimaDonasi({super.key});

  @override
  State<PenerimaDonasi> createState() => _PenerimaDonasiState();
}

class _PenerimaDonasiState extends State<PenerimaDonasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('penerima donasi '),
      ),
    );
  }
}
