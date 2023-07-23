import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                  return ListTile(
                    title: Text("Morning"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Name: ${morningData['name']}"),
                        Text("Driver Name: ${morningData['driverName']}"),
                        Text("Phone: ${morningData['phone']}"),
                        // Add more fields as needed
                      ],
                    ),
                  );
                } else if (index == 1 && hasEveningData) {
                  // Display evening data
                  final eveningData = data["akşam"] as Map<String, dynamic>;
                  return ListTile(
                    title: Text("Evening"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Name: ${eveningData['name']}"),
                        Text("Driver Name: ${eveningData['driverName']}"),
                        Text("Phone: ${eveningData['phone']}"),
                        // Add more fields as needed
                      ],
                    ),
                  );
                } else {
                  // If only morning or evening data is present, display that data
                  final singleData = data.values.first as Map<String, dynamic>;
                  return ListTile(
                    title: Text(singleData.containsKey('sabah')
                        ? "Morning"
                        : "Evening"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Name: ${singleData['name']}"),
                        Text("Driver Name: ${singleData['driverName']}"),
                        Text("Phone: ${singleData['phone']}"),
                        // Add more fields as needed
                      ],
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
}
