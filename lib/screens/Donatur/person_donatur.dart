import 'package:anti/pustaka.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Person extends StatefulWidget {
  const Person(this.outerTab, {super.key});
  final String outerTab;

  @override
  State<Person> createState() => _PersonState();
}

class _PersonState extends State<Person> with TickerProviderStateMixin {
  User? _user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _user = user;
    });
  }

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 24, right: 24, top: 50, bottom: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Akun Saya',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.asset(
                      'assets/images/person.png',
                      width: 60,
                      height: 60,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Center(
                    child: _user != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ' ${_user!.displayName ?? 'Not available'}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black),
                              ),
                              Text(' ${_user!.email ?? 'Not available'}',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black)),
                            ],
                          )
                        : const CircularProgressIndicator(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TabBar(
                controller: _tabController,
                tabs: const <Widget>[
                  Tab(
                      child: Text('Donasi saya',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              fontSize: 18))),
                  Tab(
                      child: Text('Tersimpan',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              fontSize: 18))),
                ],
              ),
              SizedBox(
                height: 400,
                child: TabBarView(
                  controller: _tabController,
                  children: const <Widget>[
                    JualanSaya(),
                    Tersimpan(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
