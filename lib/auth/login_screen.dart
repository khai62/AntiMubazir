import 'package:flutter/material.dart';
import 'package:anti/pustaka.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();

  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   Future.delayed(const Duration(seconds: 4), () {
  //     goToHome(context, 'userType');
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 24, right: 24, top: 160, bottom: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Image.asset(
                    'assets/images/logos.png',
                    width: 147,
                    height: 79,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text('Silahkan masuk menggunakan email',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(
                height: 60,
              ),
              Column(
                children: [
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    decoration: const InputDecoration(
                        hintText: 'Email',
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.black,
                        ))),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  TextFormField(
                    controller: _password,
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    decoration: const InputDecoration(
                        hintText: 'Password',
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.black,
                        ))),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Lupa Password?',
                            style: TextStyle(color: Colors.blue, fontSize: 14),
                          ))
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFF96B12D),
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    child: TextButton(
                      onPressed: _login,
                      child: const Text(
                        textAlign: TextAlign.center,
                        'Masuk',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      const Text(
                        'Belum punya akun?',
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterScreen())),
                        child: const Text(
                          'Daftar',
                          style: TextStyle(fontSize: 14, color: Colors.blue),
                        ),
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  goToSignup(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RegisterScreen()),
      );

  // goToHome(BuildContext context, String userType) async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   await preferences.setBool('loginShown', true);
  //   await preferences.setString('userType', userType);

  //   if (userType == 'Donatur') {
  //     Navigator.push(context,
  //         MaterialPageRoute(builder: (context) => const NavigationDonatur()));
  //   } else {
  //     Navigator.push(context,
  //         MaterialPageRoute(builder: (context) => const HomePenerimaDonasi()));
  //   }
  // }

  _login() async {
    final user =
        await _auth.loginUserWithEmailAndPassword(_email.text, _password.text);

    if (user != null) {
      final userType = await _getUserType(user.uid);
      if (userType != null) {
        print('login successful');
        goToHome(context, userType);
      } else {
        print('User type not found');
        // Handle situation where user type is not found
      }
    } else {
      print('Login failed');
      // Handle failed login
    }
  }

  Future<String?> _getUserType(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists) {
        return doc.data()?['userType'];
      }
    } catch (e) {
      print('Error getting user type: $e');
      // Handle error getting user type
    }
    return null;
  }

  void goToHome(BuildContext context, String userType) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool('loginShown', true);
    await preferences.setString('userType', userType);

    if (userType == 'Donatur') {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const NavigationDonatur()));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const NavigationPenerimaDonasi()));
    }
  }
}
