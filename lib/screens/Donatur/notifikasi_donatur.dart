import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anti/pustaka.dart'; // Pastikan impor halaman detail yang benar

class NotifikasiDonatur extends StatefulWidget {
  final String userId;

  const NotifikasiDonatur({super.key, required this.userId});

  @override
  State<NotifikasiDonatur> createState() => _NotifikasiDonaturState();
}

class _NotifikasiDonaturState extends State<NotifikasiDonatur> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Notifikasi'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada notifikasi'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              Timestamp timestamp = data['timestamp'] as Timestamp;
              DateTime dateTime = timestamp.toDate();

              String timeAgo = getTimeAgo(dateTime);

              return ListTile(
                subtitle: Text(data['message'] ?? 'Pesan Notifikasi'),
                trailing: Text(timeAgo),
                onTap: () {
                  String donationId = data['donationId'];
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => DetailDonasiSaya(
                      donationId: donationId,
                    ),
                  ));
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  String getTimeAgo(DateTime dateTime) {
    Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }
}
