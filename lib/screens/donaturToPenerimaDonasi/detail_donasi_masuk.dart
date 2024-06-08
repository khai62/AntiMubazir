import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailDonasiMasuk extends StatefulWidget {
  final String userId;

  const DetailDonasiMasuk({super.key, required this.userId});

  @override
  State<DetailDonasiMasuk> createState() => _DetailDonasiMasukState();
}

class _DetailDonasiMasukState extends State<DetailDonasiMasuk> {
  final TextEditingController searchController = TextEditingController();
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('donasi');

  late Stream<QuerySnapshot> _stream;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _stream = _reference.where('userId', isEqualTo: widget.userId).snapshots();
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  void clearSearchQuery() {
    setState(() {
      searchQuery = "";
    });
  }

  void clearSearchText() {
    searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: StreamBuilder<QuerySnapshot>(
          stream: _stream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              QuerySnapshot querySnapshot = snapshot.data!;
              if (querySnapshot.docs.isNotEmpty) {
                DocumentSnapshot documentSnapshot = querySnapshot.docs
                    .first; // Ambil dokumen pertama atau sesuai logika Anda
                Map<String, dynamic> data =
                    documentSnapshot.data() as Map<String, dynamic>;
                return Text(
                  'Detail donasi dari ${data['name']}',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: _stream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Some error occurred ${snapshot.error}'));
                }

                if (snapshot.hasData) {
                  QuerySnapshot querySnapshot = snapshot.data;
                  List<QueryDocumentSnapshot> documents = querySnapshot.docs;

                  List<Map<String, dynamic>> items = documents.map((e) {
                    Map<String, dynamic> data =
                        e.data() as Map<String, dynamic>;
                    data['id'] = e.id;
                    return data;
                  }).toList();

                  List<Map<String, dynamic>> filteredItems = items
                      .where((item) =>
                          item['name'] != null &&
                          item['name']
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()))
                      .toList();

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 20),
                    itemCount: filteredItems.length,
                    itemBuilder: (BuildContext context, int index) {
                      Map<String, dynamic> thisItem = filteredItems[index];

                      return GestureDetector(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 200,
                              width: double.infinity,
                              child: ClipRRect(
                                child: (thisItem.containsKey('images') &&
                                        thisItem['images'] != null)
                                    ? (thisItem['images'] is List &&
                                            thisItem['images'].isNotEmpty)
                                        ? Image.network(
                                            '${thisItem['images'][0]}',
                                            fit: BoxFit.cover,
                                          )
                                        : (thisItem['images'] is String)
                                            ? Image.network(
                                                '${thisItem['images']}',
                                                fit: BoxFit.cover,
                                              )
                                            : Container(color: Colors.grey)
                                    : Container(color: Colors.grey),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Nama',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    _buildRow(thisItem['name']),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const Text(
                                      'No Hp',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    _buildRow(thisItem['noHp']),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const Text(
                                      'Keterangan',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    _buildRow(thisItem['keterangan']),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const Text(
                                      'Tanggal donasi',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    _buildRow(thisItem['date']),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const Text(
                                      'Cara pengiriman',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    _buildRow(thisItem['carapengiriman']),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const Text(
                                      'Dikirim ke drop poin',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    _buildRow(thisItem['dropPoints']),
                                    const SizedBox(height: 20),
                                  ],
                                )),
                          ],
                        ),
                      );
                    },
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
            overflow: TextOverflow.visible,
            softWrap: true,
          ),
        ),
      ],
    );
  }
}
