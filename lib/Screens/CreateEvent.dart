import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

import 'package:file_picker/file_picker.dart';
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

  Future<void> _uploadtoFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final photoName = hashValues(_titleController.text, user.uid, DateTime.now().toString());
      final ref = storage.child('events/$photoName');
      await ref.putData(_image!);
      final url = await ref.getDownloadURL();
      setState(() {
        _imgUrlController.text = url;
      });
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
      final token = await user.getIdToken();
      final response = await http.post(
        Uri.parse('$baseUrl:3000/event'),
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
      if (response.statusCode == 200) {
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
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Date'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter date';
                }
                return null;
              },
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
                  _uploadtoFirestore();
                  print("Image URL: ${_imgUrlController.text}");
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
