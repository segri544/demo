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
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

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
  String driverId = "";
  Marker? _myMarker;
  bool serviceEnabled = false;

  Future<void> ToGetLocation() async {
    driverId = await FireStoreMethods()
        .getDriverIdByRouteName(widget.documentId, widget.routeName);
  }

  void startTimerForTrackLocation() {
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      getLocation(); // Call your function here
    });
  }

  void getLocation() async {
    var userSnap = await FirebaseFirestore.instance
        .collection("location")
        .doc(driverId = await FireStoreMethods()
            .getDriverIdByRouteName(widget.documentId, widget.routeName))
        .get();
    lat = userSnap["latitude"] as double;
    long = userSnap["longtitude"] as double;
    _updateMarker(LatLng(lat, long));
    print("lat: long: $lat $long");
    // setState(() {});
  }

  void getUserData() async {
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
    getUserData();
    _loadIsTrackingState(); // Saklanan isTracking durumunu yükle
    ToGetLocation();
    startTimerForTrackLocation();
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

// _myMarker'ı güncelleyecek fonksiyon
  void _updateMarker(LatLng newPosition) {
    setState(() {
      _myMarker = Marker(
        markerId: MarkerId(widget.routeName),
        position: newPosition,
        // Diğer özellikler, örneğin icon, title, vs. burada belirtilebilir
      );
      // _mapController?.animateCamera(
      //     CameraUpdate.newCameraPosition(CameraPosition(target: newPosition)));
    });
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

  void _startLocation() async {
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Konum servisi kapalı, kullanıcıya uyarı verelim
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Konum Servisi Kapalı'),
            content: Text('Lütfen cihazınızın konum servisini açın.'),
            actions: <Widget>[
              TextButton(
                child: Text('Tamam'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }
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
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                  child: Text(
                'Yükleniyor...',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ));
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
              // print(isMorning);
              // print(locations);
              // print(hasEveningData);
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
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return GoogleMap(
                      onMapCreated: (controller) {
                        _mapController = controller;
                        _createPolylinesSet();
                      },
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: true,
                      polylines: snapshot.data ?? {},
                      initialCameraPosition: CameraPosition(
                        target: LatLng(lat, long),
                        zoom: 15,
                      ),
                      markers: _myMarker != null
                          ? Set<Marker>.of([_myMarker!])
                          : Set<Marker>(),
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
                      style: TextStyle(fontWeight: FontWeight.bold),
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
                    serviceEnabled
                        ? (isTracking
                            ? "Canlı konum durdur"
                            : "Canlı konum başlat")
                        : "Canlı konum başlat",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: serviceEnabled
                        ? (isTracking ? Colors.red : Colors.blue)
                        : Colors.blue,

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

      // Create a list to store the futures of route segments
      List<Future<List<LatLng>>> routeSegmentsFutures = [];

      for (int i = 0; i < _routePoints.length - 1; i++) {
        // Add the future of the route segment to the list
        routeSegmentsFutures.add(_getRouteBetweenCoordinates(
          _routePoints[i],
          _routePoints[i + 1],
        ));
      }

      // Execute all the route segment futures in parallel
      List<List<LatLng>> routeSegments =
          await Future.wait(routeSegmentsFutures);

      // Flatten the list of lists into a single list of all route points
      routePoints.addAll(routeSegments.expand((segment) => segment));

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

  Future<List<LatLng>> _getRouteBetweenCoordinates(
    LatLng origin,
    LatLng destination,
  ) async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key, // Replace with your Google Maps API key
      PointLatLng(origin.latitude, origin.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    return polylineCoordinates;
  }
}
