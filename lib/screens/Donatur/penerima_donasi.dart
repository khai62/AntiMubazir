import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:anti/pustaka.dart';

class PenerimaDonasi extends StatefulWidget {
  const PenerimaDonasi({super.key});

  @override
  State<PenerimaDonasi> createState() => _PenerimaDonasiState();
}

class _PenerimaDonasiState extends State<PenerimaDonasi> {
  final TextEditingController searchController = TextEditingController();
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('profiles');

  late Stream<QuerySnapshot> _stream;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _stream = _reference.snapshots();
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
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 24, right: 24, top: 50, bottom: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Penerima Donasi',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                height: 43,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 235, 236, 235),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: TextField(
                  onChanged: updateSearchQuery,
                  controller: searchController,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(
                    decoration: TextDecoration.none,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: (() {
                              clearSearchQuery();
                              clearSearchText();
                            }),
                          )
                        : null,
                    border: InputBorder.none,
                    hintText: 'Temukan Penerima Donasi...',
                  ),
                ),
              ),
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
                        .where((item) => item['nama']
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()))
                        .toList();

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 20);
                      },
                      itemCount: filteredItems.length,
                      itemBuilder: (BuildContext context, int index) {
                        Map<String, dynamic> thisItem = filteredItems[index];

                        return GestureDetector(
                          child: Row(
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
                                  child: (thisItem
                                              .containsKey('profileImageUrl') &&
                                          thisItem['profileImageUrl'] != null)
                                      ? (thisItem['profileImageUrl'] is List &&
                                              thisItem['profileImageUrl']
                                                  .isNotEmpty)
                                          ? Image.network(
                                              '${thisItem['profileImageUrl'][0]}',
                                              fit: BoxFit.cover,
                                            )
                                          : (thisItem['profileImageUrl']
                                                  is String)
                                              ? Image.network(
                                                  '${thisItem['profileImageUrl']}',
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
                                    '${thisItem['nama']}',
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
                                    _getShortText(thisItem['tentang']),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ],
                              )
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  DetailPenerimaDonasi(id: thisItem['id']),
                            ));
                          },
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
      ),
    );
  }

  String _getShortText(String text, {int maxLength = 20}) {
    if (text.length > maxLength) {
      return '${text.substring(0, maxLength)}...';
    } else {
      return text;
    }
  }
}
