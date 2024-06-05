import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class Notifikasi extends StatefulWidget {
  const Notifikasi({super.key});

  @override
  _NotifikasiState createState() => _NotifikasiState();
}

class _NotifikasiState extends State<Notifikasi> {
  final String _apiKey = '2c96cb8ed2c7441f9bd770cbb3d9b0bf';

  Future<String> _getAddressFromLatLng(
      double latitude, double longitude) async {
    final url =
        'https://api.opencagedata.com/geocode/v1/json?q=$latitude+$longitude&key=$_apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        return data['results'][0]['formatted'];
      } else {
        return 'No address found';
      }
    } else {
      return 'Failed to get address';
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Saved Locations'),
        ),
        body: const Center(
          child: Text('Please log in to see your saved locations.'),
        ),
      );
    }

    print('Current User UID: ${user.uid}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Locations'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('locations')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('No locations found for this user.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final latitude = doc['latitude'];
              final longitude = doc['longitude'];
              return FutureBuilder(
                future: _getAddressFromLatLng(latitude, longitude),
                builder: (context, AsyncSnapshot<String> addressSnapshot) {
                  if (!addressSnapshot.hasData) {
                    return const ListTile(
                      title: Text('Loading address...'),
                    );
                  }
                  return ListTile(
                    title: Text(addressSnapshot.data!),
                    subtitle: Text('Lat: $latitude, Lng: $longitude'),
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
