import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


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

  // Large title called Leaderboard
  // Golden bordered square for the 1st. With name and points
  // Silver bordered square for the 2nd. With name and points
  // Bronze bordered square for the 3rd. With name and points
  // rest with name and points and grey borders
  // bottom bar called your rank if not in top 5

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: 100.0,
            child: Center(
              child: Text(
                "Leaderboard",
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: ListView.builder(
              itemCount: userItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: index == 0
                            ? Colors.amber
                            : index == 1
                            ? Colors.grey
                            : index == 2
                            ? Colors.brown
                            : Colors.grey,
                        width: 3.0,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: ListTile(
                      leading: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: index == 0
                                ? AssetImage("assets/gold.webp")
                                : index == 1
                                ? AssetImage("assets/silver.webp")
                                : AssetImage("assets/bronze.webp"),
                          ),
                          CircleAvatar(
                            backgroundImage: NetworkImage(userItems[index].image),
                          ),
                        ],
                      ),
                      title: Text(userItems[index].name),
                      trailing: Text(
                          userItems[index].point.toString(),
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: index == 0
                                ? Colors.amber
                                : index == 1
                                ? Colors.grey
                                : index == 2
                                ? Colors.brown
                                : Colors.grey,
                          )
                      )
                    ),
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 50.0,
              color: Colors.grey,
              child: Center(
                child: Text(
                  "Your Rank",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}