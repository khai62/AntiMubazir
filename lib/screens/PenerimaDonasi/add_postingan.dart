import 'dart:io';
import 'package:anti/pustaka.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPostingan extends StatefulWidget {
  const AddPostingan({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddPostinganState createState() => _AddPostinganState();
}

class _AddPostinganState extends State<AddPostingan> {
  final TextEditingController _controllerName = TextEditingController();
  GlobalKey<FormState> key = GlobalKey();
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('postigan');
  List<XFile> selectedFiles = [];
  List<String> imageUrls = [];
  bool isLoading = false;

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

  Future<void> _showBottomSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.camera),
                  title: const Text('Ambil Foto dari Kamera'),
                  onTap: () async {
                    Navigator.pop(context);
                    XFile? file = await ImagePicker()
                        .pickImage(source: ImageSource.camera);
                    if (file != null) {
                      setState(() {
                        selectedFiles.add(file);
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text('Pilih Foto dari Galeri'),
                  onTap: () async {
                    Navigator.pop(context);
                    List<XFile>? files = await ImagePicker().pickMultiImage();
                    if (files.isNotEmpty) {
                      setState(() {
                        selectedFiles.addAll(files);
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Posting',
          style: TextStyle(
              fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        padding:
            const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 30),
        height: MediaQuery.of(context).size.height,
        child: Form(
          key: key,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
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
                              onPressed: () async {
                                await _showBottomSheet(context);
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
                      hintText: 'Tuliskan keterangan...',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    minLines: 1,
                  ),
                ],
              ),
              InkWell(
                onTap: () async {
                  if (selectedFiles.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Please upload at least one image')));
                    return;
                  }

                  if (key.currentState!.validate()) {
                    setState(() {
                      isLoading = true;
                    });
                    showLoadingDialog(context);

                    String itemName = _controllerName.text;
                    String userId = FirebaseAuth.instance.currentUser!.uid;

                    List<String> newImageUrls = [];
                    for (XFile file in selectedFiles) {
                      String documentId = _reference.doc().id;
                      Reference referenceRoot = FirebaseStorage.instance.ref();
                      Reference referenceDirImages =
                          referenceRoot.child('postinganimage');
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
                      'userId': userId,
                      'keterangan': itemName,
                      'images': imageUrls,
                    };

                    await _reference.add(dataToSend);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('berhasil membuat postingan')));

                    hideLoadingDialog(context);

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const NavigationPenerimaDonasi()));

                    setState(() {
                      _controllerName.clear();
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
                    'Upload',
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
    );
  }
}
