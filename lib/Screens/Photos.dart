import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:zerotrash/Globals/localhost.dart';

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
  bool isLocationFetched = false;
  bool isImageUploaded = false;

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

  Future<Position?> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Open location settings if services are disabled
        await Geolocator.openLocationSettings();
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Request location permission if not granted
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          // Open location settings if permission is permanently denied
          await Geolocator.openLocationSettings();
        }
      }

      // If permission is denied forever, return error
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      // Get current position
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      // Handle any exceptions that might occur
      print('Error getting current location: $e');
      return null;
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
            Text(
              'Select an image to analyze',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
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
            ElevatedButton(
              onPressed: _image != null && !isAnalyzed
                  ? () {
                analyzeImage();
              }
                  : null,
              child: const Text('Analyze Image'),
            ),
            SizedBox(height: 20),

            Text(
              'Latitude: $latitude',
            ),
            SizedBox(width: 20),
            Text(
              'Longitude: $longitude',
            ),

            ElevatedButton(
              onPressed: isAnalyzed && !isLocationFetched
                  ? () {
                _getCurrentLocation().then((value) => {
                  setState(() {
                    latitude = value!.latitude.toString();
                    longitude = value.longitude.toString();
                    isLocationFetched = true;
                  })
                });
              }
                  : null,
              child: const Text('Get Location'),
            ),
            ElevatedButton(
              onPressed: isAnalyzed && isLocationFetched && !isImageUploaded
                  ? () {
                _storeinDB(_prediction);
              }
                  : null,
              child: const Text('Save to Database'),
            ),
            ElevatedButton(
              onPressed: _image != null && isAnalyzed && isLocationFetched
                  ? () {
                setState(() {
                  _image = null;
                  isAnalyzed = false;
                  isLocationFetched = false;
                  isImageUploaded = false;
                  latitude = null;
                  longitude = null;
                  _prediction = null;
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
        'latitude': latitude,
        'longitude': longitude,
        'date': DateTime.now().toString().substring(0, 10),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Image stored in database');
      _updateUserPoints();
    } else {
      print('Failed to store image in database. Error: ${response.statusCode}');
    }
  }

  String generateImageId(String userId) {
    String imageId = '$userId${DateTime.now().millisecondsSinceEpoch}';
    print(imageId);
    return imageId;
  }

  Future<void> _updateUserPoints() async {
    String? token = await FirebaseAuth.instance.currentUser!.getIdToken();
    String? userId = FirebaseAuth.instance.currentUser!.uid;

    if (token == null || userId == null) {
      return;
    }

    String apiUrl = '$backend:3000/user/addpoints';

    var response = await http.put(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'points': 10,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('User points updated');
    } else {
      print('Failed to update user points. Error: ${response.statusCode}');
    }
  }
}
