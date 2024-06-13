import 'package:flutter/material.dart';
import 'package:anti/pustaka.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    User? currentUser = FirebaseAuth.instance.currentUser;
    final String? currentUserId = currentUser?.uid;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          const HomePenerimaDonasi(
            postId: '',
          ),
          if (currentUserId != null)
            DonasiMasuk(
              userId: currentUserId,
            ),
          if (currentUserId != null)
            NotifikasiPenerimaDonasi(userId: currentUserId),
          const PersonPenerimaDonasi('Akun Saya'),
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
