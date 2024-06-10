import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:anti/pustaka.dart';

class DetailPenerimaDonasi extends StatefulWidget {
  final String id;

  const DetailPenerimaDonasi({super.key, required this.id});

  @override
  // ignore: library_private_types_in_public_api
  _DetailPenerimaDonasiState createState() => _DetailPenerimaDonasiState();
}

class _DetailPenerimaDonasiState extends State<DetailPenerimaDonasi>
    with SingleTickerProviderStateMixin {
  late DocumentReference _reference;
  late Stream<DocumentSnapshot> _stream;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _reference =
        FirebaseFirestore.instance.collection('profiles').doc(widget.id);
    _stream = _reference.snapshots();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                    'Detail ${data['nama']}',
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
          )),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
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
                      return const Center(
                          child: Text('Document does not exist'));
                    }
                    Map<String, dynamic> data =
                        documentSnapshot.data() as Map<String, dynamic>;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 130,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
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
                        const SizedBox(
                          height: 20,
                        ),
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
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(40)),
                                child: (data.containsKey('profileImageUrl') &&
                                        data['profileImageUrl'] != null)
                                    ? (data['profileImageUrl'] is List &&
                                            data['profileImageUrl'].isNotEmpty)
                                        ? Image.network(
                                            '${data['profileImageUrl'][0]}',
                                            fit: BoxFit.cover,
                                          )
                                        : (data['profileImageUrl'] is String)
                                            ? Image.network(
                                                '${data['profileImageUrl']}',
                                                fit: BoxFit.cover,
                                              )
                                            : Container(color: Colors.grey)
                                    : Container(color: Colors.grey),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['nama'],
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                  overflow: TextOverflow.clip,
                                  softWrap: true,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  data['email'],
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        KetentuanDonasi(id: data['userId'])));
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
                              const PostinganSaya(),
                              TentangPenerimaDonasi(
                                id: data['userId'],
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
      ),
    );
  }
}
