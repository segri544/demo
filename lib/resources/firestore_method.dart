// import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/models/destination_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class FireStoreMethods {
  String collectionNameForMaps = "Maps";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateUser(String name, String lastName, String? address,
      String email, String? carPlate) async {
    try {
      await _firestore.collection("users").doc(_auth.currentUser!.uid).update({
        "name": name,
        "lastName": lastName,
        "address": address,
        "email": email,
        "vehiclePlate": carPlate
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> likeDestination(
      String destinationID, String userID, List likes) async {
    try {
      if (likes.contains(userID)) {
        await _firestore.collection("Maps").doc(destinationID).update({
          "likes": FieldValue.arrayRemove([userID])
        });
        await _firestore.collection("users").doc(userID).update({
          "likedDestination": FieldValue.arrayRemove([destinationID])
        });
      } else {
        await _firestore.collection("Maps").doc(destinationID).update({
          "likes": FieldValue.arrayUnion([userID])
        });
        await _firestore.collection("users").doc(userID).update({
          "likedDestination": FieldValue.arrayUnion([destinationID])
        });
      }
    } catch (err) {
      print(err.toString());
    }
  }

  Future<String> uploadDestination(
    String carPlate,
    String driverId,
    int capacity,
  ) async {
    String res = "Some error occured!";
    try {
      Destination destination = Destination(carPlate, driverId, capacity);

      await _firestore
          .collection("destinations")
          .doc(_auth.currentUser!.uid)
          .set({
        "carPlate": carPlate,
        "driverId": driverId,
        "capacity": capacity,
      });
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

//************************************************************ */
  // Same function will be used for update

  Future<void> uploadRoute(
      String name,
      String driverName,
      String phone,
      String NumberPlate,
      List<dynamic> konum,
      bool morning,
      bool evening) async {
    try {
      Map<String, dynamic> json = {};
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection(collectionNameForMaps)
          .doc(_auth.currentUser!.uid)
          .get();

      if (morning && !evening) {
        json = {
          "destinationId": _auth.currentUser!.uid,
          "sabah": {
            "name": name,
            "driverName": driverName,
            "phone": phone,
            "numberPlate": NumberPlate,
            "locations": konum,
          }
        };
      } else if (evening && !morning) {
        json = {
          "akşam": {
            "destinationId": _auth.currentUser!.uid,
            "name": name,
            "driverName": driverName,
            "phone": phone,
            "numberPlate": NumberPlate,
            "locations": konum,
          }
        };
      } else {
        json = {
          "destinationId": _auth.currentUser!.uid,
          "sabah": {
            "name": name,
            "driverName": driverName,
            "phone": phone,
            "numberPlate": NumberPlate,
            "locations": konum,
          },
          "akşam": {
            "name": name,
            "driverName": driverName,
            "phone": phone,
            "numberPlate": NumberPlate,
            "locations": konum,
          }
        };
      }

      if (snapshot.exists) {
        await FirebaseFirestore.instance
            .collection(collectionNameForMaps)
            .doc(_auth.currentUser!.uid)
            .update(json);
      } else {
        final docRoute = FirebaseFirestore.instance
            .collection(collectionNameForMaps)
            .doc(_auth.currentUser!.uid);

        await docRoute.set(json);
      }
      print("Route update/upload successful!");
    } catch (e) {
      print("Error updating/uploading route: $e");
    }
  }

  Future deleteRoute(String name) async {
    await FirebaseFirestore.instance
        .collection(collectionNameForMaps)
        .doc(name)
        .delete();
  }

  // **************************************************
  Future updateLocationFirestore(double lat, double long) async {
    final CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('location');
    print("${_auth.currentUser!.uid}: updateLocationFirestore");
    Map<String, dynamic> json = {
      "latitude": lat,
      "longtitude": long,
    };
    _collectionRef.doc(_auth.currentUser!.uid).set(json).then((_) {
      print("Document updated successfully!");
    }).catchError((error) {
      print("Error updating document: $error");
    });
  }

  Future<LatLng?> getLocationFirestore(String documentId) async {
    try {
      // Access the Firestore collection and document using the provided documentId
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('location') // Specify the collection name
              .doc(documentId) // Specify the document ID
              .get();

      // Check if the document exists
      if (snapshot.exists) {
        // Get the data from the document
        Map<String, dynamic> data = snapshot.data()!;

        // Extract the latitude and longitude values from the data
        double latitude = data['latitude'] as double;
        double longitude = data['longitude'] as double;

        // Create a LatLng object with the retrieved latitude and longitude
        LatLng locationLatLng = LatLng(latitude, longitude);

        return locationLatLng;
      } else {
        // Document not found, return null or handle the case accordingly
        return null;
      }
    } catch (e) {
      // Handle any errors that may occur during the Firestore read operation
      print('Error getting location from Firestore: $e');
      return null;
    }
  }

  //*****************************************************************
  Future<String> getDriverNameByRouteName(
      String docId, String routeName) async {
    try {
      final firebase = FirebaseFirestore.instance;
      final documentRef = firebase.collection("Maps").doc(docId);
      final documentSnapshot = await documentRef.get();

      if (documentSnapshot.exists) {
        final data = documentSnapshot.data();
        // print("docSNAPPPPP: \n\n $data");
        // print(data?["sabah"]["driverName"]);
        // Check if "name" exists under "sabah" field
        if (data!.containsKey("sabah") && data["sabah"]["name"] == routeName) {
          final driverName = data["sabah"]["driverName"];
          return driverName;
        }

        // Check if "name" exists under "akşam" field
        if (data!.containsKey("akşam") && data["akşam"]["name"] == routeName) {
          final driverName = data["akşam"]["driverName"];
          print("SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS");
          return driverName;
        }

        // Return if "name" is not found under either "sabah" or "akşam"
        return "No matching documents found.";
      } else {
        return "Document with the specified docId does not exist.";
      }
    } catch (e) {
      print("Error getting document: $e");
      return "null"; // You can handle the error as you like or return an error message
    }
  }
}
