import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/components/bus_card.dart';
import 'package:demo_app/screens/track_page.dart'; // Import the TrackPage

class BusListScreen extends StatelessWidget {
  const BusListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Maps').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final routes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final routeData = routes[index].data() as Map<String, dynamic>;
              final routeName = routes[index].id;
              final morningData = routeData['sabah']
                  as Map<String, dynamic>?; // Use null safety for safe access
              final eveningData = routeData['akşam']
                  as Map<String, dynamic>?; // Use null safety for safe access

              return GestureDetector(
                onTap: () {
                  // Navigate to TrackPage when the list item is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrackPage(documentId: routeName),
                    ),
                  );
                },
                child: Column(
                  children: [
                    if (morningData != null) ...[
                      BusCard(
                        carPlate: morningData['numberPlate'],

                        // You can pass other relevant data from morningData here
                      ),
                    ],
                    if (eveningData != null) ...[
                      BusCard(
                        carPlate: eveningData['numberPlate'],
                        // You can pass other relevant data from eveningData here
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
