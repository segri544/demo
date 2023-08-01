// Authors: Sadık EĞRİ - Mehmet Enes Bilgin

// Importing required packages and classes
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/resources/firestore_method.dart';
import 'package:flutter/material.dart';
import 'dart:async' show Completer;
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:demo_app/resources/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// CreateRoutePage widget
class CreateRoutePage extends StatefulWidget {
  const CreateRoutePage({Key? key}) : super(key: key);

  @override
  State<CreateRoutePage> createState() => CreateRoutePageState();
}

// CreateRoutePageState class
class CreateRoutePageState extends State<CreateRoutePage> {
  final Completer<GoogleMapController> _controller = Completer();

  // Set of markers and polylines to be displayed on the map
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  int markerIdCounter = 0; // Variable to keep track of marker IDs

  @override
  void initState() {
    super.initState();
  }

  // Method to create a custom marker icon based on the marker ID
  Future<BitmapDescriptor> createCustomMarkerIcon(int markerId) async {
    // Custom marker icon parameters
    const double pictureSize = 60.0;
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Colors.blue;
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw the marker circle
    canvas.drawCircle(
      const Offset(pictureSize / 2, pictureSize / 2),
      pictureSize / 2,
      paint,
    );

    // Draw the marker ID on top of the circle
    textPainter.text = TextSpan(
      text: markerId.toString(),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (pictureSize - textPainter.width) / 2,
        (pictureSize - textPainter.height) / 2,
      ),
    );
    final ui.Image markerImage = await pictureRecorder
        .endRecording()
        .toImage(pictureSize.toInt(), pictureSize.toInt());

    final ByteData? byteData =
        await markerImage.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  // Method called when the map is created
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  // Method called when a marker is dragged to a new position
  void _onMarkerDragEnd(MarkerId markerId, LatLng newPosition) {
    setState(() {
      markers = markers.map((marker) {
        if (marker.markerId == markerId) {
          return marker.copyWith(positionParam: newPosition);
        }
        return marker;
      }).toSet();
    });
  }

  // Method called when the map is tapped to add a new marker
  void _onMapTapped(LatLng tappedPoint) async {
    markerIdCounter++;
    final markerId = MarkerId(markerIdCounter.toString());
    final customIcon = await createCustomMarkerIcon(markerIdCounter);

    final marker = Marker(
      markerId: markerId,
      position: tappedPoint,
      draggable: true,
      icon: customIcon,
      onDragEnd: (newPosition) => _onMarkerDragEnd(markerId, newPosition),
      infoWindow: InfoWindow(
        title: 'Marker ${markerId.value}',
        snippet: tappedPoint.toString(),
      ),
    );

    setState(() {
      markers.add(marker);
    });
  }

  // Method to handle marker deletion
  void _deleteMarker(MarkerId markerId) {
    setState(() {
      markers.removeWhere((marker) => marker.markerId == markerId);
      markerIdCounter--;
      _createRoute(); // Re-create the route after marker deletion
    });
  }

  // Method to reset markers and polylines
  void _resetMarkersAndPolylines() {
    setState(() {
      markerIdCounter = 0;
      markers.clear();
      polylines.clear();
    });
  }

