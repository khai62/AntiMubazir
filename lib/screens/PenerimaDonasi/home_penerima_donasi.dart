import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:anti/pustaka.dart';

class HomePenerimaDonasi extends StatefulWidget {
  final String postId;

  const HomePenerimaDonasi({super.key, required this.postId});

  @override
  _HomePenerimaDonasiState createState() => _HomePenerimaDonasiState();
}

class _HomePenerimaDonasiState extends State<HomePenerimaDonasi> {
  int _currentIndex = 0;

  Future<void> savePost(String postId) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'savedPost': FieldValue.arrayUnion([postId])
        });

        showModalBottomSheet(
          context: context,
          builder: (context) {
            return const SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Berhasil disimpan',
                      textAlign: TextAlign.center,
                    )),
              ),
            );
          },
        );
      } catch (e) {
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return SafeArea(
                  child: Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Gagal menyimpan posingan: $e',
                      textAlign: TextAlign.center,
                    )),
              ));
            });
      }
    } else {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return const SafeArea(
                child: Padding(
              padding: EdgeInsets.all(24),
              child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Gagal menyimpan postingan',
                    textAlign: TextAlign.center,
                  )),
            ));
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: const Text('Postingan',
            style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('postigan').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var postinganDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: postinganDocs.length,
            itemBuilder: (context, index) {
              var postinganDoc = postinganDocs[index];
              var postinganData = postinganDoc.data() as Map<String, dynamic>?;
              if (postinganData == null) {
                return const ListTile(
                  title: Text('Postingan tidak ditemukan'),
                );
              }

              Timestamp timestamp = postinganDoc['timestamp'] as Timestamp;
              DateTime dateTime = timestamp.toDate();
              String timeAgo = getTimeAgo(dateTime);

              String userId = postinganData['userId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('profiles')
                    .doc(userId)
                    .get(),
                builder: (context, profileSnapshot) {
                  if (!profileSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var profileData =
                      profileSnapshot.data!.data() as Map<String, dynamic>?;

                  if (profileData == null) {
                    return const ListTile(
                      title: Text('Profil tidak ditemukan'),
                    );
                  }

                  var images = postinganData['images'] as List<dynamic>? ?? [];

                  return Column(
                    children: [
                      ListTile(
                        leading: profileData['profileImageUrl'] != null
                            ? SizedBox(
                                height: 50,
                                child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(25)),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DetailPenerimaDonasi(
                                                    id: userId),
                                          ),
                                        );
                                      },
                                      child: Image.network(
                                        profileData['profileImageUrl'],
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                              )
                            : const Icon(Icons.person),
                        title: Text(
                          profileData['nama'],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          timeAgo,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(255, 17, 17, 17),
                          ),
                        ),
                      ),
                      if (images.isNotEmpty)
                        images.length == 1
                            ? Image.network(
                                images[0],
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width,
                                height: 200,
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CarouselSlider(
                                    options: CarouselOptions(
                                      height: 200,
                                      autoPlay: true,
                                      enlargeCenterPage: true,
                                      viewportFraction: 1.0,
                                      onPageChanged: (index, reason) {
                                        setState(() {
                                          _currentIndex = index;
                                        });
                                      },
                                    ),
                                    items: images.map((url) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return Image.network(
                                            url,
                                            fit: BoxFit.cover,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                          );
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
                                              : const Color.fromRGBO(
                                                  0, 0, 0, 0.4),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.favorite_border_outlined),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.comment_bank_outlined),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.save_outlined),
                            onPressed: () async {
                              await savePost(postinganDoc.id);
                            },
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (postinganData['keterangan'] != null)
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: ExpandableText(
                                  postinganData['keterangan'],
                                  expandText: 'Baca Selengkapnya',
                                  collapseText: 'Sembunyikan',
                                  maxLines: 2,
                                  linkColor: Colors.blue,
                                ),
                              )
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String getTimeAgo(DateTime dateTime) {
    Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} j';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min';
    } else {
      return 'Baru saja';
    }
  }
}
