import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mao/resources/firestore_method.dart';
import 'package:flutter/material.dart';
// import 'package:google_mao/order_traking_page.dart';
import 'dart:async' show Completer;
import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_mao/resources/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CreateRoutePage extends StatefulWidget {
  const CreateRoutePage({Key? key}) : super(key: key);

  @override
  State<CreateRoutePage> createState() => CreateRoutePageState();
}

class CreateRoutePageState extends State<CreateRoutePage> {
  final Completer<GoogleMapController> _controller = Completer();

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  int markerIdCounter = 0; // Variable to keep track of marker IDs

  @override
  void initState() {
    super.initState();
  }

  Future<BitmapDescriptor> createCustomMarkerIcon(int markerId) async {
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

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

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

  void _nameTheRoute() {
    String routeName = '';
    String driverName = '';
    String PhoneNumber = '';
    double lat, long;
    List<GeoPoint> konum = [];

    // Map<String, dynamic> _uploadData = <String, dynamic>{};
    // FirebaseFirestore _firestore = FirebaseFirestore.instance;

    bool isMorningSelected = false;
    bool isEveningSelected = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Enter Route and Driver Details'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      routeName = value;
                    },
                    decoration: const InputDecoration(hintText: 'Güzergah Adı'),
                  ),
                  TextField(
                    onChanged: (value) {
                      driverName = value;
                    },
                    decoration:
                        const InputDecoration(hintText: "Driver's Name"),
                  ),
                  TextField(
                    onChanged: (value) {
                      PhoneNumber = value;
                    },
                    decoration:
                        const InputDecoration(hintText: "Telefon Numarası"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: isMorningSelected,
                        onChanged: (value) {
                          setState(() {
                            isMorningSelected = value ?? false;
                          });
                        },
                      ),
                      const Text('Morning'),
                      Checkbox(
                        value: isEveningSelected,
                        onChanged: (value) {
                          setState(() {
                            isEveningSelected = value ?? false;
                          });
                        },
                      ),
                      const Text('Evening'),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (routeName.isNotEmpty && driverName.isNotEmpty) {}
                    Navigator.of(context).pop(); // Close the dialog
                    print("*********************\n");
                    for (int i = 0; i < markerIdCounter; i++) {
                      String? newString =
                          markers.elementAt(i).infoWindow.snippet?.substring(7);
                      String? newString2 = newString?.replaceRange(
                          newString.length - 1, newString.length, "");
                      List<String>? latLngValues = newString2?.split(',');
                      latLngValues?[1] = latLngValues[1].substring(1);
                      lat = double.parse(latLngValues![0]);
                      long = double.parse(latLngValues![1]);
                      // GeoPoint(latLngValues?[0], latLngValues?[1]);
                      konum.add(GeoPoint(lat, long));
                    }
                    print(konum);
                    FireStoreMethods().uploadRoute(
                        routeName,
                        driverName,
                        PhoneNumber,
                        konum,
                        isMorningSelected,
                        isEveningSelected);
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _writeFirebase() {
    //todo
  }
  void _readFirebase() {
    //todo
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Güzergah Oluşturma Ekrani",
          style:
              TextStyle(color: ui.Color.fromARGB(255, 0, 0, 0), fontSize: 16),
        ),
        backgroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            color: ui.Color.fromARGB(255, 108, 107, 107),
            onSelected: (value) {
              if (value == 'deleteMarker') {
                // Call _deleteMarker method here
                if (markers.isNotEmpty) {
                  _deleteMarker(markers.last.markerId);
                }
              } else if (value == 'resetMarkers') {
                // Call _resetMarkersAndPolylines method here
                _resetMarkersAndPolylines();
              } else if (value == 'Save Route') {
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
