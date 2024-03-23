import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zerotrash/Globals/localhost.dart';
import 'package:zerotrash/Screens/Photos.dart';
import 'package:zerotrash/Screens/UserProfile.dart';
import 'package:provider/provider.dart';

import '../models/PatientModel.dart';
import '../models/PatientModelProvider.dart';
import '../models/userModel.dart';
import 'Events.dart';
import 'HeatMap.dart';
import 'LeaderBoard2.dart';
import 'Login.dart';
import 'Tips.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardPage();
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardState();
}

class _DashboardState extends State<DashboardPage> {
  List<Widget> allTabs = [
    const GoogleHeatMap(),
    const LeaderboardPage(),
    const PhotosPage(),
    const EventsPage(),
    const TipsPage(),
    const UserProfile(),
  ];
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
  }

  // search function with ID or Name

  //
  // void dummyPatients() {
  //   List<Patient> dummyPatient = [];
  //   for (int i = 0; i < 10; i++) {
  //     //random 10 random digits for single nic number string
  //     String nic = generateRandomNIC();
  //
  //     Patient patient = Patient(
  //       nic: nic,
  //       name: 'Patient $i',
  //       age: '30',
  //       telephone: '123456789',
  //       history: 'No significant medical history',
  //     );
  //     dummyPatient.add(patient);
  //   }
  //
  //   setState(() {
  //     patients = dummyPatient;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      // Bottom Nav with Heat Map, LeaderBoard, Camera (Main Icon), Events, Tips and Profile with white background and green color active icon
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        currentIndex: _selectedIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Heat Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'LeaderBoard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Analyze',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'Tips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.green,
      ),
      backgroundColor: Colors.white,
      body: allTabs[_selectedIndex],
    );
  }
}
