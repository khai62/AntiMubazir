import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:anti/firebase_options.dart';
import 'package:anti/pustaka.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // PermissionService().startTracking();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Map<String, dynamic>> _initScreens;

  @override
  void initState() {
    super.initState();
    _initScreens = _getInitScreens();
  }

  Future<Map<String, dynamic>> _getInitScreens() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool onbordingShown = preferences.getBool('onbordingShown') ?? false;
    bool loginShown = preferences.getBool('loginShown') ?? false;
    String? userType = preferences
        .getString('userType'); // Tambahkan ini untuk mendapatkan userType

    await preferences.setBool('onbordingShown', true);

    return {
      'onbordingShown': onbordingShown,
      'loginShown': loginShown,
      'userType': userType,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _initScreens,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(color: Colors.white);
        } else if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            ),
          );
        } else {
          Map<String, dynamic> initScreens = snapshot.data!;
          bool onbordingShown = initScreens['onbordingShown']!;
          bool loginShown = initScreens['loginShown']!;
          String? userType = initScreens['userType'];

          String initialRoute;
          if (!onbordingShown) {
            initialRoute = 'onbording';
          } else if (!loginShown) {
            initialRoute = 'loginscreen';
          } else {
            initialRoute = userType == 'Donatur'
                ? 'navigasidonatur'
                : 'navigasipenerimadonasi';
          }

          return MaterialApp(
            initialRoute: initialRoute,
            routes: {
              'navigasidonatur': (context) => const NavigationDonatur(),
              'navigasipenerimadonasi': (context) =>
                  const NavigationPenerimaDonasi(),
              'onbording': (context) => const Onbording(),
              'loginscreen': (context) => const LoginScreen(),
            },
          );
        }
      },
    );
  }
}
