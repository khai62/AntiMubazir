import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

      if (savedPostsIds != null) {
        List<Map<String, dynamic>> savedPosts = [];
        for (String postId in savedPostsIds) {
          DocumentSnapshot postDoc = await FirebaseFirestore.instance
              .collection('postigan')
              .doc(postId)
              .get();
          savedPosts.add(postDoc.data() as Map<String, dynamic>);
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
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada postingan tersimpan'));
          } else {
            List<Map<String, dynamic>> savedPosts = snapshot.data!;
            return ListView.builder(
              itemCount: savedPosts.length,
              itemBuilder: (context, index) {
                var postinganData = savedPosts[index];
                return ListTile(
                  title: Text(postinganData['keterangan'] ?? 'No description'),
                  subtitle: postinganData['timestamp'] != null
                      ? Text(getTimeAgo(
                          (postinganData['timestamp'] as Timestamp).toDate()))
                      : null,
                );
              },
            );
          }
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
