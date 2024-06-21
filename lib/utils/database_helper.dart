
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:firebase_auth/firebase_auth.dart';

// class Notifikasi extends StatefulWidget {
//   const Notifikasi({super.key});

//   @override
//   _NotifikasiState createState() => _NotifikasiState();
// }

// class _NotifikasiState extends State<Notifikasi> {
//   final String _apiKey = '2c96cb8ed2c7441f9bd770cbb3d9b0bf';

//   Future<String> _getAddressFromLatLng(
//       double latitude, double longitude) async {
//     final url =
//         'https://api.opencagedata.com/geocode/v1/json?q=$latitude+$longitude&key=$_apiKey';
//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['results'].isNotEmpty) {
//         return data['results'][0]['formatted'];
//       } else {
//         return 'No address found';
//       }
//     } else {
//       return 'Failed to get address';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     User? user = FirebaseAuth.instance.currentUser;

//     if (user == null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('Saved Locations'),
//         ),
//         body: const Center(
//           child: Text('Please log in to see your saved locations.'),
//         ),
//       );
//     }

//     print('Current User UID: ${user.uid}');

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Saved Locations'),
//       ),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance
//             .collection('locations')
//             .where('userId', isEqualTo: user.uid)
//             .snapshots(),
//         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.data!.docs.isEmpty) {
//             return const Center(
//                 child: Text('No locations found for this user.'));
//           }
//           return ListView.builder(
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (context, index) {
//               final doc = snapshot.data!.docs[index];
//               final latitude = doc['latitude'];
//               final longitude = doc['longitude'];
//               return FutureBuilder(
//                 future: _getAddressFromLatLng(latitude, longitude),
//                 builder: (context, AsyncSnapshot<String> addressSnapshot) {
//                   if (!addressSnapshot.hasData) {
//                     return const ListTile(
//                       title: Text('Loading address...'),
//                     );
//                   }
//                   return ListTile(
//                     title: Text(addressSnapshot.data!),
//                     subtitle: Text('Lat: $latitude, Lng: $longitude'),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// ------------------------------------------------------ chat

// Expanded(
//   child: StreamBuilder<QuerySnapshot>(
//     stream: _firestore
//         .collection('chats')
//         .doc(widget.chatId)
//         .collection('messages')
//         .orderBy('timestamp', descending: true)
//         .snapshots(),
//     builder: (context, snapshot) {
//       if (!snapshot.hasData) {
//         return Center(child: CircularProgressIndicator());
//       }
//       final messages = snapshot.data!.docs.map((doc) {
//         return ChatMessage.fromDocument(doc);
//       }).toList();
//       return ListView.builder(
//         reverse: true,
//         itemCount: messages.length,
//         itemBuilder: (context, index) {
//           final message = messages[index];
//           final isMe = message.senderId == _auth.currentUser?.uid;
//           return ListTile(
//             title: Align(
//               alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: isMe ? Colors.blue : Colors.grey[300],
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   message.text,
//                   style: TextStyle(color: isMe ? Colors.white : Colors.black),
//                 ),
//               ),
//             ),
//           );
//         },
//       );
//     },
//   ),
// ),



// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:anti/pustaka.dart';
// import 'chat_screen.dart'; // Pastikan file ini diimport

// class DetailDonasiSaya extends StatefulWidget {
//   final String donationId;

//   const DetailDonasiSaya({super.key, required this.donationId});

//   @override
//   State<DetailDonasiSaya> createState() => _DetailDonasiSayaState();
// }

// class _DetailDonasiSayaState extends State<DetailDonasiSaya> {
//   final CollectionReference _reference =
//       FirebaseFirestore.instance.collection('donasi');

//   late Future<DocumentSnapshot> _future;
//   final TextEditingController _rejectionReasonController =
//       TextEditingController();
//   int _currentIndex = 0;
//   String currentUserId = FirebaseAuth.instance.currentUser!.uid;

//   @override
//   void initState() {
//     super.initState();
//     _future = _reference.doc(widget.donationId).get();
//   }

//   Future<void> _confirmDonation() async {
//     await _reference.doc(widget.donationId).update({'status': 'Diterima'});
//     showModalBottomSheet(
//         context: context,
//         backgroundColor: const Color.fromARGB(255, 223, 247, 202),
//         builder: (context) => Container(
//             height: 60,
//             width: double.infinity,
//             padding: const EdgeInsets.all(10),
//             child: const Center(
//               child: Text(
//                 'Donasi berhasil dikonfirmasi',
//                 style: TextStyle(
//                   fontSize: 15,
//                   color: Colors.black,
//                 ),
//               ),
//             )));

//     setState(() {
//       _future = _reference.doc(widget.donationId).get();
//     });
//   }

//   Future<void> _rejectDonation() async {
//     String reason = _rejectionReasonController.text.trim();
//     if (reason.isNotEmpty) {
//       await _reference.doc(widget.donationId).update({
//         'status': 'Ditolak',
//         'rejectionReason': reason,
//       });
//       showModalBottomSheet(
//           context: context,
//           backgroundColor: const Color.fromARGB(255, 223, 247, 202),
//           builder: (context) => Container(
//               height: 60,
//               width: double.infinity,
//               padding: const EdgeInsets.all(10),
//               child: const Center(
//                 child: Text(
//                   'Donasi berhasil ditolak',
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: Colors.black,
//                   ),
//                 ),
//               )));
//       setState(() {
//         _future = _reference.doc(widget.donationId).get(); // Refresh data
//       });
//     } else {
//       showModalBottomSheet(
//           context: context,
//           backgroundColor: const Color.fromARGB(255, 223, 247, 202),
//           builder: (context) => Container(
//               height: 60,
//               width: double.infinity,
//               padding: const EdgeInsets.all(10),
//               child: const Center(
//                 child: Text(
//                   'Alasan Penolakan Harus ada',
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: Colors.black,
//                   ),
//                 ),
//               )));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         surfaceTintColor: Colors.transparent,
//         backgroundColor: Colors.transparent,
//         title: FutureBuilder<DocumentSnapshot>(
//           future: _future,
//           builder:
//               (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
//             if (snapshot.hasData) {
//               DocumentSnapshot documentSnapshot = snapshot.data!;
//               if (documentSnapshot.exists) {
//                 Map<String, dynamic> data =
//                     documentSnapshot.data() as Map<String, dynamic>;
//                 return const Text(
//                   'Detail donasi saya',
//                   overflow: TextOverflow.clip,
//                   softWrap: true,
//                 );
//               } else {
//                 return const Text('Donasi tidak ditemukan');
//               }
//             } else if (snapshot.hasError) {
//               return Text('Error: ${snapshot.error}');
//             } else {
//               return const Text('Memuat...');
//             }
//           },
//         ),
//       ),
//       body: FutureBuilder<DocumentSnapshot>(
//         future: _future,
//         builder:
//             (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
//           if (snapshot.hasData) {
//             DocumentSnapshot documentSnapshot = snapshot.data!;
//             if (documentSnapshot.exists) {
//               Map<String, dynamic> data =
//                   documentSnapshot.data() as Map<String, dynamic>;

//               List<String> images = List<String>.from(data['images'] ?? []);
//               String userId = data['userId']; // Memperbaiki kesalahan variabel

//               return SingleChildScrollView(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     if (images.isNotEmpty)
//                       Column(
//                         children: [
//                           CarouselSlider(
//                             options: CarouselOptions(
//                               height: 200,
//                               autoPlay: true,
//                               enlargeCenterPage: true,
//                               onPageChanged: (index, reason) {
//                                 setState(() {
//                                   _currentIndex = index;
//                                 });
//                               },
//                             ),
//                             items: images.map((url) {
//                               return Builder(
//                                 builder: (BuildContext context) {
//                                   return Image.network(url, fit: BoxFit.cover);
//                                 },
//                               );
//                             }).toList(),
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: images.map((url) {
//                               int index = images.indexOf(url);
//                               return Container(
//                                 width: 8.0,
//                                 height: 8.0,
//                                 margin: const EdgeInsets.symmetric(
//                                     vertical: 10.0, horizontal: 2.0),
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: _currentIndex == index
//                                       ? const Color(0xFF96B12D)
//                                       : const Color.fromRGBO(0, 0, 0, 0.4),
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                         ],
//                       ),
//                     const Text('Nama Donatur',
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold)),
//                     Text(
//                       data['name'],
//                       style: const TextStyle(fontSize: 18),
//                       overflow: TextOverflow.visible,
//                       softWrap: true,
//                     ),
//                     const SizedBox(height: 18),
//                     const Text('No Hp',
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold)),
//                     Text(
//                       data['noHp'],
//                       style: const TextStyle(fontSize: 18),
//                       overflow: TextOverflow.visible,
//                       softWrap: true,
//                     ),
//                     const SizedBox(height: 18),
//                     const Text('Tanggal Donasi',
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold)),
//                     Text(
//                       data['date'],
//                       style: const TextStyle(fontSize: 18),
//                       overflow: TextOverflow.visible,
//                       softWrap: true,
//                     ),
//                     const SizedBox(height: 18),
//                     const Text('Cara Pengiriman',
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold)),
//                     Text(
//                       data['carapengiriman'],
//                       style: const TextStyle(fontSize: 18),
//                       overflow: TextOverflow.visible,
//                       softWrap: true,
//                     ),
//                     const SizedBox(height: 18),
//                     const Text('Drop Poin',
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold)),
//                     Text(
//                       data['dropPoints'],
//                       style: const TextStyle(fontSize: 18),
//                       overflow: TextOverflow.visible,
//                       softWrap: true,
//                     ),
//                     const SizedBox(height: 18),
//                     const Text('Keterangan',
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold)),
//                     Text(
//                       data['keterangan'],
//                       style: const TextStyle(fontSize: 18),
//                       overflow: TextOverflow.visible,
//                       softWrap: true,
//                     ),
//                     const SizedBox(height: 18),
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         const Text('Status',
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold)),
//                         const SizedBox(
//                           width: 10,
//                         ),
//                         Container(
//                           alignment: Alignment.center,
//                           padding: const EdgeInsets.only(
//                               left: 15, right: 15, top: 3, bottom: 3),
//                           decoration: BoxDecoration(
//                             color: data['status'] == 'Menunggu'
//                                 ? Colors.yellow
//                                 : data['status'] == 'Diterima'
//                                     ? Colors.green
//                                     : Colors.red,
//                             borderRadius:
//                                 const BorderRadius.all(Radius.circular(25)),
//                           ),
//                           child: Text(
//                             data['status'],
//                             style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 18,
//                                 color: Colors.white),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 18),
//                     if (data['status'] == 'Ditolak' &&
//                         data['rejectionReason'] != null)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text('Alasan Penolakan',
//                                 style: TextStyle(
//                                     fontSize: 18, fontWeight: FontWeight.bold)),
//                             Text(
//                               data['rejectionReason'],
//                               style: const TextStyle(fontSize: 18),
//                               overflow: TextOverflow.visible,
//                               softWrap: true,
//                             ),
//                           ],
//                         ),
//                       ),
//                     const SizedBox(height: 20)
//                   ],
//                 ),
//               );
//             } else {
//               return const Center(child: Text('Donasi tidak ditemukan'));
//             }
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else {
//             return const Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//       floatingActionButton: FutureBuilder<DocumentSnapshot>(
//         future: _future,
//         builder:
//             (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
//           if (snapshot.hasData) {
//             DocumentSnapshot documentSnapshot = snapshot.data!;
//             if (documentSnapshot.exists) {
//               Map<String, dynamic> data =
//                   documentSnapshot.data() as Map<String, dynamic>;
//               String userId = data['userId'];
//               return FloatingActionButton(
//                 onPressed: () {
//                   String chatId = getChatId(currentUserId, userId);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ChatScreen(
//                         chatId: chatId,
//                         recipientName: data['name'],
//                       ),
//                     ),
//                   );
//                 },
//                 tooltip: 'Chat',
//                 child: const Icon(Icons.chat),
//               );
//             } else {
//               return Container(); // or some other fallback
//             }
//           } else {
//             return const CircularProgressIndicator(); // Loading state
//           }
//         },
//       ),
//     );
//   }
  
//   // Method to get chatId from two user IDs
//   String getChatId(String userId1, String userId2) {
//     if (userId1.compareTo(userId2) > 0) {
//       return '$userId1-$userId2';
//     } else {
//       return '$userId2-$userId1';
//     }
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:anti/pustaka.dart';

// class DetailPenerimaDonasi extends StatefulWidget {
//   final String id;

//   const DetailPenerimaDonasi({super.key, required this.id});

//   @override
//   _DetailPenerimaDonasiState createState() => _DetailPenerimaDonasiState();
// }

// class _DetailPenerimaDonasiState extends State<DetailPenerimaDonasi>
//     with SingleTickerProviderStateMixin {
//   late DocumentReference _reference;
//   late Stream<DocumentSnapshot> _stream;
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _reference =
//         FirebaseFirestore.instance.collection('profiles').doc(widget.id);
//     _stream = _reference.snapshots();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   void _openChat(String userId) {
//     String currentUserId =
//         'your_current_user_id'; // Ganti dengan ID pengguna yang sesuai
//     String chatId = getChatId(currentUserId, userId);
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ChatScreen(
//           chatId: chatId,
//           recipientName:
//               'Nama Penerima Donasi', // Ganti dengan nama penerima donasi
//         ),
//       ),
//     );
//   }

//   String getChatId(String userId1, String userId2) {
//     return userId1.hashCode <= userId2.hashCode
//         ? '$userId1-$userId2'
//         : '$userId2-$userId1';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         surfaceTintColor: Colors.transparent,
//         backgroundColor: Colors.transparent,
//         title: StreamBuilder<DocumentSnapshot>(
//           stream: _stream,
//           builder: (BuildContext context, AsyncSnapshot snapshot) {
//             if (snapshot.hasData) {
//               DocumentSnapshot documentSnapshot = snapshot.data;
//               if (documentSnapshot.exists) {
//                 Map<String, dynamic> data =
//                     documentSnapshot.data() as Map<String, dynamic>;
//                 return Text(
//                   'Detail ${data['nama']}',
//                   overflow: TextOverflow.clip,
//                   softWrap: true,
//                 );
//               }
//             }
//             return const Text(
//               'Detail',
//               overflow: TextOverflow.clip,
//               softWrap: true,
//             );
//           },
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 20),
//               StreamBuilder<DocumentSnapshot>(
//                 stream: _stream,
//                 builder: (BuildContext context, AsyncSnapshot snapshot) {
//                   if (snapshot.hasError) {
//                     return Center(
//                         child: Text('Some error occurred ${snapshot.error}'));
//                   }

//                   if (snapshot.hasData) {
//                     DocumentSnapshot documentSnapshot = snapshot.data;
//                     if (!documentSnapshot.exists) {
//                       return const Center(
//                           child: Text('Document does not exist'));
//                     }
//                     Map<String, dynamic> data =
//                         documentSnapshot.data() as Map<String, dynamic>;

//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           height: 130,
//                           width: double.infinity,
//                           decoration: const BoxDecoration(
//                             borderRadius: BorderRadius.all(Radius.circular(15)),
//                           ),
//                           child: ClipRRect(
//                             borderRadius:
//                                 const BorderRadius.all(Radius.circular(15)),
//                             child: (data.containsKey('bannerImageUrl') &&
//                                     data['bannerImageUrl'] != null)
//                                 ? (data['bannerImageUrl'] is List &&
//                                         data['bannerImageUrl'].isNotEmpty)
//                                     ? Image.network(
//                                         '${data['bannerImageUrl'][0]}',
//                                         fit: BoxFit.cover,
//                                       )
//                                     : (data['bannerImageUrl'] is String)
//                                         ? Image.network(
//                                             '${data['bannerImageUrl']}',
//                                             fit: BoxFit.cover,
//                                           )
//                                         : Container(color: Colors.grey)
//                                 : Container(color: Colors.grey),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             Container(
//                               height: 65,
//                               width: 65,
//                               decoration: const BoxDecoration(
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(32.5)),
//                               ),
//                               child: ClipRRect(
//                                 borderRadius:
//                                     const BorderRadius.all(Radius.circular(40)),
//                                 child: (data.containsKey('profileImageUrl') &&
//                                         data['profileImageUrl'] != null)
//                                     ? (data['profileImageUrl'] is List &&
//                                             data['profileImageUrl'].isNotEmpty)
//                                         ? Image.network(
//                                             '${data['profileImageUrl'][0]}',
//                                             fit: BoxFit.cover,
//                                           )
//                                         : (data['profileImageUrl'] is String)
//                                             ? Image.network(
//                                                 '${data['profileImageUrl']}',
//                                                 fit: BoxFit.cover,
//                                               )
//                                             : Container(color: Colors.grey)
//                                     : Container(color: Colors.grey),
//                               ),
//                             ),
//                             const SizedBox(width: 20),
//                             Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   data['nama'],
//                                   style: const TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.black),
//                                   overflow: TextOverflow.clip,
//                                   softWrap: true,
//                                 ),
//                                 const SizedBox(height: 10),
//                                 Text(
//                                   data['email'],
//                                   style: const TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.black),
//                                 ),
//                               ],
//                             )
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         InkWell(
//                           onTap: () {
//                             _openChat(data['userId']);
//                           },
//                           child: Container(
//                             alignment: Alignment.center,
//                             width: 200,
//                             height: 40,
//                             decoration: const BoxDecoration(
//                                 color: Color(0xFF96B12D),
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(20))),
//                             child: const Text(
//                               'Chat',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                   color: Colors.white),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         TabBar(
//                           controller: _tabController,
//                           tabs: const <Widget>[
//                             Tab(
//                               child: Text(
//                                 'Postingan',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w400,
//                                   color: Colors.black,
//                                   fontSize: 18,
//                                 ),
//                               ),
//                             ),
//                             Tab(
//                               child: Text(
//                                 'Tentang',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w400,
//                                   color: Colors.black,
//                                   fontSize: 18,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(
//                           height: 400,
//                           child: TabBarView(
//                             controller: _tabController,
//                             children: <Widget>[
//                               PostinganDetailPenerimaDonasi(userId: widget.id),
//                               TentangPenerimaDonasi(id: data['userId']),
//                             ],
//                           ),
//                         ),
//                       ],
//                     );
//                   }

