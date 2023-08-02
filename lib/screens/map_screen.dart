// Authors: Sadık EĞRİ - Mehmet Enes Bilgin

import 'package:demo_app/resources/constants.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Maps"),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('Maps').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No maps found'));
          } else {
            final mapsDocs = snapshot.data!.docs;
            return MapWithRoutes(mapsDocs: mapsDocs);
          }
        },
      ),
    );
  }
}

class MapWithRoutes extends StatefulWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> mapsDocs;

  MapWithRoutes({required this.mapsDocs});

  @override
  _MapWithRoutesState createState() => _MapWithRoutesState();
}

class _MapWithRoutesState extends State<MapWithRoutes> {
  GoogleMapController? _mapController;
  List<List<LatLng>> _routePointsList = [];

  @override
  void initState() {
    super.initState();
    _createPolylinesSet();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (controller) {
        _mapController = controller;
      },
      zoomControlsEnabled: false,
      mapToolbarEnabled: true,
      markers: _createMarkersSet(),
      polylines: _createPolylinesSet(),
      initialCameraPosition: CameraPosition(
        target: _routePointsList.isNotEmpty
            ? _routePointsList.first.first
            : LatLng(39.915447686012385, 32.772942732056286),
        zoom: 14,
      ),
    );
  }

  Set<Marker> _createMarkersSet() {
    Set<Marker> markersSet = {};

    for (var routePoints in _routePointsList) {
      if (routePoints.isNotEmpty) {
        Marker startMarker = Marker(
          markerId: MarkerId('${routePoints.first}'),
          position: routePoints.first,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: 'Start',
            snippet:
                '${routePoints.first.latitude}, ${routePoints.first.longitude}',
          ),
        );

        Marker endMarker = Marker(
          markerId: MarkerId('${routePoints.last}'),
          position: routePoints.last,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: 'End',
            snippet:
                '${routePoints.last.latitude}, ${routePoints.last.longitude}',
          ),
        );

        markersSet.add(startMarker);
        markersSet.add(endMarker);
      }
    }

    return markersSet;
  }

  Set<Polyline> _createPolylinesSet() {
    Set<Polyline> polylinesSet = {};
    for (var routePoints in _routePointsList) {
      if (routePoints.length > 1) {
        Color polylineColor = Colors.blue;

        Polyline polyline = Polyline(
          polylineId: PolylineId('${routePoints.first}_${routePoints.last}'),
          color: polylineColor,
          width: 5,
          points: routePoints,
        );

        polylinesSet.add(polyline);
      }
    }
    return polylinesSet;
  }

  Future<List<LatLng>> fetchRoutePoints(
      LatLng origin, LatLng destination) async {
    final apiKey = google_api_key;
    final apiUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey";

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["status"] == "OK") {
        final List<dynamic> routes = data["routes"];
        if (routes.isNotEmpty) {
          final List<dynamic> legs = routes[0]["legs"];
          if (legs.isNotEmpty) {
            final List<dynamic> steps = legs[0]["steps"];
            List<LatLng> points = [];
            for (final step in steps) {
              final encodedPolyline = step["polyline"]["points"];
              final List<LatLng> decodedPoints =
                  decodeEncodedPolyline(encodedPolyline);
              points.addAll(decodedPoints);
            }
            return points;
          }
        }
      }
    }
    return [];
  }

  // Helper function to decode the encoded polyline points
  List<LatLng> decodeEncodedPolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;
    while (index < encoded.length) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latitude = lat / 1e5;
      double longitude = lng / 1e5;
      points.add(LatLng(latitude, longitude));
    }
    return points;
  }
}
