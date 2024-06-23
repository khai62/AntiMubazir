import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePenerimaDonasi extends StatefulWidget {
  const ProfilePenerimaDonasi({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePenerimaDonasiState createState() => _ProfilePenerimaDonasiState();
}

class _ProfilePenerimaDonasiState extends State<ProfilePenerimaDonasi> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController();
  final _alamatController = TextEditingController();
  final _tentangController = TextEditingController();
  final _ketentuanController = TextEditingController();
  List<DropPoint> dropPoints = [];

  File? _bannerImage;
  File? _profileImage;
  String? _bannerImageUrl;
  String? _profileImageUrl;
  bool _isProfileComplete = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = getUserId(); // Dapatkan user ID saat inisialisasi
    addDropPoint();
    _loadProfileData();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _alamatController.dispose();
    _tentangController.dispose();
    _ketentuanController.dispose();
    for (var dropPoint in dropPoints) {
      dropPoint.nameController.dispose();
      dropPoint.locationController.dispose();
    }
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    if (_userId == null) return; // Pastikan user ID tidak null
    DocumentSnapshot profileData = await FirebaseFirestore.instance
        .collection('profiles')
        .doc(_userId) // Menggunakan user ID sebagai dokumen ID
        .get();
    if (profileData.exists) {
      _namaController.text = profileData['nama'];
      _emailController.text = profileData['email'];
      _noHpController.text = profileData['noHp'];
      _alamatController.text = profileData['alamat'];
      _tentangController.text = profileData['tentang'];
      _ketentuanController.text = profileData['ketentuan'];
      _bannerImageUrl = profileData['bannerImageUrl'];
      _profileImageUrl = profileData['profileImageUrl'];

      List<dynamic> fetchedDropPoints = profileData['dropPoints'];
      for (var dp in fetchedDropPoints) {
        dropPoints.add(DropPoint(
          name: dp['name'],
          location: dp['location'],
        ));
      }

      // Cek apakah profil sudah lengkap
      if (_namaController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _noHpController.text.isNotEmpty &&
          _alamatController.text.isNotEmpty &&
          _tentangController.text.isNotEmpty &&
          _ketentuanController.text.isNotEmpty) {
        _isProfileComplete = true;
      } else {
        _isProfileComplete = false;
      }

      setState(() {});
    }
  }

  Future<void> _pickImage(ImageSource source, bool isBanner) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isBanner) {
          _bannerImage = File(pickedFile.path);
        } else {
          _profileImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    String fileName = image.path.split('/').last;
    Reference storageReference =
        FirebaseStorage.instance.ref().child('profileImages/$fileName');
    UploadTask uploadTask = storageReference.putFile(image);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
    return await snapshot.ref.getDownloadURL();
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

  Future<void> saveDropPoints() async {
    for (DropPoint dropPoint in dropPoints) {
      await FirebaseFirestore.instance.collection('dropPoints').add({
        'name': dropPoint.nameController.text,
        'location': dropPoint.locationController.text,
      });
    }
  }

  Future<void> saveForm() async {
    if (_formKey.currentState!.validate()) {
      String? bannerImageUrl;
      String? profileImageUrl;

      try {
        showLoadingDialog(context); // Menampilkan loading dialog

        if (_bannerImage != null) {
          bannerImageUrl = await _uploadImage(_bannerImage!);
        }

        if (_profileImage != null) {
          profileImageUrl = await _uploadImage(_profileImage!);
        }

        await saveDropPoints();

        await FirebaseFirestore.instance
            .collection('profiles')
            .doc(_userId) // Menggunakan user ID sebagai dokumen ID
            .set({
          'userId': _userId,
          'nama': _namaController.text,
          'email': _emailController.text,
          'noHp': _noHpController.text,
          'alamat': _alamatController.text,
          'tentang': _tentangController.text,
          'ketentuan': _ketentuanController.text,
          'bannerImageUrl': bannerImageUrl ?? _bannerImageUrl,
          'profileImageUrl': profileImageUrl ?? _profileImageUrl,
          'dropPoints': dropPoints
              .map((dp) => {
                    'name': dp.nameController.text,
                    'location': dp.locationController.text,
                  })
              .toList(),
        });

        _isProfileComplete = true;

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form data saved successfully')),
        );
      } finally {
        Navigator.pop(context); // Menutup loading dialog
      }
    }
  }

  void addDropPoint() {
    setState(() {
      dropPoints.add(DropPoint());
    });
  }

  void removeDropPoint(int index) {
    setState(() {
      dropPoints.removeAt(index);
    });
  }

  void _showEditBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _namaController,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  decoration: const InputDecoration(
                      labelText:
                          'Nama yayasan/ organisasi / penerima donasi/ organisasi / penerima donasi',
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.black,
                      ))),
                ),
                TextField(
                  controller: _emailController,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.black,
                      ))),
                ),
                TextField(
                  controller: _noHpController,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  decoration: const InputDecoration(
                      labelText: 'No Hp',
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.black,
                      ))),
                ),
                TextField(
                  controller: _alamatController,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  decoration: const InputDecoration(
                      labelText: 'Alamat',
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.black,
                      ))),
                ),
                TextField(
                  controller: _tentangController,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  decoration: const InputDecoration(
                      labelText: 'Tentang yayasan',
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.black,
                      ))),
                ),
                TextField(
                  controller: _ketentuanController,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  decoration: const InputDecoration(
                      labelText: 'Ketentuan donasi untuk donatur',
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.black,
                      ))),
                ),
                const SizedBox(height: 50),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: 40,
                    decoration: const BoxDecoration(
                        color: Color(0xFF96B12D),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: const Text(
                      'Simpan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditDropPointBottomSheet(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: dropPoints[index].nameController,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                      color: Colors.black,
                    )),
                  ),
                ),
                TextField(
                  controller: dropPoints[index].locationController,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                      color: Colors.black,
                    )),
                  ),
                ),
                const SizedBox(height: 50),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: 40,
                    decoration: const BoxDecoration(
                        color: Color(0xFF96B12D),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: const Text(
                      'Simpan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditImageBottomSheet(BuildContext context, bool isBanner) {
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
                  onTap: () {
                    _pickImage(ImageSource.gallery, isBanner);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Ambil Foto'),
                  onTap: () {
                    _pickImage(ImageSource.camera, isBanner);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _showEditImageBottomSheet(context, true),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 130,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        color: Colors.grey,
                        image: _bannerImageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_bannerImageUrl!),
                                fit: BoxFit.cover,
                              )
                            : _bannerImage != null
                                ? DecorationImage(
                                    image: FileImage(_bannerImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                      ),
                      child: _bannerImageUrl == null && _bannerImage == null
                          ? const Center(child: Icon(Icons.camera_alt))
                          : null,
                    ),
                    Positioned(
                      bottom: -50,
                      left: 140,
                      child: GestureDetector(
                        onTap: () => _showEditImageBottomSheet(context, false),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 159, 168, 122),
                            shape: BoxShape.circle,
                            image: _profileImageUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(_profileImageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : _profileImage != null
                                    ? DecorationImage(
                                        image: FileImage(_profileImage!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                          ),
                          child:
                              _profileImageUrl == null && _profileImage == null
                                  ? const Center(child: Icon(Icons.camera_alt))
                                  : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 80,
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      controller: _namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama yayasan/ organisasi / penerima donasi',
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.black,
                        )),
                      ),
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.black,
                        )),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    TextFormField(
                      controller: _noHpController,
                      decoration: const InputDecoration(
                        labelText: 'No Hp',
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.black,
                        )),
                      ),
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    TextFormField(
                      controller: _alamatController,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: 'Alamat',
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.black,
                        )),
                      ),
                    ),
                    TextFormField(
                      controller: _tentangController,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: 'Tentang yayasan',
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.black,
                        )),
                      ),
                      maxLines: 3,
                    ),
                    TextFormField(
                      controller: _ketentuanController,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: 'Ketentuan donasi untuk donatur',
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.black,
                        )),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    const Text('Drop Points:',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dropPoints.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: dropPoints[index].nameController,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black),
                                  decoration: const InputDecoration(
                                    labelText: 'Name',
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Colors.black,
                                    )),
                                  ),
                                ),
                                TextFormField(
                                  controller:
                                      dropPoints[index].locationController,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black),
                                  decoration: const InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.black,
                                      )),
                                      labelText: 'Location'),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                        onPressed: addDropPoint,
                                        icon: const Icon(Icons.add)),
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        if (dropPoints.length > 1) {
                                          removeDropPoint(index);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: saveForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        backgroundColor: const Color(0xFF96B12D),
                      ),
                      child: const Text(
                        'Simpan',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DropPoint {
  TextEditingController nameController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  DropPoint({String? name, String? location}) {
    if (name != null) {
      nameController.text = name;
    }
    if (location != null) {
      locationController.text = location;
    }
  }
}

String? getUserId() {
  final User? user = FirebaseAuth.instance.currentUser;
  return user?.uid;
}
