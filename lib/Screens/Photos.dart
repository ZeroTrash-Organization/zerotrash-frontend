
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zerotrash/Screens/Register.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:zerotrash/Globals/localhost.dart';
import 'package:zerotrash/Globals/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Globals/utils.dart';
import 'LocationDialogBox.dart';

class Photos extends StatelessWidget {
  const Photos({super.key});

  @override
  Widget build(BuildContext context) {
    return const PhotosPage();
  }
}

class PhotosPage extends StatefulWidget {
  const PhotosPage({Key? key}) : super(key: key);

  @override
  State<PhotosPage> createState() => _PhotosState();
}

class _PhotosState extends State<PhotosPage> {
  File? _image;
  final picker = ImagePicker();
  String? _prediction;
  bool isAnalyzed = false;

  String? modelUrl = Localhost.model;
  String? backend = Localhost.backend;

  String? latitude;
  String? longitude;

  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> analyzeImage() async {
    if (_image == null) {
      return;
    }

    String apiUrl = '$modelUrl:8000/analyze';

    print(apiUrl);


    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    print(response.body);

    // take 'category' from the response
    // set the state of _prediction to the category
    if (response.statusCode == 200) {
      setState(() {
        _prediction = jsonDecode(response.body)['category'];
        isAnalyzed = true;
      });
    } else {
      print('Failed to analyze image. Error: ${response.statusCode}');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyze Photos'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // add a dummy image from network
            // Image.network(
            //   'https://previews.123rf.com/images/vovashevchuk/vovashevchuk1512/vovashevchuk151200064/50242222-rusty-metal-garbage-dump-as-a-texture.jpg',
            //   width: 300,
            //   height: 300,
            //   fit: BoxFit.cover,
            // ),
            // SizedBox(height: 20),
            // // Header text
            Text(
              'Select an image to analyze',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // Display the image in a square container with padding only if an image is selected
            if (_image != null)
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(
                  _image!,
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),

            SizedBox(height: 20),
            Text(
              'Prediction: $_prediction',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // Display a button to analyze the image
            ElevatedButton(
              onPressed: _image != null
                  ? () {
                      analyzeImage();
                    }
                  : null,
              child: const Text('Analyze Image'),
            ),
            // display upload to server button if image is analyzed,otherwise disable it
            ElevatedButton(
              onPressed: isAnalyzed
                  ? () {

                _storeinDB(_prediction);
                    }
                  : null,
              child: const Text('Save to Database'),
            ),
            // discard the image and start over
            ElevatedButton(
              onPressed: _image != null
                  ? () {
                      setState(() {
                        _image = null;
                        isAnalyzed = false;
                      });
                    }
                  : null,
              child: const Text('Discard Image'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openCamera();
          // Add your onPressed code here!
        },
        child: const Icon(Icons.camera_alt, color: Colors.white),
        backgroundColor: Colors.green,
      ),
    );
  }

  void openCamera() {
    // show a dialog box to either open camera or choose from gallery with camera and image_picker plugin
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose an option'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    getImageFromCamera();
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    getImageFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // {
  //   "imageId": "create hash with userid and time",
  //   "category": "metal",
  //   "latitude": 40.71258,
  //   "longitude": -74.0060,
  //   "date": "2024-04-19"
  // }

  void _storeinDB(String? category) async {
    if (category == null) {
      return;
    }

    String? userId = FirebaseAuth.instance.currentUser!.uid;
    String? token = await FirebaseAuth.instance.currentUser!.getIdToken();

    if (userId == null || token == null) {
      return;
    }

    String apiUrl = '$backend:3000/saveimage';

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'imageId': generateImageId(userId),
        'category': category,
        'latitude': 40.71258,
        'longitude': -74.0060,
        'date': '2024-04-19',
      }),
    );

    if (response.statusCode == 200) {
      print('Image stored in database');
    } else {
      print('Failed to store image in database. Error: ${response.statusCode}');
    }
  }

  String generateImageId(String userId) {
    String imageId = '$userId${DateTime.now().millisecondsSinceEpoch}';
    print(imageId);
    return imageId;
  }





}
