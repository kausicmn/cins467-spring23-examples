import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddPhoto extends StatefulWidget {
  const AddPhoto({super.key, required this.title});

  final String title;

  @override
  State<AddPhoto> createState() => _AddPhotoState();
}

class _AddPhotoState extends State<AddPhoto> {
  File? _image;
  Position? _position;
  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  void initState() {
    super.initState();
    _determinePosition().then((value) => setState(() {
          _position = value;
        }));
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void _getImage() async {
    final ImagePicker _picker = ImagePicker();
    // Capture a photo
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
      } else {
        if (kDebugMode) {
          print("No image picked");
        }
      }
    });
  }

  void _upload() async {
    if (_image == null) {
      return;
    }
    if (myController.text == "") {
      return;
    }
    if (_position == null) {
      return;
    }
    var uuid = const Uuid();
    final String uuidString = uuid.v4();
    final String downloadUrl = await uploadFile(uuidString);
    await _addItem(downloadUrl, myController.text, uuidString);
    if (kDebugMode) {
      print(uuidString);
    }
    Navigator.pop(context);
  }

  Future<String> uploadFile(String filename) async {
    // Create a Reference to the file
    Reference ref = FirebaseStorage.instance.ref().child('$filename.jpg');
    final SettableMetadata metadata =
        SettableMetadata(contentType: 'image/jpeg', contentLanguage: 'en');

    // Upload the file to firebase
    UploadTask uploadTask = ref.putFile(_image!, metadata);

    // Waits till the file is uploaded then stores the download url
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    if (kDebugMode) {
      print(downloadUrl);
    }
    return downloadUrl;
  }

  Future<void> _addItem(String downloadURL, String title, String uid) async {
    await FirebaseFirestore.instance.collection('photos').add({
      'downloadURL': downloadURL,
      'title': title,
      'geopoint': GeoPoint(_position!.latitude, _position!.longitude),
      'uid': uid,
      'author': FirebaseAuth.instance.currentUser!.uid,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Column(
          children: [
            _image != null
                ? Image.file(_image!)
                : const Text("No image selected"),
            TextField(
              controller: myController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: "Title of the photo"),
            ),
            ElevatedButton(
              onPressed: _upload,
              child: const Text("Submit"),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _getImage,
          tooltip: 'Take Photo',
          child: const Icon(Icons.add_a_photo),
        ));
  }
}
