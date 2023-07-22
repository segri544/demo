import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mao/models/destination_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireStoreMethods {
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

  Future uploadRoute(String name, String driverName, String phone, List konum,
      bool morning, bool evening) async {
    // referance to document
    final docRoute = FirebaseFirestore.instance.collection('Maps').doc(name);
    final json = {
      "name": name,
      "driverName": driverName,
      "phone": phone,
      "locations": konum,
      "morning": morning,
      "evening": evening
    };
    await docRoute.set(json);
  }
}
