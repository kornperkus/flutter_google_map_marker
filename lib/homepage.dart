import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _mapController = Completer<GoogleMapController>();
  final _initialPos = const LatLng(37.42225729384123, -122.08405751644975);

  final List<LatLng> _markerTargets = const [
    LatLng(37.421405, -122.086193),
    LatLng(37.432597, -122.076279),
    LatLng(37.424126, -122.074559),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final currenLocation = _initialPos;
    _moveToPosition(LatLng(currenLocation.latitude, currenLocation.longitude));
  }

  Future<BitmapDescriptor> _getMarkerIcon() async {
    await Future.delayed(const Duration(seconds: 2));
    return BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/place.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Map"),
      ),
      body: FutureBuilder<BitmapDescriptor>(
        future: _getMarkerIcon(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final icon = snapshot.data;
            final markers = _markTargets(icon!);

            return GoogleMap(
              onMapCreated: (controller) {
                _mapController.complete(controller);
              },
              initialCameraPosition: CameraPosition(
                target: _initialPos,
                zoom: 15,
              ),
              gestureRecognizers: {
                Factory(() => PanGestureRecognizer()),
              },
              markers: markers,
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

  Set<Marker> _markTargets(BitmapDescriptor icon) {
    final Set<Marker> markers = {};

    for (var i = 0; i < _markerTargets.length; i++) {
      final currentMark = _markerTargets[i];

      markers.add(Marker(
        icon: icon,
        markerId: MarkerId(i.toString()),
        position: currentMark,
        infoWindow: InfoWindow(
          title: "Info: ${currentMark.latitude}, ${currentMark.longitude}",
        ),
        onTap: () {
          //DO stuff when mark got tap
        },
      ));
    }
    return markers;
  }

  Future<void> _moveToPosition(LatLng position) async {
    final controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newLatLng(position),
    );
  }
}
