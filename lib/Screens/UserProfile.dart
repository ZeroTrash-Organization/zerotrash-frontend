import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zerotrash/Globals/localhost.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({Key? key}) : super(key: key);

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

class userModel {
  final String name;
  final String email;
  final int points;
  final String rank;

  userModel({
    required this.name,
    required this.email,
    required this.points,
    required this.rank,
  });
}

class _UserProfileState extends State<UserProfilePage> {
  String? name;
  String? email;
  int? points;
  String? rank;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    // create a circular loading animation
    print("Loading user data");
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await user.getIdToken();

      final userDataResponse = await http.get(
        Uri.parse('${Localhost.backend}:3000/user'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      print(userDataResponse.body);

      if (userDataResponse.statusCode == 200) {
        final userData = jsonDecode(userDataResponse.body);
        setState(() {
          name = userData['username'];
          email = userData['email'];
          points = userData['points'];
        });
      } else {
        print('Failed to load user data');
      }

      final rankResponse = await http.get(
        Uri.parse('${Localhost.backend}:3000/user/rank'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      print(rankResponse.body);

      if (rankResponse.statusCode == 200) {
        final rankData = jsonDecode(rankResponse.body);
        setState(() {
          rank = rankData['rank'].toString();
        });
      } else {
        print('Failed to load user rank');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 16),
            if (name != null) Text('Name: $name'),
            if (email != null) Text('Email: $email'),
            if (points != null) Text('Points: $points'),
            if (rank != null) Text('Rank: $rank'),
          ],
        ),
      ),
    );
  }
}