  // Method to create a route by connecting the markers with polylines
  void _createRoute() async {
    if (markers.length < 2) {
      // Not enough markers to create a route
      polylines.clear();
      return;
    }

    List<LatLng> markerPositions =
        markers.map((marker) => marker.position).toList();

    polylines.clear();
    polylineCoordinates.clear();

    for (int i = 0; i < markerPositions.length - 1; i++) {
      LatLng source = markerPositions[i];
      LatLng destination = markerPositions[i + 1];

      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(source.latitude, source.longitude),
        PointLatLng(destination.latitude, destination.longitude),
      );

      if (result.points.isNotEmpty) {
        polylineCoordinates.addAll(result.points.map(
            (PointLatLng point) => LatLng(point.latitude, point.longitude)));
      }
    }
    setState(() {
      polylines.add(
        Polyline(
          polylineId: const PolylineId("route"),
          points: polylineCoordinates,
          color: Colors.blue,
          width: 6,
        ),
      );
    });
  }

  // Method to display a dialog for naming the route
  void _nameTheRoute() {
    String routeName = '';
    String PhoneNumber = '';
    double lat, long;
    List<GeoPoint> konum = [];
    bool isMorningSelected = false;
    bool isEveningSelected = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Rota Verileri'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      routeName = value;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Güzergah Adı',
                    ),
                  ),
                  TextField(
                    onChanged: (value) {
                      PhoneNumber = value;
                    },
                    decoration: const InputDecoration(
                      hintText: "Telefon Numaranız",
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Checkbox(
                        value: isMorningSelected,
                        onChanged: (value) {
                          setState(() {
                            isMorningSelected = value ?? false;
                          });
                        },
                      ),
                      const Text('Sabah'),
                      Checkbox(
                        value: isEveningSelected,
                        onChanged: (value) {
                          setState(() {
                            isEveningSelected = value ?? false;
                          });
                        },
                      ),
                      const Text('Akşam'),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('iptal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (routeName.isNotEmpty) {
                      // If route name is not empty, proceed to save the route
                      Navigator.of(context).pop(); // Close the dialog

                      // Get the latitude and longitude of each marker and store them in konum list
                      for (int i = 0; i < markerIdCounter; i++) {
                        String? newString = markers
                            .elementAt(i)
                            .infoWindow
                            .snippet
                            ?.substring(7);
                        String? newString2 = newString?.replaceRange(
                            newString.length - 1, newString.length, "");
                        List<String>? latLngValues = newString2?.split(',');
                        latLngValues?[1] = latLngValues[1].substring(1);
                        lat = double.parse(latLngValues![0]);
                        long = double.parse(latLngValues![1]);
                        konum.add(GeoPoint(lat, long));
                      }
                      // Remove any trailing spaces from the route name
                      while (routeName.endsWith(" ")) {
                        routeName = routeName.trimRight();
                      }

                      // Remove any spaces from the vehicle plate and phone number

                      PhoneNumber = PhoneNumber.replaceAll(" ", "");

                      // Call the method to upload the route to Firestore
                      FireStoreMethods().uploadRoute(
                        routeName.toLowerCase(),
                        PhoneNumber,
                        konum,
                        isMorningSelected,
                        isEveningSelected,
                      );
                    }
                  },
                  child: Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 16, 99, 166),
        title: const Text(
          "Güzergah Oluşturma Ekrani",
          style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255), fontSize: 20),
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Montserrat',
        ),
        actions: [
          PopupMenuButton<String>(
            color: Color.fromARGB(255, 255, 255, 255),
            onSelected: (value) {
              if (value == 'deleteMarker') {
                // Call _deleteMarker method here when "Son Konumu Kaldır" is selected
                if (markers.isNotEmpty) {
                  _deleteMarker(markers.last.markerId);
                }
              } else if (value == 'resetMarkers') {
                // Call _resetMarkersAndPolylines method here when "Sıfırla" is selected
                _resetMarkersAndPolylines();
              } else if (value == 'Save Route') {
                // Call _nameTheRoute method here when "Güzergahı Kaydet" is selected
                _nameTheRoute();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'deleteMarker',
                child: Text('Son Konumu Kaldır'),
              ),
              const PopupMenuItem<String>(
                value: 'resetMarkers',
                child: Text('Sıfırla'),
              ),
              const PopupMenuItem<String>(
                value: 'Save Route',
                child: Text('Güzergahı Kaydet'),
              )
            ],
          ),
        ],
      ),
      body: GoogleMap(
        onTap: _onMapTapped,
        onMapCreated: _onMapCreated,
        polylines: polylines,
        markers: markers,
        initialCameraPosition: const CameraPosition(
          target: LatLng(39.915447686012385, 32.772942732056286),
          zoom: 15,
        ),
      ),
      floatingActionButton: Container(
        alignment: Alignment.bottomCenter,
        child: ElevatedButton(
          onPressed: _createRoute,
          child: const Text("Güzergah Oluştur"),
        ),
      ),
    );
  }
}
