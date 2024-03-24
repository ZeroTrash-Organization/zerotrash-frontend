import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import '../Globals/localhost.dart';

class HeatMap extends StatelessWidget {
  const HeatMap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const GoogleHeatMap();
  }
}

class GoogleHeatMap extends StatefulWidget {
  const GoogleHeatMap({Key? key}) : super(key: key);

  @override
  State<GoogleHeatMap> createState() => _GoogleHeatMapState();
}

class _GoogleHeatMapState extends State<GoogleHeatMap> {
  late List<Marker> markerData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('${Localhost.backend}:3000/getimageheat'),);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        markerData = data.map((item) {
          final LatLng latLng = LatLng(item['latitude'], item['longitude']);
          final String category = item['category'];
          Color markerColor = Colors.red; // Default color
          // Assign different colors based on category
          if (category == 'Plastic') {
            markerColor = Colors.blue;
          } else if (category == 'Metal') {
            markerColor = Colors.green;
          } else if (category == 'Glass') {
            markerColor = Colors.yellow;
          }
          return Marker(
            width: 40.0,
            height: 40.0,
            point: latLng,
            builder: (ctx) => Container(
              child: Icon(
                Icons.location_on,
                color: markerColor,
              ),
            ),
          );
        }).toList();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markers'),
      ),
      body: markerData != null
          ? FlutterMap(
        options: MapOptions(
          center: LatLng(6.93194, 79.84778), // Center of the map
          zoom: 10.0, // Zoom level of the map
        ),
        children: [
          openStreetMapTileLayer,
          MarkerLayer(
            markers: markerData,
          ),
        ],
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  TileLayer get openStreetMapTileLayer {
    return TileLayer(
      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      subdomains: ['a', 'b', 'c'],
    );
  }
}
