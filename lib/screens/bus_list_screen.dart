// Author: Berke GÜREL

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/components/bus_card.dart';
import 'package:demo_app/screens/track_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Extracting data from the snapshot
          final routes = snapshot.data!.docs;

          // Creating a map to store unique routes with their data
          final uniqueRoutes = <String, Map<String, dynamic>>{};

          // Iterating through all routes from the snapshot data
          for (final route in routes) {
            final routeData = route.data() as Map<String, dynamic>;
            final routeName = route.id;
            final morningData = routeData['sabah']
                as Map<String, dynamic>?; // Use null safety for safe access
            final eveningData = routeData['akşam']
                as Map<String, dynamic>?; // Use null safety for safe access

            // Storing routes with morning or evening data in the uniqueRoutes map
            if (morningData != null || eveningData != null) {
              uniqueRoutes[routeName] = {
                if (morningData != null) ...morningData,
                if (eveningData != null) ...eveningData,
              };
            }
          }

          // Building a ListView with unique route data
          return ListView.builder(
            itemCount: uniqueRoutes.length,
            itemBuilder: (context, index) {
              final RouteID = uniqueRoutes.keys.elementAt(index);
              final routeData = uniqueRoutes[RouteID];

              // Navigating to TrackPage with specific data when a BusCard is tapped
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrackPage(
                          documentId: RouteID, routeName: routeData?["name"]),
                    ),
                  );
                },
                child: BusCard(
                  snap:
                      snapshot.data!.docs[index].data() as Map<String, dynamic>,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