//                   return const Center(child: CircularProgressIndicator());
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:anti/pustaka.dart';

// class DetailDonasiMasuk extends StatefulWidget {
//   final String donationId;

//   const DetailDonasiMasuk({super.key, required this.donationId});

//   @override
//   State<DetailDonasiMasuk> createState() => _DetailDonasiMasukState();
// }

// class _DetailDonasiMasukState extends State<DetailDonasiMasuk> {
//   final CollectionReference _reference =
//       FirebaseFirestore.instance.collection('donasi');

//   late Future<DocumentSnapshot> _future;
//   final TextEditingController _rejectionReasonController =
//       TextEditingController();
//   int _currentIndex = 0;
//   String? currentUserId;
//   Map<String, dynamic>? profileData;

//   @override
//   void initState() {
//     User? user = FirebaseAuth.instance.currentUser;
//     super.initState();
//     _future = _reference.doc(widget.donationId).get();
//     currentUserId =
//         user?.uid; // Menggunakan ID pengguna saat ini dari FirebaseAuth
//   }

//   Future<void> _confirmDonation() async {
//     await _reference.doc(widget.donationId).update({'status': 'Diterima'});
//     showModalBottomSheet(
//         context: context,
//         backgroundColor: const Color.fromARGB(255, 223, 247, 202),
//         builder: (context) => Container(
//             height: 60,
//             width: double.infinity,
//             padding: const EdgeInsets.all(10),
//             child: const Center(
//               child: Text(
//                 'Donasi berhasil dikonfirmasi',
//                 style: TextStyle(
//                   fontSize: 15,
//                   color: Colors.black,
//                 ),
//               ),
//             )));

