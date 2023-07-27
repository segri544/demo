// import 'dart:html';
import 'package:demo_app/resources/firestore_method.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/resources/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:background_location/background_location.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool isTracking = false;
  var userData = {};
  bool isLoading = true;

  void ToGetLocation() {
    // documment id git -> şöför adını al
    // users a git şöför adına ait id al
    // locationa git oradan ilgili id ait konum bilgilerini çek
  }
  void getData() async {
    //get user data
    var userSnap = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    userData = userSnap.data()!;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getData();
    _loadIsTrackingState(); // Saklanan isTracking durumunu yükle
    // Future A = FireStoreMethods()
    //     .getDriverNameByRouteName(widget.documentId, widget.routeName);
    // print("A: $A");
  }

  void _loadIsTrackingState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isTracking = prefs.getBool('isTracking') ?? false;
    });
  }

  @override
  void dispose() {
    _saveIsTrackingState(); // Durumu kaydet
    super.dispose();
  }

  void _saveIsTrackingState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isTracking', isTracking); // isTracking durumunu kaydet
  }

  void _updateLocation() {
    print("update location");
    BackgroundLocation.getLocationUpdates((location) {
      FireStoreMethods().updateLocationFirestore(
          location.latitude as double, location.longitude as double);
      // print(location.latitude.toString());
      // print(location.longitude.toString());
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
              style: const TextStyle(
                color: Colors.white, // Set the title text color
                fontSize: 20, // Increase the font size
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat', // Use a custom font
              )),
          centerTitle: true,
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
                      // markers: _createMarkersSet(),
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
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
              onPressed: () {
                setState(() {
                  isMorning = !isMorning;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isMorning ? "Sabah Rotası" : "Akşam Rotası",
                    ),
                  ),
                );
              },
              child: Icon(
                isMorning ? Icons.wb_sunny : Icons.brightness_3,
              ),
            ),
          ],
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

        bottomNavigationBar: (userData["position"] == "Şöför"
            ? BottomAppBar(
                color: Colors.blue, // Custom background color
                child: ElevatedButton(
                  onPressed: () {
                    if (isTracking) {
                      _stopLocation();
                      print("stopping location button");
                    } else {
                      _startLocation();
                      print("starting location button");
                    }
                    setState(() {
                      isTracking = !isTracking;
                    });
                  },
                  child: Text(
                    isTracking ? "Canlı konum durdur" : "Canlı konum başlat",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: isTracking ? Colors.red : Colors.blue,

                    onPrimary: Colors.white,
                    // shape: StadiumBorder(),
                    elevation: 0, // Remove the button's elevation
                  ),
                ),
              )
            : null));
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
