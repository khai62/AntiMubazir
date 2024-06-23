import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:anti/pustaka.dart'; // Pastikan Anda mengimport halaman detail postingan saya

class Tersimpan extends StatefulWidget {
  const Tersimpan({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TersimpanState createState() => _TersimpanState();
}

class _TersimpanState extends State<Tersimpan> {
  Future<List<Map<String, dynamic>>> _getSavedPosts() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      List<dynamic>? savedPostsIds = userDoc['savedPost'] as List<dynamic>?;

      if (savedPostsIds != null && savedPostsIds.isNotEmpty) {
        List<Map<String, dynamic>> savedPosts = [];
        for (var postId in savedPostsIds) {
          DocumentSnapshot postDoc = await FirebaseFirestore.instance
              .collection('postigan')
              .doc(postId)
              .get();
          var postData = postDoc.data();
          if (postData != null) {
            savedPosts.add({
              'postId': postDoc.id,
              ...postData as Map<String, dynamic>,
            });
          }
        }
        return savedPosts;
      } else {
        return [];
      }
    } else {
      throw Exception('User not logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getSavedPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('${snapshot.error}');
            return const Center(child: Text('Tidak ada postingan tersimpan'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada postingan tersimpan'));
          } else {
            List<Map<String, dynamic>> savedPosts = snapshot.data!;
            return StaggeredGridView.countBuilder(
              crossAxisCount: 6,
              itemCount: savedPosts.length,
              itemBuilder: (BuildContext context, int index) {
                var postinganData = savedPosts[index];
                var images = postinganData['images'] as List<dynamic>? ?? [];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailPostingan(postData: postinganData),
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
          }
        },
      ),
    );
  }
}

class DetailPostingan extends StatelessWidget {
  final Map<String, dynamic> postData;

  const DetailPostingan({super.key, required this.postData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(postData['keterangan'] ?? 'Detail Postingan'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (postData['images'] != null && postData['images'].isNotEmpty)
              Image.network((postData['images'] as List<dynamic>)[0]),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(postData['keterangan'] ?? 'No description'),
            ),
          ],
        ),
      ),
    );
  }
}