//     setState(() {
//       _future = _reference.doc(widget.donationId).get();
//     });
//   }

//   Future<void> _rejectDonation() async {
//     String reason = _rejectionReasonController.text.trim();
//     if (reason.isNotEmpty) {
//       await _reference.doc(widget.donationId).update({
//         'status': 'Ditolak',
//         'rejectionReason': reason,
//       });
//       showModalBottomSheet(
//           context: context,
//           backgroundColor: const Color.fromARGB(255, 223, 247, 202),
//           builder: (context) => Container(
//               height: 60,
//               width: double.infinity,
//               padding: const EdgeInsets.all(10),
//               child: const Center(
//                 child: Text(
//                   'Donasi berhasil ditolak',
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: Colors.black,
//                   ),
//                 ),
//               )));
//       setState(() {
//         _future = _reference.doc(widget.donationId).get(); // Refresh data
//       });
//     } else {
//       showModalBottomSheet(
//           context: context,
//           backgroundColor: const Color.fromARGB(255, 223, 247, 202),
//           builder: (context) => Container(
//               height: 60,
//               width: double.infinity,
//               padding: const EdgeInsets.all(10),
//               child: const Center(
//                 child: Text(
//                   'Alasan Penolakan Harus ada',
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: Colors.black,
//                   ),
//                 ),
//               )));
//     }
//   }

