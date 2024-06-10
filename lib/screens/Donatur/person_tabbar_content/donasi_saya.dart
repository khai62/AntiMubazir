import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:anti/pustaka.dart'; // Pastikan import sesuai dengan struktur proyek Anda

class DonasiSaya extends StatefulWidget {
  final String userId;

  const DonasiSaya({super.key, required this.userId});

  @override
  State<DonasiSaya> createState() => _DonasiSayaState();
}

class _DonasiSayaState extends State<DonasiSaya> {
  final TextEditingController searchController = TextEditingController();
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('donasi');

  late Stream<QuerySnapshot> _stream;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _stream =
        _reference.where('donaturId', isEqualTo: widget.userId).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      Timestamp timestamp = thisItem['timestamp'] as Timestamp;
                      DateTime dateTime = timestamp.toDate();

                      String timeAgo = getTimeAgo(dateTime);

                      return GestureDetector(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 130,
                              width: 130,
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5)),
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
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${thisItem['keterangan'] ?? 'No Name'}',
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
                                    _getShortText(thisItem['status'] ?? ''),
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
                          String donationId = thisItem['id'];
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => DetailDonasiSaya(
                              donationId: donationId,
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
