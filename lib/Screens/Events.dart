import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:zerotrash/Globals/localhost.dart';
import 'package:intl/intl.dart';

import 'CreateEvent.dart';

class Events extends StatelessWidget {
  const Events({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const EventsPage();
  }
}

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsState();
}

// dummy event set made with event name, location, time, and image
// with 3 main columns. 1 featured events - horizontally scrollable cards. all events with 2 columns

class eventItem {
  final String name;
  final String location;
  final String time;
  final String image;

  eventItem({
    required this.name,
    required this.location,
    required this.time,
    required this.image,
  });
}

class _EventsState extends State<EventsPage> {
  // get user token from firebase
  late bool isOrganizer = false;
  List<eventItem> eventItems = [];
  List<eventItem> eventItemsDummy = [
    eventItem(
      name: "Beach Cleanup",
      location: "Galle Face",
      time: "10:00 AM",
      image:
      "https://greenfins.net/wp-content/uploads/2020/08/beach-cleanup-3.jpeg",
    ),
    eventItem(
      name: "River Cleanup",
      location: "Kelaniya",
      time: "11:00 AM",
      image:
      "https://www.ecowatch.com/wp-content/uploads/2022/07/GettyImages-1353301481-scaled.jpg",
    ),
    eventItem(
      name: "Park Cleanup",
      location: "Viharamahadevi Park",
      time: "12:00 PM",
      image:
      "https://a.storyblok.com/f/146790/1600x842/7ac33a43f1/how-to-organize-a-beach-clean-up-0.png",
    ),
    eventItem(
      name: "Beach Cleanup",
      location: "Galle Face",
      time: "10:00 AM",
      image:
      "https://www.jconnectseattle.org/wp-content/uploads/2021/08/beach-cleanup.jpg",
    ),
    eventItem(
      name: "River Cleanup",
      location: "Kelaniya",
      time: "11:00 AM",
      image:
      "https://greenfins.net/wp-content/uploads/2020/08/beach-cleanup-3.jpeg",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkOrganizer();
    _loadEvents();
  }

  Future<void> _checkOrganizer() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      final response = await http.get(
        Uri.parse('${Localhost.backend}:3000/user'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      final userData = jsonDecode(response.body);
      if (userData['role'] != null && userData['role'] == 'organizer') {
        setState(() {
          isOrganizer = true;
        });
      }
    }
  }
  Future<void> _loadEvents() async {
    try {
      final List<eventItem> fetchedEvents = await _getEventsFromDB();

      print(fetchedEvents);
      setState(() {
        eventItems = fetchedEvents;
      });
    } catch (error) {
      print('Error loading events: $error');
      // Handle error loading events
    }
  }

  Future<List<eventItem>> _getEventsFromDB() async {
    final response = await http.get(
      Uri.parse('${Localhost.backend}:3000/event/getevents'),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print(data);
      return data.map((e) {
        return eventItem(
          name: e['title'],
          location: e['location'],
          time: e['date'].toString().substring(0, 10),
          image: e['imgUrl'],
        );
      }).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }
  int index = 0;



  Widget _title() {
    return Text(
      eventItems[index].name,
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget _content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eventItems[index].location),
        Text(eventItems[index].time),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
      ),
      floatingActionButton: isOrganizer
          ? FloatingActionButton(
              backgroundColor: Colors.green,
              // go to CreateEventPage() page without routes
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateEventPage(),
                  ),
                );
              },

              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Featured Events',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 200.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: eventItems.length,
                itemBuilder: (context, index) {
                  final currentEvent =
                      eventItems[index]; // Fetch current event data
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 200.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: FillImageCard(
                        width: 200,
                        heightImage: 200,
                        imageProvider: NetworkImage(currentEvent.image),
                        // Set image URL
                        title: Text(
                          currentEvent.name, // Set event name
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        description: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentEvent.location,
                              style: TextStyle(color: Colors.white),
                            ),
                            // Set event location
                            Text(
                              currentEvent.time,
                              style: TextStyle(color: Colors.white),
                            ),
                            // Set event time
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(),
            // Add a divider between sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'All Events',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 1.0,
                mainAxisSpacing: 1.0,
                childAspectRatio: 1.0,
              ),
              itemCount: eventItems.length,
              itemBuilder: (context, index) {
                final currentEvent =
                    eventItems[index]; // Fetch current event data
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FillImageCard(
                    width: 200,
                    heightImage: 200,
                    imageProvider: NetworkImage(currentEvent.image),
                    // Set image URL
                    title: Text(
                      currentEvent.name, // Set event name
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    description: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentEvent.location,
                          style: TextStyle(color: Colors.white),
                        ), // Set event location
                        Text(
                          currentEvent.time,
                          style: TextStyle(color: Colors.white),
                        ), // Set event time
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FillImageCard extends StatelessWidget {
  final double width;
  final double heightImage;
  final ImageProvider imageProvider;
  final Widget title;
  final Widget description;

  const FillImageCard({
    Key? key,
    required this.width,
    required this.heightImage,
    required this.imageProvider,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Stack(
        children: [
          Container(
            width: width,
            height: heightImage,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            width: width,
            height: heightImage,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.black
                  .withOpacity(0.5), // Add opacity to darken the image
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  title,
                  SizedBox(height: 4.0),
                  description,
                  SizedBox(height: 8.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
