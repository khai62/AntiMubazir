import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> createUserWithEmailAndPassword(
      String email, String password, String name, String userType) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await cred.user!.updateDisplayName(name);

      // Simpan data pengguna termasuk userType ke Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'email': email,
        'name': name,
        'userType': userType,
      });

      // Setelah pengguna berhasil mendaftar, pindahkan data lokasi ke Firestore
      await _saveLocationToFirestore(cred.user!.uid);

      return cred.user;
    } catch (e) {
      log('something went wrong');
    }
    return null;
  }

  Future<void> _saveLocationToFirestore(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? latitude = prefs.getDouble('latitude');
    double? longitude = prefs.getDouble('longitude');

    if (latitude != null && longitude != null) {
      try {
        await FirebaseFirestore.instance.collection('locations').add({
          'userId': userId,
          'latitude': latitude,
          'longitude': longitude,
          'timestamp': FieldValue.serverTimestamp(),
        });
        print('Location saved to Firestore');

        // Hapus data dari SharedPreferences setelah disimpan di Firestore
        await prefs.remove('latitude');
        await prefs.remove('longitude');
      } catch (e) {
        print('Error saving location to Firestore: $e');
      }
    }
  }

  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      log('something went wrong');
    }
    return null;
  }

  Future<void> signout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log('something went wrong');
    }
  }

  Future<bool> checkIfEmailInUse(String email) async {
    try {
      // ignore: deprecated_member_use
      final signInMethods = await _auth.fetchSignInMethodsForEmail(email);
      return signInMethods.isNotEmpty;
    } catch (e) {
      log('Error checking if email is in use: $e');
      return false;
    }
  }
}
