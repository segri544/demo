// >>>>>> Author: Berke Gürel, Sadık EĞRİ, Mehmet Enes BİLGİN <<<<<<<

// Importing required packages
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// FireStoreMethods class for Firestore operations
class FireStoreMethods {
  String collectionNameForMaps = "Maps"; // Collection name for map routes
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance
  final FirebaseAuth _auth =
      FirebaseAuth.instance; // Firebase Authentication instance
  var userData = {}; // Placeholder for user data

  // Method to get user data (currently empty, may be used to fetch user data from Firestore)
  void getData() async {
    // Implementation of getting user data from Firestore
  }

  // Method to update user information in the database
  Future<void> updateUser(String name, String lastName, String? address,
      String email, String? carPlate) async {
    try {
      await _firestore.collection("users").doc(_auth.currentUser!.uid).update({
        "name": name,
        "lastName": lastName,
        "address": address,
        "email": email,
        "vehiclePlate": carPlate,
      });
    } catch (e) {
      print(e);
    }
  }

  // Method to handle liking/unliking a destination by the user
  Future<void> likeDestination(
      String destinationID, String userID, List likes) async {
    try {
      var destinationData =
          await _firestore.collection("Maps").doc(destinationID).get();
      var destinationSnap = destinationData.data() as Map<String, dynamic>;

      if (likes.contains(userID)) {
        // User already liked the destination, so unlike it
        await _firestore.collection("Maps").doc(destinationID).update({
          "likes": FieldValue.arrayRemove([userID]),
        });
        await _firestore.collection("users").doc(userID).update({
          "likedDestinations":
              FieldValue.arrayRemove([destinationSnap["sabah"]["name"]]),
        });
      } else {
        // User did not like the destination, so like it
        await _firestore.collection("Maps").doc(destinationID).update({
          "likes": FieldValue.arrayUnion([userID]),
        });
        await _firestore.collection("users").doc(userID).update({
          "likedDestinations":
              FieldValue.arrayUnion([destinationSnap["sabah"]["name"]]),
        });
      }
    } catch (err) {
      print(err.toString());
    }
  }

  // Method to upload a new route or update an existing route in the Firestore database
  Future<void> uploadRoute(
    String name,
    String phone,
    List<dynamic> konum,
    bool morning,
    bool evening,
  ) async {
    // Fetching user data from Firestore to use in the route information
    var userSnap = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    userData = userSnap.data()!;

    try {
      Map<String, dynamic> json = {};
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection(collectionNameForMaps)
          .doc(_auth.currentUser!.uid)
          .get();

      // Determine the format of the route JSON based on morning and evening flags
      if (morning && !evening) {
        json = {
          "destinationId": _auth.currentUser!.uid,
          "likes": [],
          "sabah": {
            "name": name,
            "driverName": "${userData["name"]} ${userData["lastName"]}",
            "phone": phone,
            "numberPlate": userData["vehiclePlate"],
            "locations": konum,
          },
        };
      } else if (evening && !morning) {
        json = {
          "likes": [],
          "destinationId": _auth.currentUser!.uid,
          "akşam": {
            "name": name,
            "driverName": "${userData["name"]} ${userData["lastName"]}",
            "phone": phone,
            "numberPlate": userData["vehiclePlate"],
            "locations": konum,
          },
        };
      } else {
        json = {
          "likes": [],
          "destinationId": _auth.currentUser!.uid,
          "sabah": {
            "name": name,
            "driverName": "${userData["name"]} ${userData["lastName"]}",
            "phone": phone,
            "numberPlate": userData["vehiclePlate"],
            "locations": konum,
          },
          "akşam": {
            "name": name,
            "driverName": "${userData["name"]} ${userData["lastName"]}",
            "phone": phone,
            "numberPlate": userData["vehiclePlate"],
            "locations": konum,
          },
        };
      }

      if (snapshot.exists) {
        // If the document already exists, update the route information
        await FirebaseFirestore.instance
            .collection(collectionNameForMaps)
            .doc(_auth.currentUser!.uid)
            .update(json);
      } else {
        // If the document does not exist, create a new one with the route information
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

  // Method to delete a route from the Firestore database
  Future deleteRoute(String name) async {
    await FirebaseFirestore.instance
        .collection(collectionNameForMaps)
        .doc(name)
        .delete();
  }

  // Method to update the driver's location in the database
  Future updateLocationFirestore(
      double lat, double long, bool istracking) async {
    final CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('location');
    Map<String, dynamic> json = {
      "latitude": lat,
      "longtitude": long,
      "istracking": istracking,
    };
    _collectionRef.doc(_auth.currentUser!.uid).set(json).then((_) {
      print("Document updated successfully!");
    }).catchError((error) {
      print("Error updating document: $error");
    });
  }

  // Method to update the istracking flag in the database
  Future updateIstracingFirestore(bool istracking) async {
    final CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('location');
    Map<String, dynamic> json = {
      "istracking": istracking,
    };
    _collectionRef.doc(_auth.currentUser!.uid).update(json).then((_) {
      print("Document updated successfully!");
    }).catchError((error) {
      print("Error updating document: $error");
    });
  }

  // Method to get the driver's ID (destinationId) by route name (docId) from the Firestore
  Future<String> getDriverIdByRouteName(String docId, String routeName) async {
    try {
      final firebase = FirebaseFirestore.instance;
      final documentRef = firebase.collection("Maps").doc(docId);
      final documentSnapshot = await documentRef.get();

      if (documentSnapshot.exists) {
        final data = documentSnapshot.data();
        final driverId = data!["destinationId"] as String;

        return driverId;
      } else {
        return "null";
      }
    } catch (e) {
      print("Error getting document: $e");
      return "null"; // You can handle the error as you like or return an error message
    }
  }
}
