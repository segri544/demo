import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackPage extends StatelessWidget {
  final String documentId;

  // Constructor to receive the document ID
  TrackPage({required this.documentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Track Page')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('Maps')
            .doc(documentId)
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
              itemCount: hasMorningData && hasEveningData ? 2 : 1,
              itemBuilder: (context, index) {
                if (index == 0 && hasMorningData) {
                  // Display morning data
                  final morningData = data["sabah"] as Map<String, dynamic>;
                  return _buildListTile("Morning", morningData);
                } else if (index == 1 && hasEveningData) {
                  // Display evening data
                  final eveningData = data["akşam"] as Map<String, dynamic>;
                  return _buildListTile("Evening", eveningData);
                } else {
                  // If only morning or evening data is present, display that data
                  final singleData = data.values.first as Map<String, dynamic>;
                  return _buildListTile(
                    singleData.containsKey('sabah') ? "Morning" : "Evening",
                    singleData,
                  );
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
