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
  var userData = {};

  void getData() async {
    //get user data
  }

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
      var destinationData =
          await _firestore.collection("Maps").doc(destinationID).get();

      var destinationSnap = destinationData.data() as Map<String, dynamic>;

      if (likes.contains(userID)) {
        await _firestore.collection("Maps").doc(destinationID).update({
          "likes": FieldValue.arrayRemove([userID])
        });
        await _firestore.collection("users").doc(userID).update({
          "likedDestination":
              FieldValue.arrayRemove([destinationSnap["sabah"]["name"]])
        });
      } else {
        await _firestore.collection("Maps").doc(destinationID).update({
          "likes": FieldValue.arrayUnion([userID])
        });
        await _firestore.collection("users").doc(userID).update({
          "likedDestination":
              FieldValue.arrayUnion([destinationSnap["sabah"]["name"]])
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
      // String driverName,
      String phone,
      // String NumberPlate,
      List<dynamic> konum,
      bool morning,
      bool evening) async {
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

      if (morning && !evening) {
        json = {
          "destinationId": _auth.currentUser!.uid,
          "sabah": {
            "name": name,
            "driverName": "${userData["name"]} ${userData["lastName"]}",
            "phone": phone,
            "numberPlate": userData["vehiclePlate"],
            "locations": konum,
          }
        };
      } else if (evening && !morning) {
        json = {
          "akşam": {
            "destinationId": _auth.currentUser!.uid,
            "name": name,
            "driverName": "${userData["name"]} ${userData["lastName"]}",
            "phone": phone,
            "numberPlate": userData["vehiclePlate"],
            "locations": konum,
          }
        };
      } else {
        json = {
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
  Future updateLocationFirestore(
      double lat, double long, bool istracking) async {
    final CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('location');
    // print("${_auth.currentUser!.uid}: updateLocationFirestore");
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

  //*****************************************************************
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
