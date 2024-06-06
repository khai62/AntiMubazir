import 'dart:io';
import 'package:anti/pustaka.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerDescription = TextEditingController();
  final TextEditingController _controllerPrice = TextEditingController();
  final TextEditingController _controllerDiscount = TextEditingController();
  final TextEditingController _controllerQuantity = TextEditingController();
  final TextEditingController _controllerDate = TextEditingController();
  final TextEditingController _controllerStartTime = TextEditingController();
  final TextEditingController _controllerEndTime = TextEditingController();

  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  GlobalKey<FormState> key = GlobalKey();

  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('produk');

  List<XFile> selectedFiles = [];
  List<String> imageUrls = [];
  bool isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _controllerDate.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedStartTime = pickedTime;
        _controllerStartTime.text = _selectedStartTime!.format(context);
        // Reset _selectedEndTime to ensure end time is always after start time
        if (_selectedEndTime != null &&
            _compareTimeOfDay(_selectedEndTime!, _selectedStartTime!)) {
          _selectedEndTime = _selectedStartTime;
          _controllerEndTime.text = _selectedEndTime!.format(context);
        }
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      if (_selectedStartTime != null &&
          _compareTimeOfDay(pickedTime, _selectedStartTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('End time cannot be before start time'),
        ));
      } else {
        setState(() {
          _selectedEndTime = pickedTime;
          _controllerEndTime.text = _selectedEndTime!.format(context);
        });
      }
    }
  }

  bool _compareTimeOfDay(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour < time2.hour) {
      return true;
    } else if (time1.hour == time2.hour && time1.minute < time2.minute) {
      return true;
    }
    return false;
  }

  String formatCurrency(String value) {
    final number = double.tryParse(value.replaceAll('.', ''));
    if (number == null) return value;
    final formatCurrency = NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: 0,
    );
    return formatCurrency.format(number);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Jual',
          style: TextStyle(
              fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
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
                const SizedBox(
                  height: 20,
                ),
                // untuk menampilkan gambar
                SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    scrollDirection:
                        Axis.horizontal, // Mengatur scroll menjadi horizontal
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
                              ImagePicker imagePicker = ImagePicker();
                              List<XFile>? files =
                                  await imagePicker.pickMultiImage();

                              if (files.isEmpty) return;

                              setState(() {
                                selectedFiles.addAll(files);
                              });
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),

                TextFormField(
                  controller: _controllerName,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  decoration: const InputDecoration(
                      hintText: 'Nama ',
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.black,
                      ))),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the product name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _controllerDescription,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  decoration: const InputDecoration(
                      hintText: 'Deskripsi',
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.black,
                      ))),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the product description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _controllerPrice,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      hintText: 'Harga',
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.black,
                      ))),
                  onChanged: (value) {
                    setState(() {
                      _controllerPrice.text = formatCurrency(value);
                      _controllerPrice.selection = TextSelection.fromPosition(
                        TextPosition(offset: _controllerPrice.text.length),
                      );
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the product price';
                    }
                    if (double.tryParse(value.replaceAll('.', '')) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _controllerDiscount,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      hintText: 'Diskon',
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.black,
                      ))),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the discount percentage';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _controllerQuantity,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      hintText: 'Jumlah',
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.black,
                      ))),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the quantity available';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _controllerDate,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  decoration: const InputDecoration(
                      hintText: 'Tanggal berakhir',
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.black,
                      ))),
                  onTap: () => _selectDate(context),
                  readOnly: true,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the date available';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _controllerStartTime,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Jam mulai',
                    enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                      color: Colors.black,
                    )),
                    suffixIcon: IconButton(
                      onPressed: () => _selectStartTime(context),
                      icon: const Icon(Icons.access_time),
                    ),
                  ),
                  readOnly: true,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the start time';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: _controllerEndTime,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Jam berakhir',
                    enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                      color: Colors.black,
                    )),
                    suffixIcon: IconButton(
                      onPressed: () => _selectEndTime(context),
                      icon: const Icon(Icons.access_time),
                    ),
                  ),
                  readOnly: true,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the end time';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
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
                      String itemDescription = _controllerDescription.text;
                      String itemPrice = _controllerPrice.text;
                      String itemDiscount = _controllerDiscount.text;
                      String itemQuantity = _controllerQuantity.text;
                      String itemDate = _controllerDate.text;
                      String itemStartTime = _controllerStartTime.text;
                      String itemEndTime = _controllerEndTime.text;
                      String userId = FirebaseAuth.instance.currentUser!.uid;

                      // Unggah gambar ke Firebase Storage
                      List<String> newImageUrls = [];
                      for (XFile file in selectedFiles) {
                        String documentId = _reference.doc().id;
                        Reference referenceRoot =
                            FirebaseStorage.instance.ref();
                        Reference referenceDirImages =
                            referenceRoot.child('images');
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
                        'name': itemName,
                        'description': itemDescription,
                        'price': itemPrice,
                        'discount': itemDiscount,
                        'quantity': itemQuantity,
                        'date': itemDate,
                        'startTime': itemStartTime,
                        'endTime': itemEndTime,
                        'images': imageUrls,
                      };

                      await _reference.add(dataToSend);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Item added successfully')));

                      hideLoadingDialog(context);

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NavigationDonatur()));

                      setState(() {
                        _controllerName.clear();
                        _controllerDescription.clear();
                        _controllerPrice.clear();
                        _controllerDiscount.clear();
                        _controllerQuantity.clear();
                        _controllerDate.clear();
                        _controllerStartTime.clear();
                        _controllerEndTime.clear();
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
      ),
    );
  }
}
