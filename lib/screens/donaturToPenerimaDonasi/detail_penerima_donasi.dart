import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Tambahkan ini untuk mendapatkan user saat ini
import 'package:anti/pustaka.dart';

class DetailPenerimaDonasi extends StatefulWidget {
  final String id;

  const DetailPenerimaDonasi({super.key, required this.id});

  @override
  _DetailPenerimaDonasiState createState() => _DetailPenerimaDonasiState();
}

class _DetailPenerimaDonasiState extends State<DetailPenerimaDonasi>
    with SingleTickerProviderStateMixin {
  late DocumentReference _reference;
  late Stream<DocumentSnapshot> _stream;
  late TabController _tabController;
  DocumentSnapshot?
      _currentSnapshot; // Menyimpan snapshot terakhir untuk referensi
  late String currentUserId; // ID pengguna saat ini

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _reference =
        FirebaseFirestore.instance.collection('profiles').doc(widget.id);
    _stream = _reference.snapshots();

    // Menyimpan data terakhir dari snapshot
    _stream.listen((snapshot) {
      setState(() {
        _currentSnapshot = snapshot;
      });
    });

    // Mendapatkan ID pengguna saat ini
    User? user = FirebaseAuth.instance.currentUser;
    currentUserId = user?.uid ?? ''; // Simpan ID pengguna saat ini
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openChat(String userId, String recipientName) {
    if (_currentSnapshot != null) {
      String chatId = getChatId(currentUserId, userId);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatId: chatId,
            recipientName: recipientName,
            receiverId:
                userId, // Tambahkan ini untuk mengirim receiverId ke ChatScreen
          ),
        ),
      );
    } else {
      print('Snapshot data is not available yet.');
    }
  }

  String getChatId(String userId1, String userId2) {
    return userId1.hashCode <= userId2.hashCode
        ? '$userId1-$userId2'
        : '$userId2-$userId1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: StreamBuilder<DocumentSnapshot>(
          stream: _stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              DocumentSnapshot documentSnapshot = snapshot.data;
              if (documentSnapshot.exists) {
                Map<String, dynamic> data =
                    documentSnapshot.data() as Map<String, dynamic>;
                return Text(
                  'Detail ${data['nama'] ?? 'N/A'}', // Beri nilai default 'N/A' jika data['nama'] null
                  overflow: TextOverflow.clip,
                  softWrap: true,
                );
              }
            }
            return const Text(
              'Detail',
              overflow: TextOverflow.clip,
              softWrap: true,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            StreamBuilder<DocumentSnapshot>(
              stream: _stream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Some error occurred ${snapshot.error}'));
                }

                if (snapshot.hasData) {
                  DocumentSnapshot documentSnapshot = snapshot.data;
                  if (!documentSnapshot.exists) {
                    return const Center(child: Text('Document does not exist'));
                  }
                  Map<String, dynamic> data =
                      documentSnapshot.data() as Map<String, dynamic>;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 14, right: 14, top: 5, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 130,
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                                child: (data.containsKey('bannerImageUrl') &&
                                        data['bannerImageUrl'] != null)
                                    ? (data['bannerImageUrl'] is List &&
                                            data['bannerImageUrl'].isNotEmpty)
                                        ? Image.network(
                                            '${data['bannerImageUrl'][0]}',
                                            fit: BoxFit.cover,
                                          )
                                        : (data['bannerImageUrl'] is String)
                                            ? Image.network(
                                                '${data['bannerImageUrl']}',
                                                fit: BoxFit.cover,
                                              )
                                            : Container(color: Colors.grey)
                                    : Container(color: Colors.grey),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: 65,
                                  width: 65,
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(32.5)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(40)),
                                    child: (data.containsKey(
                                                'profileImageUrl') &&
                                            data['profileImageUrl'] != null)
                                        ? (data['profileImageUrl'] is List &&
                                                data['profileImageUrl']
                                                    .isNotEmpty)
                                            ? Image.network(
                                                '${data['profileImageUrl'][0]}',
                                                fit: BoxFit.cover,
                                              )
                                            : (data['profileImageUrl']
                                                    is String)
                                                ? Image.network(
                                                    '${data['profileImageUrl']}',
                                                    fit: BoxFit.cover,
                                                  )
                                                : Container(color: Colors.grey)
                                        : Container(color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['nama'] ??
                                          'N/A', // Beri nilai default 'N/A' jika data['nama'] null
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                      overflow: TextOverflow.clip,
                                      softWrap: true,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      data['email'] ??
                                          'N/A', // Beri nilai default 'N/A' jika data['email'] null
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => KetentuanDonasi(
                                            id: data['userId'] ??
                                                ''))); // Beri nilai default '' jika data['userId'] null
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: 200,
                                height: 40,
                                decoration: const BoxDecoration(
                                    color: Color(0xFF96B12D),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: const Text(
                                  'Donasi',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TabBar(
                        controller: _tabController,
                        tabs: const <Widget>[
                          Tab(
                              child: Text('Postingan',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                      fontSize: 18))),
                          Tab(
                              child: Text('Tentang',
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
                          children: <Widget>[
                            PostinganDetailPenerimaDonasi(
                              userId: widget.id,
                            ),
                            TentangPenerimaDonasi(
                              id: data['userId'] ??
                                  '', // Beri nilai default '' jika data['userId'] null
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentSnapshot != null) {
            Map<String, dynamic> data =
                _currentSnapshot!.data() as Map<String, dynamic>;
            _openChat(
                data['userId'] ?? '',
                data['nama'] ??
                    'N/A'); // Beri nilai default jika data['userId'] atau data['nama'] null
          } else {
            print('Snapshot data is not available yet.');
          }
        },
        child: const Icon(Icons.chat),
      ),
    );
  }
}
