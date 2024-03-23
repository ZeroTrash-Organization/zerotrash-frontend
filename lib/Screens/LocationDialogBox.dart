import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationDialogBox extends StatefulWidget {
  final Function(double latitude, double longitude) onSave;

  const LocationDialogBox({Key? key, required this.onSave}) : super(key: key);

  @override
  _LocationDialogBoxState createState() => _LocationDialogBoxState();
}

class _LocationDialogBoxState extends State<LocationDialogBox> {
  late GoogleMapController _controller;
  late LatLng _selectedLocation;

  late CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(6.93194, 79.84778),
    zoom: 15,
  );

  @override
  void initState() {
    super.initState();
    _selectedLocation = LatLng(6.93194, 79.84778); // Default location (Colombo, Sri Lanka)
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Location'),
      content: SizedBox(
        height: 300,
        width: 300,
        child: GoogleMap(
          initialCameraPosition: initialCameraPosition,
          onTap: _selectLocation,
          markers: <Marker>{
            Marker(
              markerId: MarkerId('selected-location'),
              position: _selectedLocation,
              draggable: true,
              onDragEnd: (LatLng newPosition) {
                setState(() {
                  _selectedLocation = newPosition;
                });
              },
            ),
          },
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_selectedLocation.latitude, _selectedLocation.longitude);
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Save'),
        ),
      ],
    );
  }

  void _selectLocation(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }
}
