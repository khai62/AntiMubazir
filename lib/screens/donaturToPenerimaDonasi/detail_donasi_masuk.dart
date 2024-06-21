import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:anti/pustaka.dart';

class DetailDonasiMasuk extends StatefulWidget {
  final String donationId;

  const DetailDonasiMasuk({super.key, required this.donationId});

  @override
  State<DetailDonasiMasuk> createState() => _DetailDonasiMasukState();
}

class _DetailDonasiMasukState extends State<DetailDonasiMasuk> {
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('donasi');

  late Future<DocumentSnapshot> _future;
  final TextEditingController _rejectionReasonController =
      TextEditingController();
  int _currentIndex = 0;
  String? currentUserId;
  Map<String, dynamic>? profileData;

  @override
  void initState() {
    User? user = FirebaseAuth.instance.currentUser;
    super.initState();
    _future = _reference.doc(widget.donationId).get();
    currentUserId = user?.uid;
  }

  Future<void> _confirmDonation() async {
    await _reference.doc(widget.donationId).update({'status': 'Diterima'});
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromARGB(255, 223, 247, 202),
      builder: (context) => Container(
        height: 60,
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        child: const Center(
          child: Text(
            'Donasi berhasil dikonfirmasi',
            style: TextStyle(
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );

    setState(() {
      _future = _reference.doc(widget.donationId).get();
    });
  }

  Future<void> _rejectDonation() async {
    String reason = _rejectionReasonController.text.trim();
    if (reason.isNotEmpty) {
      await _reference.doc(widget.donationId).update({
        'status': 'Ditolak',
        'rejectionReason': reason,
      });
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color.fromARGB(255, 223, 247, 202),
        builder: (context) => Container(
          height: 60,
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          child: const Center(
            child: Text(
              'Donasi berhasil ditolak',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ),
        ),
      );
      setState(() {
        _future = _reference.doc(widget.donationId).get();
      });
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color.fromARGB(255, 223, 247, 202),
        builder: (context) => Container(
          height: 60,
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          child: const Center(
            child: Text(
              'Alasan Penolakan Harus ada',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ),
        ),
      );
    }
  }

  void _openChat() async {
    try {
      DocumentSnapshot snapshot = await _future;
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        String donaturId = data['donaturId'];
        String recipientName = data['name'];
        String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

        if (currentUserId.isEmpty) {
          print('Current user is not logged in');
          return;
        }

        String chatId = getChatId(currentUserId, donaturId);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: chatId,
              recipientName: recipientName,
              receiverId: donaturId,
            ),
          ),
        );
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error opening chat: $e');
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
        title: FutureBuilder<DocumentSnapshot>(
          future: _future,
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasData) {
              DocumentSnapshot documentSnapshot = snapshot.data!;
              if (documentSnapshot.exists) {
                Map<String, dynamic> data =
                    documentSnapshot.data() as Map<String, dynamic>;
                profileData = data;
                return Text(
                  'Detail donasi dari ${data['name']}',
                  overflow: TextOverflow.clip,
                  softWrap: true,
                );
              } else {
                return const Text('Donasi tidak ditemukan');
              }
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return const Text('Memuat...');
            }
          },
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _future,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            DocumentSnapshot documentSnapshot = snapshot.data!;
            if (documentSnapshot.exists) {
              Map<String, dynamic> data =
                  documentSnapshot.data() as Map<String, dynamic>;

              List<String> images = List<String>.from(data['images'] ?? []);

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (images.isNotEmpty)
                      Column(
                        children: [
                          CarouselSlider(
                            options: CarouselOptions(
                              height: 200,
                              autoPlay: true,
                              enlargeCenterPage: true,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentIndex = index;
                                });
                              },
                            ),
                            items: images.map((url) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Image.network(url, fit: BoxFit.cover);
                                },
                              );
                            }).toList(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: images.map((url) {
                              int index = images.indexOf(url);
                              return Container(
                                width: 8.0,
                                height: 8.0,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 2.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentIndex == index
                                      ? const Color(0xFF96B12D)
                                      : const Color.fromRGBO(0, 0, 0, 0.4),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Nama Donatur',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            data['name'],
                            style: const TextStyle(fontSize: 18),
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                          const SizedBox(height: 18),
                          const Text('No Hp',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            data['noHp'],
                            style: const TextStyle(fontSize: 18),
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                          const SizedBox(height: 18),
                          const Text('Tanggal Donasi',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            data['date'],
                            style: const TextStyle(fontSize: 18),
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                          const SizedBox(height: 18),
                          const Text('Cara Pengiriman',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            data['carapengiriman'],
                            style: const TextStyle(fontSize: 18),
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                          const SizedBox(height: 18),
                          const Text('Drop Poin',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            data['dropPoints'],
                            style: const TextStyle(fontSize: 18),
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                          const SizedBox(height: 18),
                          const Text('Keterangan',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            data['keterangan'],
                            style: const TextStyle(fontSize: 18),
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                          const SizedBox(height: 18),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('Status',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(
                                    left: 15, right: 15, top: 3, bottom: 3),
                                decoration: BoxDecoration(
                                  color: data['status'] == 'Menunggu'
                                      ? Colors.yellow
                                      : data['status'] == 'Diterima'
                                          ? Colors.green
                                          : Colors.red,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(25)),
                                ),
                                child: Text(
                                  data['status'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          if (data['status'] != 'Diterima' &&
                              data['status'] != 'Ditolak')
                            Column(
                              children: [
                                InkWell(
                                  onTap: _confirmDonation,
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: double.infinity,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF96B12D),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(25)),
                                    ),
                                    child: const Text(
                                      'Konfirmasi',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),
                                TextField(
                                  controller: _rejectionReasonController,
                                  decoration: const InputDecoration(
                                    labelText: 'Alasan Penolakan',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 3,
                                ),
                                const SizedBox(height: 20),
                                InkWell(
                                  onTap: _rejectDonation,
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: double.infinity,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(25)),
                                    ),
                                    child: const Text(
                                      'Tolak',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20)
                  ],
                ),
              );
            } else {
              return const Center(child: Text('Donasi tidak ditemukan'));
            }
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openChat,
        child: const Icon(Icons.chat),
      ),
    );
  }
}
