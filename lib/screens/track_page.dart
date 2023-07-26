// import 'dart:html';
import 'package:demo_app/resources/firestore_method.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/resources/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:background_location/background_location.dart';

// import 'package:animated_toggle_switch/animated_toggle_switch.dart';

class TrackPage extends StatefulWidget {
  final String documentId;
  final String routeName;

  // Constructor to receive the document ID
  TrackPage({required this.documentId, required this.routeName});

  @override
  _TrackPageState createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  bool isMorning = true; // Default is morning
  GoogleMapController? _mapController;
  List<LatLng> _routePoints = [];
  double lat = 0, long = 0;

  @override
  void initState() {
    super.initState();
  }

  void _updateLocation() {
    print("update location");
    BackgroundLocation.getLocationUpdates((location) {
      FireStoreMethods().updateLocationFirestore(
          location.latitude as double, location.longitude as double);
      // Map<String, dynamic> json = {
      //   "latitude": location.latitude,
      //   "longtitude": location.longitude,
      //   "name": "mdasjdnasdas"
      // };
      // final CollectionReference _collectionRef =
      //     FirebaseFirestore.instance.collection('location');
      // _mapController!.animateCamera(CameraUpdate.newLatLng(
      //     LatLng(location.latitude as double, location.longitude as double)));
      // _collectionRef.doc("user1").update(json).then((_) {
      //   print("Document updated successfully!");
      // }).catchError((error) {
      //   print("Error updating document: $error");
      // });
      print(location.latitude.toString());
      print(location.longitude.toString());
    });
  }

  void _startLocation() {
    BackgroundLocation.startLocationService();
    _updateLocation();
  }

  void _stopLocation() {
    BackgroundLocation.stopLocationService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Custom background color
        elevation: 4, // Add a shadow/elevation to the AppBar
        toolbarHeight: 45, // Increase the AppBar's height for a modern look
        title: Text(widget.routeName.toUpperCase(),
            style: TextStyle(
              color: Colors.white, // Set the title text color
              fontSize: 20, // Increase the font size
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat', // Use a custom font
            )),
        actions: [
          LiteRollingSwitch(
            value: isMorning,
            textOn: 'Sabah',
            textOff: 'Akşam',
            width: 100,
            colorOn: Color.fromARGB(255, 239, 231, 5),
            colorOff: const Color.fromARGB(255, 13, 64, 90),
            iconOn: Icons.wb_sunny,
            iconOff: Icons.brightness_3,
            onDoubleTap: () {},
            onSwipe: () {},
            onTap: () {},
            onChanged: (bool state) {
              setState(() {
                isMorning = state;
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

            return FutureBuilder<Set<Polyline>>(
              future: _createPolylinesSet(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return GoogleMap(
                    //
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: true,
                    markers: _createMarkersSet(),
                    polylines: snapshot.data ?? {},
                    initialCameraPosition: CameraPosition(
                      target: LatLng(39.915447686012385, 32.772942732056286),
                      zoom: 14,
                    ),
                  );
                }
              },
            );
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            child: Icon(Icons.location_on),
            onPressed: () {
              if (_mapController != null) {
                _mapController!.animateCamera(CameraUpdate.newLatLng(
                  LatLng(lat, long),
                ));
              }
            },
          ),
          FloatingActionButton(
            child: Icon(Icons.start),
            onPressed: () {
              _startLocation();
              print("start location button");
            },
          ),
          SizedBox(height: 16), // Add some spacing between the buttons
          FloatingActionButton(
              child: Icon(Icons.update),
              onPressed: () {
                _updateLocation();
                print("update location button");
              }),
        ],
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
        isMorning ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueBlue,
      ),
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
        isMorning ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueBlue,
      ),
      infoWindow: InfoWindow(
        title: isMorning ? 'Sabah Varış' : 'Akşam Kalkış',
        snippet:
            '${_routePoints.last.latitude}, ${_routePoints.last.longitude}',
      ),
    );

    List<Marker> markersToShow = [startMarker, endMarker];

    // Add a marker for the user's current location only if it's available
    // if (currentLocation != null) {
    //   markersToShow.add(
    //     Marker(
    //       markerId: MarkerId("Here"),
    //       position: LatLng(
    //         currentLocation!.latitude as double,
    //         currentLocation!.longitude as double,
    //       ),
    //     ),
    //   );
    // }

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

      Color polylineColor = isMorning ? Colors.orange : Colors.blue;

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
