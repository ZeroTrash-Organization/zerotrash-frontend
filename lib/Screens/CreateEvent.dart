import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:zerotrash/Globals/localhost.dart';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';

import '../Globals/utils.dart';

class CreateEvent extends StatelessWidget {
  const CreateEvent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CreateEventPage();
  }
}

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({Key? key}) : super(key: key);

  @override
  State<CreateEventPage> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEventPage> {
  Uint8List? _image;

  final storage = FirebaseStorage.instance.ref();


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _dateController.text) {
      setState(() {
        // Format the picked date to display only the date
        _dateController.text = picked.toString().substring(0, 10);
      });
    }
  }

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  void takePicture() async {
    Uint8List img = await pickImage(ImageSource.camera);
    setState(() {
      _image = img;
    });
  }

  // upload to firestore and store the image path in firebase as _imageURL
  // stored in a folder called /events/{photo_name}
  // photo_name is a hashed value of event name, user id and date

// Modify the _uploadtoFirestore() method
  Future<void> _uploadtoFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final photoName = hashValues(_titleController.text, user.uid, DateTime.now().toString());
      final ref = storage.child('events/$photoName');

      // Get the file extension from the image picker
      String extension = _image != null ? getImageExtension() : '';

      // convert the _image bytes to an image file
      final metadata = SettableMetadata(
        contentType: 'image/$extension', // Set the correct content type based on the file extension
        customMetadata: <String, String>{'event': _titleController.text},
      );

      // Upload image data to Firebase Storage
      await ref.putData(_image!, metadata);

      // Retrieve the download URL and set it to the controller
      final url = await ref.getDownloadURL();
      setState(() {
        _imgUrlController.text = url; // Set download URL
      });
      print("Image URL: $url"); // Print the download URL
    }
  }

// Function to get the image extension
  String getImageExtension() {
    final List<int> headerBytes = _image!.sublist(0, 10); // Read first 10 bytes to determine the file type

    // Check for common image file signatures
    if (headerBytes[0] == 0x89 && headerBytes[1] == 0x50 && headerBytes[2] == 0x4E && headerBytes[3] == 0x47 &&
        headerBytes[4] == 0x0D && headerBytes[5] == 0x0A && headerBytes[6] == 0x1A && headerBytes[7] == 0x0A) {
      return 'png'; // PNG file signature
    } else if (headerBytes[0] == 0xFF && headerBytes[1] == 0xD8) {
      return 'jpg'; // JPEG file signature
    } else if (headerBytes[0] == 0x47 && headerBytes[1] == 0x49 && headerBytes[2] == 0x46) {
      return 'gif'; // GIF file signature
    } else if (headerBytes[0] == 0x42 && headerBytes[1] == 0x4D) {
      return 'bmp'; // BMP file signature
    } else {
      return 'jpg'; // Default to JPEG if signature is not recognized
    }
  }

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _imgUrlController = TextEditingController();

  String? baseUrl = Localhost.backend;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _createEvent() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      print("User is there");
      final token = await user.getIdToken();
      print(token);

      String? Url = '$baseUrl:3000/event/create';

      print(Url);

      // add a loading circular indicator when creating an event
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );


      await _uploadtoFirestore();

      print(_titleController.text);
      print(_locationController.text);
      print(_dateController.text);
      print(_imgUrlController.text);


      final response = await http.post(
        Uri.parse(Url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{
          'title': _titleController.text,
          'location': _locationController.text,
          'date': _dateController.text,
          'imgUrl': _imgUrlController.text,
        }),
      );

      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event created successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create event'),
          ),
        );
      }
    }

    // go back to the previous screen
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter title';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter location';
                }
                return null;
              },
            ),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(labelText: 'Date'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                ),
              ),
            ),
            SizedBox(height: 20),

            if (_image != null)
              Image.memory(
                _image!,
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
            if (_image == null)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: selectImage,
                icon: const Icon(Icons.image,
                  color: Colors.white,),
                label: const Text('Select Image'),
              ),
            SizedBox(height: 20),

            const SizedBox(height: 16),
            ElevatedButton(
              style : ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _createEvent();
                }
              },
              child: const Text('Create Event',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
