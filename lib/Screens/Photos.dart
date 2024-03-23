
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zerotrash/Screens/Register.dart';

import '../Globals/utils.dart';

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
  Uint8List? _image;
  bool isAnalyzed = true;

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
            Image.network(
              'https://previews.123rf.com/images/vovashevchuk/vovashevchuk1512/vovashevchuk151200064/50242222-rusty-metal-garbage-dump-as-a-texture.jpg',
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            // Header text
            Text(
              "Category: ${isAnalyzed ? 'Metal' : 'Metal'}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // Display the image in a square container with padding only if an image is selected
            if (_image != null)
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Image.memory(
                  _image!,
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),

            SizedBox(height: 20),
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
                      // Add your onPressed code here!
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
                    takePicture();
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    selectImage();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void analyzeImage() {
    // Add your analyze image code here!
    setState(() {
      isAnalyzed = true;
    });
  }
}
