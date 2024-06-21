import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:anti/pustaka.dart'; // Pastikan Anda mengimport halaman detail postingan saya

class PostinganSaya extends StatefulWidget {
  const PostinganSaya({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PostinganSayaState createState() => _PostinganSayaState();
}

class _PostinganSayaState extends State<PostinganSaya> {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('User belum login'),
      );
    }

    String currentUserId = user.uid;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('postigan')
            .where('userId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada postingan ditemukan'));
          }

          var postinganDocs = snapshot.data!.docs;

          // Log untuk memeriksa apakah postinganDocs berisi data yang diharapkan
          print('Jumlah postingan: ${postinganDocs.length}');

          return StaggeredGridView.countBuilder(
            crossAxisCount: 6,
            itemCount: postinganDocs.length,
            itemBuilder: (BuildContext context, int index) {
              var postinganDoc = postinganDocs[index];
              var postinganData = postinganDoc.data() as Map<String, dynamic>?;

              if (postinganData == null) {
                // Log jika postinganData null
                print('postinganData null di index: $index');
                return const SizedBox.shrink();
              }

              var images = postinganData['images'] as List<dynamic>? ?? [];

              // Log untuk memeriksa apakah ada gambar dalam postingan
              print('Jumlah gambar di postingan ke-$index: ${images.length}');

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailPostinganSaya(postId: postinganDoc.id),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.grey[200],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (images.isNotEmpty)
                        Image.network(
                          images[0],
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width,
                          height: 150,
                        )
                      else
                        Container(
                          height: 150,
                          color: Colors.grey,
                          child: const Center(
                            child: Text('Tidak ada gambar'),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
            staggeredTileBuilder: (int index) => const StaggeredTile.fit(2),
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
          );
        },
      ),
    );
  }
}
