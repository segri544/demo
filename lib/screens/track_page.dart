import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mao/resources/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:animated_toggle_switch/animated_toggle_switch.dart';

class TrackPage extends StatefulWidget {
  final String documentId;

  // Constructor to receive the document ID
  TrackPage({required this.documentId});

  @override
  _TrackPageState createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  bool isMorning = true; // Default is morning
  GoogleMapController? _mapController;
  List<LatLng> _routePoints = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title:
            Text(widget.documentId.toUpperCase()), // Use widget.documentId here
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          Switch(
            value: isMorning,
            onChanged: (value) {
              setState(() {
                isMorning = value;
                // _updateRoute(); // Update the route when the switch changes
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('Maps')
            .doc(widget.documentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Document not found'));
          } else {
            final data = snapshot.data!.data()!;

            // Determine whether "sabah" and "akşam" data are present
            final bool hasMorningData = data.containsKey("sabah");
            final bool hasEveningData = data.containsKey("akşam");

            // Get the locations based on the selected switch value
            final locations = isMorning && hasMorningData
                ? data["sabah"]!["locations"]
                : (!isMorning && hasEveningData
                    ? data["akşam"]!["locations"]
                    : null);

            // Clear the route points
            _routePoints.clear();

            // Add the route points
            if (locations != null) {
              for (var location in locations) {
                if (location is GeoPoint) {
                  _routePoints
                      .add(LatLng(location.latitude, location.longitude));
                }
              }
            }

            // Return the Google Maps widget
            return FutureBuilder<Set<Polyline>>(
              future: _createPolylinesSet(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return GoogleMap(
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    markers: _createMarkersSet(),
                    polylines: snapshot.data ?? {},
                    initialCameraPosition: CameraPosition(
                      target: _routePoints.isNotEmpty
                          ? _routePoints.first
                          : LatLng(39.915447686012385, 32.772942732056286),
                      zoom: 14,
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  Set<Marker> _createMarkersSet() {
    if (_routePoints.isEmpty) return {};

    // Create markers for the start and end points of the route
    Marker startMarker = Marker(
      markerId: MarkerId('startMarker'),
      position: _routePoints.first,
      icon: BitmapDescriptor.defaultMarkerWithHue(
          isMorning ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueOrange),
      infoWindow: InfoWindow(
        title: isMorning ? 'Sabah Kalkış' : 'Akşam Varış',
        snippet:
            '${_routePoints.first.latitude}, ${_routePoints.first.longitude}',
      ),
    );

    Marker endMarker = Marker(
      markerId: MarkerId('endMarker'),
      position: _routePoints.last,
      icon: BitmapDescriptor.defaultMarkerWithHue(
          isMorning ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueOrange),
      infoWindow: InfoWindow(
        title: isMorning ? 'Sabah Varış' : 'Akşam Kalkış',
        snippet:
            '${_routePoints.last.latitude}, ${_routePoints.last.longitude}',
      ),
    );

    List<Marker> markersToShow = [startMarker, endMarker];

    return markersToShow.asMap().entries.map((entry) {
      int index = entry.key;
      Marker marker = entry.value;

      return Marker(
        markerId: MarkerId(index.toString()),
        position: marker.position,
        icon: marker.icon,
        infoWindow: InfoWindow(
          title: marker.infoWindow.title,
          snippet: marker.infoWindow.snippet,
        ),
      );
    }).toSet();
  }

  Future<Set<Polyline>> _createPolylinesSet() async {
    if (_routePoints.length > 1) {
      List<LatLng> routePoints = [];
      for (int i = 0; i < _routePoints.length - 1; i++) {
        List<LatLng> segmentPoints =
            await fetchRoutePoints(_routePoints[i], _routePoints[i + 1]);
        routePoints.addAll(segmentPoints);
      }

      Color polylineColor = isMorning ? Colors.blue : Colors.orange;

      return {
        Polyline(
          polylineId: PolylineId('route'),
          color: polylineColor,
          width: 5,
          points: routePoints,
        ),
      };
    } else {
      return {};
    }
  }

  // Function to fetch route data from Directions API
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
