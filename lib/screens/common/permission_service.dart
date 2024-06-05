import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  // meminta izin notification s
  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('User granted provisional permission');
      }
    } else {
      if (kDebugMode) {
        print('User denied permission');
      }
    }
  }

  //akhir ---------- meminta izin dan notification

  Future<void> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      print('Location permission granted');
      await _getCurrentLocation();
    } else if (status.isDenied) {
      print('Location permission denied');
    } else if (status.isPermanentlyDenied) {
      print(
          'Location permission permanently denied, open app settings to change');
      openAppSettings();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print('Current location: ${position.latitude}, ${position.longitude}');

      // Simpan lokasi sementara di SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('latitude', position.latitude);
      await prefs.setDouble('longitude', position.longitude);
      print('Location saved to SharedPreferences');
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void startTracking() {
    // Minta izin lokasi dan dapatkan lokasi saat ini
    requestLocationPermission();

    // Set timer untuk mendapatkan lokasi secara periodik
    Timer.periodic(const Duration(minutes: 5), (timer) {
      requestLocationPermission();
    });
  }

  Future<void> requestPhonePermission() async {
    PermissionStatus status = await Permission.phone.request();
    if (status.isGranted) {
      print('Phone permission granted');
    } else if (status.isDenied) {
      print('Phone permission denied');
    } else if (status.isPermanentlyDenied) {
      print('Phone permission permanently denied, open app settings to change');
      openAppSettings();
    }
  }
}
