import 'package:anti/screens/PenerimaDonasi/donasi_masuk.dart';
import 'package:flutter/material.dart';
import 'package:anti/pustaka.dart';

class NavigationPenerimaDonasi extends StatefulWidget {
  const NavigationPenerimaDonasi({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NavigationPenerimaDonasiState createState() =>
      _NavigationPenerimaDonasiState();
}

class _NavigationPenerimaDonasiState extends State<NavigationPenerimaDonasi> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const <Widget>[
          HomePenerimaDonasi(),
          DonasiMasuk(),
          AddPostingan(),
          NotifikasiPenerimaDonasi(),
          PersonPenerimaDonasi('Akun Saya'),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF96B12D),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        unselectedItemColor: Colors.white,
        selectedItemColor: const Color.fromARGB(255, 10, 10, 10),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.all_inclusive),
            label: 'donasimasuk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'addpostingan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'notifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
