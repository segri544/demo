// import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mao/models/destination_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future uploadRoute(String name, String driverName, String phone,
      String NumberPlate, List konum, bool morning, bool evening) async {
    Map<String, dynamic> json = {};
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection(collectionNameForMaps)
        .doc(name)
        .get();
    if (morning && !evening) {
      json = {
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
          "name": name,
          "driverName": driverName,
          "phone": phone,
          "numberPlate": NumberPlate,
          "locations": konum,
        }
      };
    } else {
      json = {
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
    ;
    if (snapshot.exists) {
      await FirebaseFirestore.instance
          .collection(collectionNameForMaps)
          .doc(name)
          .update(json);
    } else {
      final docRoute = FirebaseFirestore.instance
          .collection(collectionNameForMaps)
          .doc(name);

      await docRoute.set(json);
    }
    // referance to document
  }

  Future deleteRoute(String name) async {
    await FirebaseFirestore.instance
        .collection(collectionNameForMaps)
        .doc(name)
        .delete();
  }
}
