import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/models/user_model.dart' as model;

class AuthMethods {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  //Sign-Up User
  Future<String> signUpUser(
      {required String email,
      required String password,
      required String name,
      required String lastName,
      required String position,
      String? carPlate,
      String? userAddress}) async {
    String res = "Beklenmedik bir hata oluştu !";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          name.isNotEmpty ||
          position.isNotEmpty ||
          lastName.isNotEmpty) {
        //Register User
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
            email: email.trim(), password: password.trim());

        //Add user to our database
        model.User user = model.User(
            email: email,
            name: name,
            lastName: lastName,
            position: position,
            address: userAddress,
            vehiclePlate: carPlate,
            likedDestination: []);
        //yukarıda aldığımız bilgilerle userın içeriklerini set ettik
        await _firestore
            .collection("users")
            .doc(credential.user!.uid)
            .set(user.toJson());
        res = "success";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == "invalid-email") {
        res = "Email is badly formatted";
      } else if (err.code == "weak-password") {
        res = "Your password must be at least 6 characters";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //Login User
  Future<String> logInUser(
      {required String email, required String password}) async {
    String res = "Bir Hatayla karşılaşıldı";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "success";
      } else {
        res = "Lütfen Her alanı doğru doldurunuz";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
