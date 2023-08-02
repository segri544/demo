// Author: Berke GÜREL

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/components/button_large.dart';
import 'package:demo_app/components/my_textfield.dart';
import 'package:demo_app/resources/firestore_method.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _adressController =
      TextEditingController(); // Controller for the address text field
  final _nameController =
      TextEditingController(); // Controller for the name text field
  final _lastNameController =
      TextEditingController(); // Controller for the last name text field
  final _emailController =
      TextEditingController(); // Controller for the email text field
  final _vehiclePlateController =
      TextEditingController(); // Controller for the vehicle plate text field

  var userData = {}; // Map to store the user data retrieved from Firestore
  bool isLoading =
      true; // Variable to track the loading state while fetching user data

  void getData() async {
    // Get user data from Firestore using the current user's UID
    var userSnap = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    userData = userSnap.data()!; // Store the user data in the userData map
    _nameController.text =
        userData["name"]; // Set the name text field with the user's name
    _lastNameController.text = userData[
        "lastName"]; // Set the last name text field with the user's last name
    _adressController.text = userData["address"] ??
        ""; // Set the address text field with the user's address if available, otherwise an empty string
    _emailController.text =
        userData["email"]; // Set the email text field with the user's email

    setState(() {
      isLoading =
          false; // Set isLoading to false to indicate that data fetching is complete
    });
  }

  @override
  void initState() {
    super.initState();
    getData(); // Call getData() method when the widget is initialized to fetch user data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text("Profil Güncelleme"), // Display the app bar title
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            ) // Show a circular progress indicator while loading data
          : SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      const Icon(
                        Icons.person,
                        size: 100,
                      ), // Display an icon representing the user's profile
                      Text(
                        "Profil Güncelleme", // Display a heading for the profile edit screen
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 25),
                      MyTextField(
                        controller: _nameController,
                        hintText:
                            "İsim", // Display a hint text for the name text field
                        isObscure: false,
                      ),
                      const SizedBox(height: 5),
                      MyTextField(
                        controller: _lastNameController,
                        hintText:
                            "Soyisim", // Display a hint text for the last name text field
                        isObscure: false,
                      ),
                      const SizedBox(height: 10),
                      userData["position"] != "Şöför"
                          ? MyTextField(
                              controller: _adressController,
                              hintText:
                                  "Yeni Adres", // Display a hint text for the address text field if the user is not a driver
                              isObscure: false,
                              icon: const Icon(Icons
                                  .location_city), // Display an icon for the address text field
                            )
                          : MyTextField(
                              controller: _vehiclePlateController,
                              hintText:
                                  "Yeni Plaka", // Display a hint text for the vehicle plate text field if the user is a driver
                              isObscure: false,
                              icon: const Icon(Icons
                                  .bus_alert), // Display an icon for the vehicle plate text field
                            ),
                      const SizedBox(height: 5),
                      MyTextField(
                        controller: _emailController,
                        hintText:
                            "Email", // Display a hint text for the email text field
                        isObscure: false,
                        icon: const Icon(Icons
                            .mail), // Display an icon for the email text field
                      ),
                      const SizedBox(height: 25),
                      ButtonLarge(
                        title: "Güncelle", // Display the button title
                        onTapFunction: () {
                          // Call the updateUser method from FireStoreMethods to update the user data
                          FireStoreMethods().updateUser(
                              _nameController.text
                                  .trim(), // trim The string without any leading and trailing whitespace.
                              _lastNameController.text.trim(),
                              _adressController.text.trim(),
                              _emailController.text.trim(),
                              _vehiclePlateController.text.trim());
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Başarıyla Güncellendi", // Display a success message in a snackbar
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
