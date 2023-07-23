import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackPage extends StatefulWidget {
  final String documentId;

  // Constructor to receive the document ID
  TrackPage({required this.documentId});

  @override
  _TrackPageState createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  bool isMorning = true; // Default is morning

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text(widget.documentId),
        titleTextStyle: TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        actions: [
          Switch(
            value: isMorning,
            onChanged: (value) {
              setState(() {
                isMorning = value;
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

            return ListView.builder(
              itemCount:
                  isMorning && hasMorningData || !isMorning && hasEveningData
                      ? 1
                      : 0,
              itemBuilder: (context, index) {
                if (isMorning && hasMorningData) {
                  // Display morning data
                  final morningData = data["sabah"] as Map<String, dynamic>;
                  return _buildListTile("Morning", morningData);
                } else if (!isMorning && hasEveningData) {
                  // Display evening data
                  final eveningData = data["akşam"] as Map<String, dynamic>;
                  return _buildListTile("Evening", eveningData);
                } else {
                  return SizedBox
                      .shrink(); // Empty placeholder if data is not available
                }
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildListTile(String title, Map<String, dynamic> data) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${data['name']}"),
            Text("Driver Name: ${data['driverName']}"),
            Text("Phone: ${data['phone']}"),
            _buildGeoPointInfo(data['locations']),
          ],
        ),
      ),
    );
  }

  Widget _buildGeoPointInfo(List<dynamic>? locations) {
    if (locations == null || locations.isEmpty) {
      return Text("No GeoPoints available");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("GeoPoints:"),
        for (var location in locations)
          if (location is GeoPoint)
            Text(
              "Latitude: ${location.latitude}, Longitude: ${location.longitude}",
            ),
      ],
    );
  }
}
