/// >>>>>> Author: Berke Gürel <<<<<<<

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/models/user_model.dart' as model;
import 'package:flutter/material.dart';

// AuthMethods class for user authentication
class AuthMethods {
  final FirebaseAuth _auth =
      FirebaseAuth.instance; // Firebase authentication instance
  final _firestore =
      FirebaseFirestore.instance; // Firestore instance for database access

  // Sign up the user with provided details
  Future<String> signUpUser({
    required String email,
    required String password,
    required String name,
    required String lastName,
    required String position,
    String? carPlate,
    var likedDestinations,
    String? userAddress,
  }) async {
    String res = "Beklenmedik bir hata oluştu !"; // Default error message
    try {
      // Check if required fields are not empty
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          name.isNotEmpty ||
          position.isNotEmpty ||
          lastName.isNotEmpty) {
        // Register User using Firebase Authentication
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );

        // Create a new User object using the provided details
        model.User user = model.User(
          email: email,
          name: name,
          lastName: lastName,
          position: position,
          address: userAddress,
          vehiclePlate: carPlate,
          likedDestinations: [],
        );

        // Save user data to our Firestore database
        await _firestore
            .collection("users")
            .doc(credential.user!.uid)
            .set(user.toJson());

        res = "success"; // Success message
      }
    } on FirebaseAuthException catch (err) {
      // Handle specific FirebaseAuth exceptions
      if (err.code == "invalid-email") {
        res = "Email formatı yanlış"; // Invalid email format error message
      } else if (err.code == "weak-password") {
        res =
            "Şifreniz en az 6 karakter içermelidir"; // Weak password error message
      }
    } catch (err) {
      res = err.toString(); // General error message for any other errors
    }
    return res; // Return the result of the sign-up process
  }

  // Login the user with provided email and password
  Future<String> logInUser(
      {required String email, required String password}) async {
    String res = "Bir Hatayla karşılaşıldı"; // Default error message
    try {
      // Check if email and password are not empty
      if (email.isNotEmpty || password.isNotEmpty) {
        // Sign in the user using Firebase Authentication
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        res = "success"; // Success message
      } else {
        res =
            "Lütfen Her alanı doğru doldurunuz"; // Error message for empty fields
      }
    } catch (err) {
      res = err.toString(); // General error message for any other errors
    }
    return res; // Return the result of the login process
  }
}
