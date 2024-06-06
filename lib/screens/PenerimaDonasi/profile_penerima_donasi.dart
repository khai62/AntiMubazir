import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfilePenerimaDonasi extends StatefulWidget {
  const ProfilePenerimaDonasi({super.key});

  @override
  State<ProfilePenerimaDonasi> createState() => _ProfilePenerimaDonasiState();
}

class _ProfilePenerimaDonasiState extends State<ProfilePenerimaDonasi> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _noHpController = TextEditingController();
  final _alamatController = TextEditingController();
  final _tentangController = TextEditingController();
  final _ketentuanController = TextEditingController();
  List<DropPoint> dropPoints = [];

  File? _bannerImage;
  File? _profileImage;
  String? _bannerImageUrl;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    addDropPoint();
    _loadProfileData();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
    DocumentSnapshot profileData = await FirebaseFirestore.instance
        .collection('profiles')
        .doc('profileId')
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

      if (_bannerImage != null) {
        bannerImageUrl = await _uploadImage(_bannerImage!);
      }

      if (_profileImage != null) {
        profileImageUrl = await _uploadImage(_profileImage!);
      }

      await saveDropPoints();
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc('profileId')
          .set({
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form data saved successfully')),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onTap: () => _pickImage(ImageSource.gallery, true),
                      child: Container(
                        width: double.infinity,
                        height: 130,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 201, 199, 199),
                          borderRadius: BorderRadius.circular(20),
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
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: GestureDetector(
                        onTap: () => _pickImage(ImageSource.gallery, true),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -50,
                      left: 135,
                      child: GestureDetector(
                        onTap: () => _pickImage(ImageSource.gallery, false),
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
                      controller: _namaController,
                      decoration:
                          const InputDecoration(labelText: 'Nama yayasan'),
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    TextFormField(
                      controller: _noHpController,
                      decoration: const InputDecoration(labelText: 'No Hp'),
                      keyboardType: TextInputType.phone,
                    ),
                    TextFormField(
                      controller: _alamatController,
                      decoration: const InputDecoration(
                        labelText: 'Alamat',
                        suffixIcon: Icon(Icons.location_pin),
                      ),
                    ),
                    TextFormField(
                      controller: _tentangController,
                      decoration:
                          const InputDecoration(labelText: 'Tentang yayasan'),
                      maxLines: 3,
                    ),
                    TextFormField(
                      controller: _ketentuanController,
                      decoration: const InputDecoration(
                          labelText: 'Ketentuan donasi untuk donatur'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    const Text('Drop Points:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
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
                                  decoration:
                                      const InputDecoration(labelText: 'Name'),
                                ),
                                TextFormField(
                                  controller:
                                      dropPoints[index].locationController,
                                  decoration: const InputDecoration(
                                      labelText: 'Location'),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
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
                      onPressed: addDropPoint,
                      child: const Text('Add Drop Point'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: saveForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
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