//   void _openChat() async {
//     try {
//       DocumentSnapshot snapshot = await _future;
//       if (snapshot.exists) {
//         Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
//         String donaturId = data['donaturId'];
//         String recipientName = data['name'];
//         String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

//         if (currentUserId.isEmpty) {
//           print('Current user is not logged in');
//           return;
//         }

//         String chatId = getChatId(currentUserId, donaturId);

//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ChatScreen(
//               chatId: chatId,
//               recipientName: recipientName,
//             ),
//           ),
//         );
//       } else {
//         print('Document does not exist');
//       }
//     } catch (e) {
//       print('Error opening chat: $e');
//     }
//   }

//   String getChatId(String userId1, String userId2) {
//     return userId1.hashCode <= userId2.hashCode
//         ? '$userId1-$userId2'
//         : '$userId2-$userId1';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         surfaceTintColor: Colors.transparent,
//         backgroundColor: Colors.transparent,
//         title: FutureBuilder<DocumentSnapshot>(
//           future: _future,
//           builder:
//               (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
//             if (snapshot.hasData) {
//               DocumentSnapshot documentSnapshot = snapshot.data!;
//               if (documentSnapshot.exists) {
//                 Map<String, dynamic> data =
//                     documentSnapshot.data() as Map<String, dynamic>;
//                 profileData = data; // Menyimpan data profil untuk chat
//                 return Text(
//                   'Detail donasi dari ${data['name']}',
//                   overflow: TextOverflow.clip,
//                   softWrap: true,
//                 );
//               } else {
//                 return const Text('Donasi tidak ditemukan');
//               }
//             } else if (snapshot.hasError) {
//               return Text('Error: ${snapshot.error}');
//             } else {
//               return const Text('Memuat...');
//             }
//           },
//         ),
//       ),
//       body: FutureBuilder<DocumentSnapshot>(
//         future: _future,
//         builder:
//             (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
//           if (snapshot.hasData) {
//             DocumentSnapshot documentSnapshot = snapshot.data!;
//             if (documentSnapshot.exists) {
//               Map<String, dynamic> data =
//                   documentSnapshot.data() as Map<String, dynamic>;

