import 'dart:async';
import 'package:demo_app/resources/constants.dart';
import 'package:demo_app/resources/firestore_method.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:background_location/background_location.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  Map<String, dynamic> userData = {}; // Variable to store user data
  Set<Polyline> _polylines = {}; // Set of polylines for the map
  GoogleMapController? _mapController; // Controller for the Google Map
  bool isMorning = true; // Change this based on your condition

  @override
  void initState() {
    super.initState();
    getUserData();
    _updateLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void getUserData() async {
    // Get user data from Firestore
    var userSnap = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    userData = userSnap.data()!;
    setState(() {});
  }

  void _updateLocation() {
    print("update location");
    BackgroundLocation.getLocationUpdates((location) {
      FireStoreMethods().updateLocationFirestore(
        location.latitude as double,
        location.longitude as double,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 4,
        toolbarHeight: 45,
        title: Text(
          widget.routeName.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
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
              ),
            );
          } else {
            final data = snapshot.data!.data()!;

            final bool hasMorningData = data.containsKey("sabah");
            final bool hasEveningData = data.containsKey("akşam");

            final locations = isMorning && hasMorningData
                ? data["sabah"]!["locations"]
                : (!isMorning && hasEveningData
                    ? data["akşam"]!["locations"]
                    : null);

            List<LatLng> routePoints = [];

            if (locations != null) {
              for (var location in locations) {
                if (location is GeoPoint) {
                  routePoints
                      .add(LatLng(location.latitude, location.longitude));
                }
              }
            }

            return GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
                _createPolylinesSet(routePoints);
              },
              zoomControlsEnabled: false,
              mapToolbarEnabled: true,
              polylines: _polylines,
              initialCameraPosition: CameraPosition(
                target: LatLng(39.93634092516396, 32.8238638211257),
                zoom: 14,
              ),
              markers: Set<Marker>(),
            );
          }
        },
      ),
    );
  }

  void _createPolylinesSet(List<LatLng> routePoints) async {
    if (routePoints.length > 1) {
      List<LatLng> routePointsWithPolylines = [];
      List<Polyline> polylines = [];

      for (int i = 0; i < routePoints.length - 1; i++) {
        List<LatLng> segment = await _getRouteBetweenCoordinates(
          routePoints[i],
          routePoints[i + 1],
        );
        routePointsWithPolylines.addAll(segment);
      }

      Color polylineColor = isMorning ? Colors.orange : Colors.blue;

      polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          color: polylineColor,
          width: 5,
          points: routePointsWithPolylines,
        ),
      );

      setState(() {
        _polylines = polylines.toSet();
      });
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
      polylineCoordinates = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    }
    return polylineCoordinates;
  }
}
