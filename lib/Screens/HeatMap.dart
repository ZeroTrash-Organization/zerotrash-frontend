import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  late final WebViewController _controller;


  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    _controller.loadFlutterAsset('assets/map.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heat Map'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
