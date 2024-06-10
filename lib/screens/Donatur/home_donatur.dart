import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomeDonatur extends StatelessWidget {
  const HomeDonatur({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Postingan'),
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
                  title: Text('Data tidak ditemukan'),
                );
              }

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

                  return ListTile(
                    leading: profileData['profileImageUrl'] != null
                        ? Image.network(profileData['profileImageUrl'])
                        : const Icon(Icons.person),
                    title: Text(profileData['nama']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(postinganData['keterangan']),
                        Wrap(
                          children: (postinganData['images'] as List<dynamic>)
                              .map((url) {
                            return Image.network(url, width: 50, height: 50);
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
