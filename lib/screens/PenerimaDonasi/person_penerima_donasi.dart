import 'package:anti/pustaka.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PersonPenerimaDonasi extends StatefulWidget {
  const PersonPenerimaDonasi(this.outerTab, {super.key});
  final String outerTab;

  @override
  State<PersonPenerimaDonasi> createState() => _PersonPenerimaDonasiState();
}

class _PersonPenerimaDonasiState extends State<PersonPenerimaDonasi>
    with TickerProviderStateMixin {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 50,
              ),
              child: Column(
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
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Setting()));
                          },
                          icon: const Icon(Icons.settings))
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
                  InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const ProfilePenerimaDonasi())),
                    child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFF96B12D),
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        child: const Text(
                          'Lengkapi Profile',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white),
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TabBar(
              controller: _tabController,
              tabs: const <Widget>[
                Tab(
                    child: Text('Postingan saya',
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
                  PostinganSaya(),
                  Tersimpan(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddPostingan()));
        },
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
