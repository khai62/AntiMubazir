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

  PermissionService().startTracking();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Map<String, bool>> _initScreens;

  @override
  void initState() {
    super.initState();
    _initScreens = _getInitScreens();
  }

  Future<Map<String, bool>> _getInitScreens() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool onbordingShown = preferences.getBool('onbordingShown') ?? false;
    bool loginShown = preferences.getBool('loginShown') ?? false;

    await preferences.setBool('onbordingShown', true);

    return {
      'onbordingShown': onbordingShown,
      'loginShown': loginShown,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, bool>>(
      future: _initScreens,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            ),
          );
        } else {
          Map<String, bool> initScreens = snapshot.data!;
          bool onbordingShown = initScreens['onbordingShown']!;
          bool loginShown = initScreens['loginShown']!;

          String initialRoute;
          if (!onbordingShown) {
            initialRoute = 'onbording';
          } else if (!loginShown) {
            initialRoute = 'loginscreen';
          } else {
            initialRoute = 'navigationscreen';
          }
          return MaterialApp(
            initialRoute: initialRoute,
            routes: {
              'navigationscreen': (context) => const NavigationScreen(),
              'onbording': (context) => const Onbording(),
              'loginscreen': (context) => const LoginScreen(),
            },
          );
        }
      },
    );
  }
}
