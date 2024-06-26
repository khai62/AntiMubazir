import 'package:flutter/material.dart';
import 'package:anti/pustaka.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth for exceptions

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 24, right: 24, top: 160, bottom: 24),
          child: Form(
            key: _formKey,
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
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
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
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 14),
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
                    _isLoading
                        ? const CircularProgressIndicator()
                        : InkWell(
                            onTap: _login,
                            child: Container(
                              alignment: Alignment.center,
                              width: double.infinity,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Color(0xFF96B12D),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25)),
                              ),
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
                                  builder: (context) =>
                                      const RegisterScreen())),
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
      ),
    );
  }

  goToSignup(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RegisterScreen()),
      );

  _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = await _auth.loginUserWithEmailAndPassword(
            _email.text, _password.text);

        if (user != null) {
          final userType = await _getUserType(user.uid);
          if (userType != null) {
            goToHome(context, userType);
          } else {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User type not found')),
            );
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Login failed. Check your email and password.')),
          );
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });
        String errorMessage;
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided.';
        } else {
          errorMessage = 'Login failed. Please try again.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
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
