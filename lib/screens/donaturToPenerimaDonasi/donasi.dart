import 'dart:io';
import 'package:anti/pustaka.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Donasi extends StatefulWidget {
  final String id;
  const Donasi({super.key, required this.id});

  @override
  _DonasiState createState() => _DonasiState();
}

class _DonasiState extends State<Donasi> {
  late Stream<DocumentSnapshot> _stream;
  late DocumentReference _reference;

  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerNoHp = TextEditingController();
  final TextEditingController _controllerDate = TextEditingController();
  final TextEditingController _controllerCaraPengiriman =
      TextEditingController();
  final TextEditingController _controllerKeterangan = TextEditingController();
  final DateTime _selectedDate = DateTime.now();
  GlobalKey<FormState> key = GlobalKey();

  final CollectionReference _referencee =
      FirebaseFirestore.instance.collection('donasi');

  @override
  void initState() {
    super.initState();
    _reference =
        FirebaseFirestore.instance.collection('profiles').doc(widget.id);
    _stream = _reference.snapshots();
    _fetchDropPointsOptions(widget.id);
  }

  List<XFile> selectedFiles = [];
  List<String> imageUrls = [];
  bool isLoading = false;
  List<Map<String, String>> dropPointsOptions = [];
  String _selectedDropPoint = '';

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: _selectedDate,
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _controllerDate.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("Uploading..."),
              ],
            ),
          ),
        );
      },
    );
  }

  void hideLoadingDialog(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> _pickImages(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? files = await picker.pickMultiImage();
    if (files != null) {
      setState(() {
        selectedFiles.addAll(files);
      });
    }
  }

  void _showEditImageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () async {
                    await _pickImages(ImageSource.gallery);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Ambil Foto'),
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? file =
                        await picker.pickImage(source: ImageSource.camera);
                    if (file != null) {
                      setState(() {
                        selectedFiles.add(file);
                      });
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchDropPointsOptions(String userId) async {
    final profileSnapshot = await FirebaseFirestore.instance
        .collection('profiles')
        .doc(userId)
        .get();
    final dropPoints = profileSnapshot.get('dropPoints');

    List<Map<String, String>> dropPointsNames = [];

    for (var point in dropPoints) {
      String name = point['name'];
      String location = point['location'];
      dropPointsNames.add({'name': name, 'location': location});
    }

    setState(() {
      dropPointsOptions = dropPointsNames;
      if (dropPointsOptions.isNotEmpty) {
        _selectedDropPoint = dropPointsOptions.first['name']!;
      }
    });
  }

  // Fungsi untuk membuat notifikasi
  Future<void> createNotification(
      String userId, String message, String donationId) async {
    Map<String, dynamic> notificationData = {
      'userId': userId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
      'donationId': donationId,
    };

    await FirebaseFirestore.instance
        .collection('notifications')
        .add(notificationData);
  }

  // Fungsi untuk mendengarkan perubahan status donasi
  void listenToDonationStatusChanges(String donationId) {
    FirebaseFirestore.instance
        .collection('donasi')
        .doc(donationId)
        .snapshots()
        .listen((documentSnapshot) {
      if (documentSnapshot.exists) {
        String status = documentSnapshot['status'];
        String donaturId = documentSnapshot['donaturId'];
        String message;

        if (status == 'Diterima') {
          message = 'Donasi Anda diterima';
        } else if (status == 'Menunggu') {
          message = 'Donasi Anda masih menunggu konfirmasi';
        } else if (status == 'Ditolak') {
          message = 'Donasi Anda ditolak';
        } else {
          message = 'Status donasi tidak dikenal';
        }

        createNotification(donaturId, message, donationId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: StreamBuilder<DocumentSnapshot>(
          stream: _stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              DocumentSnapshot documentSnapshot = snapshot.data;
              if (documentSnapshot.exists) {
                Map<String, dynamic> data =
                    documentSnapshot.data() as Map<String, dynamic>;
                return Text(
                  'Donasi ke ${data['nama']}',
                  overflow: TextOverflow.clip,
                  softWrap: true,
                );
              }
            }
            return const Text(
              'Donasi ke',
              overflow: TextOverflow.clip,
              softWrap: true,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding:
              const EdgeInsets.only(left: 24, right: 24, top: 10, bottom: 24),
          height: MediaQuery.of(context).size.height,
          child: Form(
            key: key,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // untuk menampilkan gambar
                SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        for (int index = 0;
                            index < selectedFiles.length;
                            index++)
                          Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 10),
                                height: 100,
                                width: 100,
                                child: Image.file(
                                  File(selectedFiles[index].path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.cancel,
                                      color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      selectedFiles.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        Container(
                          alignment: Alignment.center,
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            border: Border.all(
                              style: BorderStyle.solid,
                              color: const Color.fromARGB(255, 20, 20, 20),
                              width: 1.0,
                            ),
                          ),
                          child: IconButton(
                            onPressed: () {
                              _showEditImageBottomSheet(context);
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _controllerName,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  decoration: const InputDecoration(
                      hintText: 'Nama donatur',
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.black,
                      ))),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukan Nama';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _controllerNoHp,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  decoration: const InputDecoration(
                      hintText: 'No Hp',
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.black,
                      ))),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan No Hp';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _controllerDate,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  decoration: const InputDecoration(
                      hintText: 'Rencana tanggal donasi',
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.black,
                      ))),
                  onTap: () => _selectDate(context),
                  readOnly: true,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan rencana tgl donasi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _controllerCaraPengiriman,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  decoration: const InputDecoration(
                      hintText: 'Cara Pengiriman',
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.black,
                      ))),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan cara pengiriman';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedDropPoint,
                  items: dropPointsOptions.map((Map<String, String> option) {
                    return DropdownMenuItem<String>(
                      value: option['name'],
                      child: Text('${option['name']} : ${option['location']}'),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedDropPoint = value ?? '';
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Drop Point',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan Drop Point';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _controllerKeterangan,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  decoration: const InputDecoration(
                      hintText: 'Keterangan',
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.black,
                      ))),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukan keterangan';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                InkWell(
                  onTap: () async {
                    if (selectedFiles.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Silahkan masukkan gambar')));
                      return;
                    }

                    if (key.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      showLoadingDialog(context);

                      String itemName = _controllerName.text;
                      String itemNoHp = _controllerNoHp.text;
                      String itemDate = _controllerDate.text;
                      String itemCaraPengiriman =
                          _controllerCaraPengiriman.text;
                      String itemDroupPoin = _selectedDropPoint;
                      String itemKeterangan = _controllerKeterangan.text;
                      String userId = FirebaseAuth.instance.currentUser!.uid;

                      // Unggah gambar ke Firebase Storage
                      List<String> newImageUrls = [];
                      for (XFile file in selectedFiles) {
                        String documentId = _referencee.doc().id;
                        Reference referenceRoot =
                            FirebaseStorage.instance.ref();
                        Reference referenceDirImages =
                            referenceRoot.child('donasi');
                        Reference referenceImageToUpload =
                            referenceDirImages.child(documentId);

                        try {
                          await referenceImageToUpload.putFile(File(file.path));
                          String imageUrl =
                              await referenceImageToUpload.getDownloadURL();
                          newImageUrls.add(imageUrl);
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Error uploading image: $error')));
                        }
                      }

                      setState(() {
                        imageUrls = newImageUrls;
                      });

                      Map<String, dynamic> dataToSend = {
                        'userId': widget.id,
                        'donaturId': userId,
                        'name': itemName,
                        'noHp': itemNoHp,
                        'date': itemDate,
                        'carapengiriman': itemCaraPengiriman,
                        'dropPoints': itemDroupPoin,
                        'keterangan': itemKeterangan,
                        'images': imageUrls,
                        'timestamp': FieldValue.serverTimestamp(),
                        'status': 'Menunggu',
                      };

                      DocumentReference donationDoc =
                          await _referencee.add(dataToSend);

                      listenToDonationStatusChanges(donationDoc.id);

                      // Tambahkan notifikasi
                      Map<String, dynamic> notificationData = {
                        'userId': widget.id, // ID penerima donasi
                        'donaturId': userId, // ID donatur
                        'name': itemName,
                        'message': 'Anda menerima donasi baru.',
                        'timestamp': FieldValue.serverTimestamp(),
                        'donationId': donationDoc.id,
                      };

                      await FirebaseFirestore.instance
                          .collection('notifications')
                          .add(notificationData);

                      hideLoadingDialog(context);
                      await showModalBottomSheet(
                        context: context,
                        backgroundColor:
                            const Color.fromARGB(255, 223, 247, 202),
                        builder: (context) => Container(
                          height: 60,
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          child: const Center(
                            child: Text(
                              'Donasi berhasil di kirim, tunggu konfirmasi',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NavigationDonatur()),
                      );

                      setState(() {
                        _controllerName.clear();
                        _controllerNoHp.clear();
                        _controllerKeterangan.clear();
                        _controllerCaraPengiriman.clear();
                        _controllerDate.clear();
                        selectedFiles.clear();
                        imageUrls.clear();
                        isLoading = false;
                      });
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFF96B12D),
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    child: const Text(
                      'Donasikan',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
