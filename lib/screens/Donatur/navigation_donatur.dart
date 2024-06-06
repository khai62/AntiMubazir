import 'package:flutter/material.dart';
import 'package:anti/pustaka.dart';

class NavigationDonatur extends StatefulWidget {
  const NavigationDonatur({super.key});

  @override
  State<NavigationDonatur> createState() => _NavigationDonaturState();
}

class _NavigationDonaturState extends State<NavigationDonatur> {
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
          HomeDonatur(),
          PenerimaDonasi(),
          Notifikasi(),
          Person('Akun Saya'),
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
            label: 'Troli',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Message',
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
