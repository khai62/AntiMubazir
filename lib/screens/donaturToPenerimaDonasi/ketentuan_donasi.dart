import 'package:anti/pustaka.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class KetentuanDonasi extends StatefulWidget {
  final String id;

  const KetentuanDonasi({super.key, required this.id});

  @override
  // ignore: library_private_types_in_public_api
  _KetentuanDonasiState createState() => _KetentuanDonasiState();
}

class _KetentuanDonasiState extends State<KetentuanDonasi> {
  late Stream<DocumentSnapshot> _stream;

  bool agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance
        .collection('profiles')
        .doc(widget.id)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            StreamBuilder<DocumentSnapshot>(
              stream: _stream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Some error occurred ${snapshot.error}'),
                  );
                }

                if (snapshot.hasData) {
                  DocumentSnapshot documentSnapshot = snapshot.data!;
                  if (!documentSnapshot.exists) {
                    return const Center(
                      child: Text('Document does not exist'),
                    );
                  }
                  Map<String, dynamic> data =
                      documentSnapshot.data() as Map<String, dynamic>;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ketentuan Donasi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Terima kasih telah mempertimbangkan untuk berdonasi! Donasi Anda sangat berarti bagi kami dan akan membantu untuk mencapai tujuan kami. Sebelum Anda berdonasi, mohon baca dan pahami ketentuan berikut:',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        data['ketentuan'],
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CheckboxListTile(
                        value: agreedToTerms,
                        onChanged: (newValue) {
                          setState(() {
                            agreedToTerms = newValue!;
                          });
                        },
                        title: const Text("Saya menyetujui ketentuan donasi"),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              alignment: Alignment.center,
                              width: 160,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 190, 194, 175),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: const Text(
                                'Batal',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          InkWell(
                            onTap: agreedToTerms
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Donasi(
                                          id: data['userId'],
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            child: Container(
                              alignment: Alignment.center,
                              width: 160,
                              height: 40,
                              decoration: BoxDecoration(
                                color: agreedToTerms
                                    ? const Color(0xFF96B12D)
                                    : const Color(0xFF96B12D).withOpacity(0.5),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                              ),
                              child: const Text(
                                'Lanjut',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
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
}
