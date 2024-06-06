import 'package:flutter/material.dart';

class NotifikasiPenerimaDonasi extends StatefulWidget {
  const NotifikasiPenerimaDonasi({super.key});

  @override
  State<NotifikasiPenerimaDonasi> createState() =>
      _NotifikasiPenerimaDonasiState();
}

class _NotifikasiPenerimaDonasiState extends State<NotifikasiPenerimaDonasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('notifikasi'),
      ),
    );
  }
}