//               List<String> images = List<String>.from(data['images'] ?? []);

//               return SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     if (images.isNotEmpty)
//                       Column(
//                         children: [
//                           CarouselSlider(
//                             options: CarouselOptions(
//                               height: 200,
//                               autoPlay: true,
//                               enlargeCenterPage: true,
//                               onPageChanged: (index, reason) {
//                                 setState(() {
//                                   _currentIndex = index;
//                                 });
//                               },
//                             ),
//                             items: images.map((url) {
//                               return Builder(
//                                 builder: (BuildContext context) {
//                                   return Image.network(url, fit: BoxFit.cover);
//                                 },
//                               );
//                             }).toList(),
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: images.map((url) {
//                               int index = images.indexOf(url);
//                               return Container(
//                                 width: 8.0,
//                                 height: 8.0,
//                                 margin: const EdgeInsets.symmetric(
//                                     vertical: 10.0, horizontal: 2.0),
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: _currentIndex == index
//                                       ? const Color(0xFF96B12D)
//                                       : const Color.fromRGBO(0, 0, 0, 0.4),
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                         ],
//                       ),
//                     Padding(
//                       padding: const EdgeInsets.all(24),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text('Nama Donatur',
//                               style: TextStyle(
//                                   fontSize: 18, fontWeight: FontWeight.bold)),
//                           Text(
//                             data['name'],
//                             style: const TextStyle(fontSize: 18),
//                             overflow: TextOverflow.visible,
//                             softWrap: true,
//                           ),
//                           const SizedBox(height: 18),
//                           const Text('No Hp',
//                               style: TextStyle(
//                                   fontSize: 18, fontWeight: FontWeight.bold)),
//                           Text(
//                             data['noHp'],
//                             style: const TextStyle(fontSize: 18),
//                             overflow: TextOverflow.visible,
//                             softWrap: true,
//                           ),
//                           const SizedBox(height: 18),
//                           const Text('Tanggal Donasi',
//                               style: TextStyle(
//                                   fontSize: 18, fontWeight: FontWeight.bold)),
//                           Text(
//                             data['date'],
//                             style: const TextStyle(fontSize: 18),
//                             overflow: TextOverflow.visible,
//                             softWrap: true,
//                           ),
//                           const SizedBox(height: 18),
//                           const Text('Cara Pengiriman',
//                               style: TextStyle(
//                                   fontSize: 18, fontWeight: FontWeight.bold)),
//                           Text(
//                             data['carapengiriman'],
//                             style: const TextStyle(fontSize: 18),
//                             overflow: TextOverflow.visible,
//                             softWrap: true,
//                           ),
//                           const SizedBox(height: 18),
//                           const Text('Drop Poin',
//                               style: TextStyle(
//                                   fontSize: 18, fontWeight: FontWeight.bold)),
//                           Text(
//                             data['dropPoints'],
//                             style: const TextStyle(fontSize: 18),
//                             overflow: TextOverflow.visible,
//                             softWrap: true,
//                           ),
//                           const SizedBox(height: 18),
//                           const Text('Keterangan',
//                               style: TextStyle(
//                                   fontSize: 18, fontWeight: FontWeight.bold)),
//                           Text(
//                             data['keterangan'],
//                             style: const TextStyle(fontSize: 18),
//                             overflow: TextOverflow.visible,
//                             softWrap: true,
//                           ),
//                           const SizedBox(height: 18),
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               const Text('Status',
//                                   style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold)),
//                               const SizedBox(
//                                 width: 10,
//                               ),
//                               Container(
//                                 alignment: Alignment.center,
//                                 padding: const EdgeInsets.only(
//                                     left: 15, right: 15, top: 3, bottom: 3),
//                                 decoration: BoxDecoration(
//                                   color: data['status'] == 'Menunggu'
//                                       ? Colors.yellow
//                                       : data['status'] == 'Diterima'
//                                           ? Colors.green
//                                           : Colors.red,
//                                   borderRadius: const BorderRadius.all(
//                                       Radius.circular(25)),
//                                 ),
//                                 child: Text(
//                                   data['status'],
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 18,
//                                       color: Colors.white),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 40),
//                           if (data['status'] != 'Diterima' &&
//                               data['status'] != 'Ditolak')
//                             Column(
//                               children: [
//                                 InkWell(
//                                   onTap: _confirmDonation,
//                                   child: Container(
//                                     alignment: Alignment.center,
//                                     width: double.infinity,
//                                     height: 40,
//                                     decoration: const BoxDecoration(
//                                       color: Color(0xFF96B12D),
//                                       borderRadius:
//                                           BorderRadius.all(Radius.circular(25)),
//                                     ),
//                                     child: const Text(
//                                       'Konfirmasi',
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 18,
//                                           color: Colors.white),
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 40),
//                                 TextField(
//                                   controller: _rejectionReasonController,
//                                   decoration: const InputDecoration(
//                                     labelText: 'Alasan Penolakan',
//                                     border: OutlineInputBorder(),
//                                   ),
//                                   maxLines: 3,
//                                 ),
//                                 const SizedBox(height: 20),
//                                 InkWell(
//                                   onTap: _rejectDonation,
//                                   child: Container(
//                                     alignment: Alignment.center,
//                                     width: double.infinity,
//                                     height: 40,
//                                     decoration: const BoxDecoration(
//                                       color: Colors.red,
//                                       borderRadius:
//                                           BorderRadius.all(Radius.circular(25)),
//                                     ),
//                                     child: const Text(
//                                       'Tolak',
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 18,
//                                           color: Colors.white),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20)
//                   ],
//                 ),
//               );
//             } else {
//               return const Center(child: Text('Donasi tidak ditemukan'));
//             }
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else {
//             return const Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _openChat,
//         child: const Icon(Icons.chat),
//       ),
//     );
//   }
// }