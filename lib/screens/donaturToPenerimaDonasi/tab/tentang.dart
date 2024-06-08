import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TentangPenerimaDonasi extends StatefulWidget {
  final String id;

  const TentangPenerimaDonasi({super.key, required this.id});

  @override
  // ignore: library_private_types_in_public_api
  _TentangPenerimaDonasiState createState() => _TentangPenerimaDonasiState();
}

class _TentangPenerimaDonasiState extends State<TentangPenerimaDonasi>
    with SingleTickerProviderStateMixin {
  late DocumentReference _reference;
  late Stream<DocumentSnapshot> _stream;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _reference =
        FirebaseFirestore.instance.collection('profiles').doc(widget.id);
    _stream = _reference.snapshots();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            StreamBuilder<DocumentSnapshot>(
              stream: _stream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Some error occurred ${snapshot.error}'));
                }

                if (snapshot.hasData) {
                  DocumentSnapshot documentSnapshot = snapshot.data;
                  if (!documentSnapshot.exists) {
                    return const Center(child: Text('Document does not exist'));
                  }
                  Map<String, dynamic> data =
                      documentSnapshot.data() as Map<String, dynamic>;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRow(Icons.person, data['nama']),
                      const SizedBox(
                        height: 20,
                      ),
                      _buildRow(Icons.info, data['tentang']),
                      const SizedBox(
                        height: 20,
                      ),
                      _buildRow(Icons.location_on, data['alamat']),
                      const SizedBox(
                        height: 20,
                      ),
                      _buildRow(Icons.phone, data['noHp']),
                      const SizedBox(
                        height: 20,
                      ),
                      _buildRow(Icons.email, data['email']),
                      const SizedBox(
                        height: 20,
                      ),
                      _buildRow(Icons.rule, data['ketentuan']),
                      const SizedBox(height: 20),
                      if (data.containsKey('dropPoints')) ...[
                        const Text(
                          'Drop Points:',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        for (var dropPoint in data['dropPoints'])
                          _buildDropPoint(dropPoint),
                      ],
                    ],
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

  Widget _buildRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            text ?? '-',
            style: const TextStyle(fontSize: 18, color: Colors.black),
            overflow: TextOverflow.visible,
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDropPoint(Map<String, dynamic> dropPoint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.business),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                dropPoint['name'] ?? '-',
                style: const TextStyle(fontSize: 18, color: Colors.black),
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Icon(Icons.location_on),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                dropPoint['location'] ?? '-',
                style: const TextStyle(fontSize: 18, color: Colors.black),
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
            ),
          ],
        ),
        const Divider(),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }
}
