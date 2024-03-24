import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../Globals/localhost.dart';

class Leaderboard extends StatelessWidget {
  const Leaderboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const LeaderboardPage();
  }

}

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  State<LeaderboardPage> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<LeaderboardPage> {
  List<String> userAvatars =[
    "https://uxwing.com/wp-content/themes/uxwing/download/peoples-avatars/man-user-circle-icon.png",
    "https://cdn-icons-png.freepik.com/512/4128/4128349.png",
    "https://uxwing.com/wp-content/themes/uxwing/download/peoples-avatars/woman-user-circle-icon.png",
  "https://cdn.esquimaltmfrc.com/wp-content/uploads/2015/09/flat-faces-icons-circle-woman-3.png"];


  late List<userItem> userItems = [
  ];

  @override
  void initState() {
    _loadLeaderboard();
    super.initState();
  }

  Future<void> _loadLeaderboard() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await user.getIdToken();

      final userDataResponse = await http.get(
        Uri.parse('${Localhost.backend}:3000/leaderboard'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      print(userDataResponse.body);

      if (userDataResponse.statusCode == 200) {
        // parse the response into a list of userItems
        final List<dynamic> data = jsonDecode(userDataResponse.body);
        List<userItem> loadedUserItems = data.map((e) => userItem(
          rank: e['rank'].toString() ?? "",
          name: e['username'] ?? "",
          points: e['points'] != null ? e['points'].toString() : "",
        )).toList();

        setState(() {
          userItems = loadedUserItems;
        });

        print("Leaderboard data loaded");
        print(userItems.first);
      } else {
        print("Failed to load leaderboard data");
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: 100.0,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height / 1.9,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: userItems.isEmpty
                  ? Center(
                child: CircularProgressIndicator(), // Show circular progress indicator while loading
              )
                  : ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: userItems.length,
                  itemBuilder: (context, index) {
                    final items = userItems[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                          right: 20, left: 20, bottom: 15),
                      child: Row(
                        children: [
                          Text(
                            (index + 1).toString(), // Display index + 1 as rank
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(
                                userAvatars[Random()
                                    .nextInt(userAvatars.length)]),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Text(
                            items.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            height: 25,
                            width: 70,
                            decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(50)),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 5,
                                ),
                                const RotatedBox(
                                  quarterTurns: 1,
                                  child: Icon(
                                    Icons.back_hand,
                                    color:
                                    Color.fromARGB(255, 255, 187, 0),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  items.points,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  }),
            ),
          ),
          const Positioned(
            top: 70,
            right: 150,
            child: Text(
              "Leaderboard",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Rank 1st
          Positioned(
            top: 140,
            right: 165,
            child: rank(
              radius: 45.0,
              height: 25,
              image:
              "https://www.pngitem.com/pimgs/m/101-1011777_clip-art-1st-place-medal-clipart-hd-png.png",
              name: userItems.isEmpty ? '' : userItems[0].name,
              point: userItems.isEmpty ? '' : userItems[0].points,
            ),
          ),
          // for rank 2nd
          Positioned(
            top: 240,
            left: 45,
            child: rank(
              radius: 30.0,
              height: 10,
              image:
              "https://i.pinimg.com/originals/3a/8d/bc/3a8dbc67fd6e3c7e2d64b2de2d176b6a.png",
              name: userItems.length < 2 ? '' : userItems[1].name,
              point: userItems.length < 2 ? '' : userItems[1].points,
            ),
          ),
          // For 3rd rank
          Positioned(
            top: 263,
            right: 50,
            child: rank(
              radius: 30.0,
              height: 10,
              image:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQP-0B9-C7gmqhmpAXDHO_uOF40EYz2bgrosnQzNNXrvX8uncRJfIslibXP1NBnAylCq-Q&usqp=CAU",
              name: userItems.length < 3 ? '' : userItems[2].name,
              point: userItems.length < 3 ? '' : userItems[2].points,
            ),
          ),
        ],
      ),
    );
  }


  Column rank({
    required double radius,
    required double height,
    required String image,
    required String name,
    required String point,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundImage: NetworkImage(image),
        ),
        SizedBox(
          height: height,
        ),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Container(
          height: 25,
          width: 70,
          decoration: BoxDecoration(
              color: Colors.black54, borderRadius: BorderRadius.circular(50)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                point,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class userItem {
  final String rank;
  final String name;
  final String points;

  userItem({
    required this.rank,
    required this.name,
    required this.points,
  });
}
