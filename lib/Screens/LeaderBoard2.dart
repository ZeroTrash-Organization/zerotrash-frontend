import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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

  List<userItem> userItems = [
    userItem(
      rank: "1",
      image: "https://static.dc.com/dc/files/default_images/Char_Profile_Batman_20190116_5c3fc4b40faec2.47318964.jpg",
      name: "Johnny Rios",
      point: 23131,
    ),
    userItem(
      rank: "2",
      image: "https://static.dc.com/dc/files/default_images/Char_Profile_Batman_20190116_5c3fc4b40faec2.47318964.jpg",
      name: "Hodges",
      point: 12323,
    ),
    userItem(
      rank: "3",
      image: "https://static.dc.com/dc/files/default_images/Char_Profile_Batman_20190116_5c3fc4b40faec2.47318964.jpg",
      name: "loram",
      point: 6343,
    ),
    userItem(
      rank: "4",
      image: "https://static.dc.com/dc/files/default_images/Char_Profile_Batman_20190116_5c3fc4b40faec2.47318964.jpg",
      name: "Hodges",
      point: 12323,
    ),
    userItem(
      rank: "5",
      image: "https://static.dc.com/dc/files/default_images/Char_Profile_Batman_20190116_5c3fc4b40faec2.47318964.jpg",
      name: "loram",
      point: 6343,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
              height: 100.0
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
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final items = userItems[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                          right: 20, left: 20, bottom: 15),
                      child: Row(
                        children: [
                          Text(
                            items.rank,
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
                            backgroundImage: AssetImage(items.image),
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
                                    color: Color.fromARGB(255, 255, 187, 0),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  items.point.toString(),
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
          const Positioned(
            top: 120,
            left: 10,
            child: Text(
              "Ens in 2d 23Hours",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
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
                image: "Images/g.jpeg",
                name: "Johnny Rios",
                point: "23131"),
          ),
          // for rank 2nd
          Positioned(
            top: 240,
            left: 45,
            child: rank(
                radius: 30.0,
                height: 10,
                image: "Images/k.jpeg",
                name: "Hodges",
                point: "12323"),
          ),
          // For 3rd rank
          Positioned(
            top: 263,
            right: 50,
            child: rank(
                radius: 30.0,
                height: 10,
                image: "Images/j.jpeg",
                name: "loram",
                point: "6343"),
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
          backgroundImage: AssetImage(image),
        ),
        SizedBox(
          height: height,
        ),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(
          height: height,
        ),
        Container(
          height: 25,
          width: 70,
          decoration: BoxDecoration(
              color: Colors.black54, borderRadius: BorderRadius.circular(50)),
          child: Row(
            children: [
              const SizedBox(
                width: 5,
              ),
              const Icon(
                Icons.back_hand,
                color: Color.fromARGB(255, 255, 187, 0),
              ),
              const SizedBox(
                width: 5,
              ),
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
  final String image;
  final String name;
  final int point;

  userItem({
    required this.rank,
    required this.image,
    required this.name,
    required this.point,
  });
}
