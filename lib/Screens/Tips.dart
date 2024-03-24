import 'package:flutter/material.dart';

class TipsPage extends StatefulWidget {
  const TipsPage({Key? key}) : super(key: key);

  @override
  State<TipsPage> createState() => _TipsState();
}

class _TipsState extends State<TipsPage> {
  List<Map<String, String>> content = [
    {
      'link': "https://www.texasdisposal.com/blog/the-real-cost-of-littering/",
      'image':
          "https://images.unsplash.com/flagged/photo-1572213426852-0e4ed8f41ff6?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8cGxhc3RpYyUyMHdhc3RlfGVufDB8fDB8fHww",
      'title': "How Does Littering Affect the Environment?",
      'description':
          "Littering — or what littering means to us today — is actually a rather modern problem. It wasn’t until roughly the 1950s that manufacturers began producing a higher volume of litter-generating products and packaging made of materials like plastic."
    },
    {
      'link':
          "https://www.plastictides.org/plastics101/?gad_source=1&gclid=Cj0KCQjwqdqvBhCPARIsANrmZhOUFNZ7ScA_qksCVXkfsUeSdf3UZjlsLv5iMXgDvnM8qk58K2ImnkQaAisKEALw_wcB",
      'image':
          "https://images.unsplash.com/photo-1605600659908-0ef719419d41?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fHBsYXN0aWMlMjB3YXN0ZXxlbnwwfHwwfHx8MA%3D%3D",
      'title': "Our culture depends on single-use plastics. ",
      'description':
          "Stop reading and look up; is there any plastic around you? Water bottles, yogurt containers, the infamous six pack rings? Most plastic waste does not make it to the recycling center, or even the landfill. This plastic — carried by rivers, wind, and animals can find its way to the sea."
    },
    {
      'link':
          "https://www.unep.org/interactives/beat-plastic-pollution/?gad_source=1&gclid=Cj0KCQjwqdqvBhCPARIsANrmZhNgcb97WgBNMhaNFncH_UdpmyJoN6I03JdR1ID7EskHzRRU2U_gB_UaAtd-EALw_wcB",
      'image':
          "https://images.unsplash.com/photo-1621451749004-a06ae0616c44?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTV8fHBsYXN0aWMlMjB3YXN0ZXxlbnwwfHwwfHx8MA%3D%3D",
      'title': "Our planet is choking on plastic",
      'description':
          "While plastic has many valuable uses, we have become addicted to single-use plastic products — with severe environmental, social, economic and health consequences."
    },
    {
      'link':
          "https://lki.lk/blog/marine-plastic-pollution-opportunities-for-sri-lanka/",
      'image':
          "https://images.unsplash.com/photo-1617953141905-b27fb1f17d88?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MzV8fG1hcmluZSUyMHBsYXN0aWMlMjBwb2xsdXRpb258ZW58MHx8MHx8fDA%3D",
      'title': "Marine Plastic Pollution: Opportunities for Sri Lanka",
      'description':
          "The availability and affordability of plastic has had transformative effects on industries such as clothing, technology and transport. Since 1980, global plastic production is estimated to have accounted for 8.3 billion MT."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Educational Content'),
      ),
      body: ListView.builder(
        itemCount: content.length,
        itemBuilder: (BuildContext context, int index) {
          return TipCard(
            link: content[index]['link']!,
            image: content[index]['image']!,
            title: content[index]['title']!,
            description: content[index]['description']!,
          );
        },
      ),
    );
  }
}

class TipCard extends StatelessWidget {
  final String link;
  final String image;
  final String title;
  final String description;

  const TipCard({
    required this.link,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Open the provided link when tapped
        // You can use any suitable method to open the link, like launching a web view
        // Here, I'm using the built-in function launch() from the url_launcher package
        // Make sure to add url_launcher dependency in your pubspec.yaml file
        // Example: https://pub.dev/packages/url_launcher
        // import 'package:url_launcher/url_launcher.dart';
        // launch(link);
      },
      child: Card(
        margin: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0), // Adjust the value as needed
                topRight: Radius.circular(20.0), // Adjust the value as needed
              ),
              child: Image.network(
                image,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Read more',
                    style: TextStyle(
                      color: Colors.blue,
                      // Make the text appear blue for indicating it's a hyperlink
                      decoration: TextDecoration.underline,
                      // Add underline to indicate it's a hyperlink
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
