import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Globals/localhost.dart';
import '../models/userModel.dart';
import 'Login.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return const UserProfilePage();
  }
}

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfilePage> {
  UserModel user = UserModel(
    userId: "",
    therapistId: "",
    name: "",
    email: "",
    telephone: "",
    workplace: "",
  );

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  void _loadUserDetails() async {
    try {
      user = await getUserDetails();
      setState(() {
        user = user;
      });
    } catch (e) {
      // Handle error (e.g., display an error message)
      print('Error loading user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildTitleSubtitlePair("Username", "${user.therapistId}"),
          buildTitleSubtitlePair("Name", "${user.name}"),
          buildTitleSubtitlePair("Email", "${user.email}"),
          buildTitleSubtitlePair("Rank", "${user.telephone}"),
          buildTitleSubtitlePair("Role", "${user.workplace}"),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Confirm Delete"),
                    content:
                    // you will lose all your data including patients and voice samples
                        Text("Are you sure you want to delete your account? This will delete all your data including patients and voice samples."),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                        },
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: deleteuser,
                        child: Text("Delete"),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text("Deactivate Account",
                style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              // low saturated red for background
              backgroundColor: Colors.red[100],
              foregroundColor: Colors.red,
              // make the button big
              minimumSize: Size(200, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0),
              ),
            ),
          )
        ],
      ),
    );
  }

  // delete user function with delete firebase account, and call backend /deleteuser
  void deleteuser() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    // get token from Auth instance
    String? token = await FirebaseAuth.instance.currentUser!.getIdToken();

    // get localhost
    String localhost = Localhost.localhost;

    // Make the HTTP request
    var response = await http.delete(
      Uri.parse('$localhost:3000/deleteuser'),
      headers: {'Authorization': 'Bearer $token'},
    );

    Navigator.pop(context); // Close the dialog

    if (response.statusCode == 200) {
      // user is deleted successfully from backend

      // delete user from firebase
      FirebaseAuth.instance.currentUser!.delete();

      // navigate to login page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Login(),
        ),
      );

      // give bottom alert saying user deleted
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User deleted'),
        ),
      );
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load user details');
    }
  }
}

Future<UserModel> getUserDetails() async {
  // get token from Auth instance
  String? token = await FirebaseAuth.instance.currentUser!.getIdToken();

  print(token);

  // get localhost
  String localhost = Localhost.localhost;

  // Make the HTTP request
  var response = await http.get(
    Uri.parse('$localhost:3000/user'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    // If the server returns a 200 OK response,
    // parse the JSON
    Map<String, dynamic> jsonResponse = json.decode(response.body);

    // Create a user model
    UserModel user = UserModel(
      userId: jsonResponse['user_id'],
      therapistId: jsonResponse['therapist_id'],
      name: jsonResponse['name'],
      email: jsonResponse['email'],
      telephone: jsonResponse['telephone'],
      workplace: jsonResponse['workplace'],
    );

    // Now you can use the 'user' object as needed
    print(user.name);
    return user;
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load user details');
  }
}

Widget buildTitleSubtitlePair(String topic, String data) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(20),
    child: Column(
      children: [
        Text(
          topic,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          data,
          style: TextStyle(fontSize: 24),
        ),
      ],
    ),
  );
}
