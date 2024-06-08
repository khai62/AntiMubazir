import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:anti/pustaka.dart';

class DonasiMasuk extends StatefulWidget {
  final String userId;

  const DonasiMasuk({super.key, required this.userId});

  @override
  State<DonasiMasuk> createState() => _DonasiMasukState();
}

class _DonasiMasukState extends State<DonasiMasuk> {
  final TextEditingController searchController = TextEditingController();
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('donasi');

  late Stream<QuerySnapshot> _stream;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _stream = _reference
        .where('userId', isEqualTo: widget.userId) // Filter berdasarkan userId
        .snapshots();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Donasi Masuk',
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
                    hintText: 'Temukan Donasi...',
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
                        Timestamp timestamp =
                            thisItem['timestamp'] as Timestamp;
                        DateTime dateTime = timestamp.toDate();

                        String timeAgo = getTimeAgo(dateTime);

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
                              const SizedBox(width: 20),
                              Expanded(
                                // Ensure that the Row's content can take the full available width
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Dari ${thisItem['name'] ?? 'No Name'}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            overflow: TextOverflow.clip,
                                            softWrap: true,
                                          ),
                                        ),
                                        Text(
                                          timeAgo,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color:
                                                Color.fromARGB(255, 17, 17, 17),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      _getShortText(
                                          thisItem['keterangan'] ?? ''),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            String userId = thisItem['userId'];
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DetailDonasiMasuk(
                                userId: userId,
                              ),
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

  String getTimeAgo(DateTime dateTime) {
    Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} hr yg lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jm yg lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min yg lalu';
    } else {
      return 'Baru saja';
    }
  }
}
