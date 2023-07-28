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
  final _adressController = TextEditingController();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _vehiclePlateController = TextEditingController();

  var userData = {};
  bool isLoading = true;

  void getData() async {
    //get user data
    var userSnap = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    userData = userSnap.data()!;
    _nameController.text = userData["name"];
    _lastNameController.text = userData["lastName"];
    _adressController.text = userData["address"] ?? "";
    _emailController.text = userData["email"];

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text("Profil Güncelleme"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
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
                      ),
                      Text(
                        "Profil Güncelleme",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 25),
                      MyTextField(
                        controller: _nameController,
                        hintText: "İsim",
                        isObscure: false,
                      ),
                      const SizedBox(height: 5),
                      MyTextField(
                        controller: _lastNameController,
                        hintText: "Soyisim",
                        isObscure: false,
                      ),
                      const SizedBox(height: 10),
                      userData["position"] != "Şöför"
                          ? MyTextField(
                              controller: _adressController,
                              hintText: "Yeni Adres",
                              isObscure: false,
                              icon: const Icon(Icons.location_city),
                            )
                          : MyTextField(
                              controller: _vehiclePlateController,
                              hintText: "Yeni Plaka",
                              isObscure: false,
                              icon: const Icon(Icons.bus_alert),
                            ),
                      const SizedBox(height: 5),
                      MyTextField(
                        controller: _emailController,
                        hintText: "Email",
                        isObscure: false,
                        icon: const Icon(Icons.mail),
                      ),
                      const SizedBox(height: 25),
                      ButtonLarge(
                        title: "Güncelle",
                        onTapFunction: () {
                          FireStoreMethods().updateUser(
                              _nameController.text.trim(),
                              _lastNameController.text.trim(),
                              _adressController.text.trim(),
                              _emailController.text.trim(),
                              _vehiclePlateController.text.trim());
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Başarıyla Güncellendi",
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
