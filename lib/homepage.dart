import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _mapController = Completer<GoogleMapController>();
  final _initialPos = const LatLng(37.42225729384123, -122.08405751644975);

  final Set<Marker> _allMarker = {};

  Future<void> getLocation() async {
    final jsonFile = await rootBundle.loadString("assets/locations.json");
    final json = jsonDecode(jsonFile) as List;

    for (int i = 0; i < json.length; i++) {
      final latlng = LatLng(json[i]['lat'], json[i]['lon']);
      _allMarker.add(Marker(
        markerId: MarkerId(i.toString()),
        position: latlng,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Map"),
      ),
      body: FutureBuilder<void>(
        future: getLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return GoogleMap(
              onMapCreated: (controller) {
                _mapController.complete(controller);
              },
              initialCameraPosition: CameraPosition(
                target: _initialPos,
                zoom: 15,
              ),
              markers: _allMarker,
            );
          }
          if (snapshot.hasError) {
            return _buildLoadFailure(snapshot.error.toString());
          }
          return _buildLoading();
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildLoadFailure(String message) {
    return Center(
      child: Text(message),
    );
  }

  // Set<Marker> _markTargets(BitmapDescriptor icon) {
  //   final Set<Marker> markers = {};

  //   for (var i = 0; i < _markerTargets.length; i++) {
  //     final currentMark = _markerTargets[i];

  //     markers.add(Marker(
  //       icon: icon,
  //       markerId: MarkerId(i.toString()),
  //       position: currentMark,
  //       infoWindow: InfoWindow(
  //         title: "Info: ${currentMark.latitude}, ${currentMark.longitude}",
  //       ),
  //       onTap: () {
  //         //DO stuff when mark got tap
  //       },
  //     ));
  //   }
  //   return markers;
  // }

  // Future<void> _moveToPosition(LatLng position) async {
  //   final controller = await _mapController.future;
  //   controller.animateCamera(
  //     CameraUpdate.newLatLng(position),
  //   );
  // }
}
