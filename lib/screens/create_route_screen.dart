import 'dart:ffi';

import 'package:demo_app/components/button_large.dart';
import 'package:demo_app/components/my_textfield.dart';
import 'package:demo_app/resources/firestore_method.dart';
import 'package:flutter/material.dart';

class CreateRouteScreen extends StatefulWidget {
  const CreateRouteScreen({super.key});

  @override
  State<CreateRouteScreen> createState() => _CreateRouteScreenState();
}

class _CreateRouteScreenState extends State<CreateRouteScreen> {
  final _carPlateController = TextEditingController();
  final _destinationController = TextEditingController();
  final _vehicleCapacityController = TextEditingController();
  bool _isLoading = false;

  void shareDestination(
      String carPlate, String destinationName, int capacity) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String res = await FireStoreMethods()
          .uploadDestination(carPlate, destinationName, capacity);
      if (res == "success") {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Rota Paylaşıldı"),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Hata"),
          ),
        );
      }
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Hata"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                const Image(
                  width: 200,
                  image: AssetImage("assets/Havelsan_logo.svg.png"),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: _carPlateController,
                  hintText: "Araba Plakası",
                  isObscure: false,
                ),
                MyTextField(
                  controller: _destinationController,
                  hintText: "Güzargah İsmi",
                  isObscure: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: _vehicleCapacityController,
                  hintText: "Araç Kapasitesi",
                  isObscure: false,
                ),
                const SizedBox(height: 25),
                ButtonLarge(
                  title: "Rotayı Paylaş",
                  onTapFunction: () => shareDestination(
                    _carPlateController.text.trim(),
                    _destinationController.text.trim(),
                    int.parse(_vehicleCapacityController.text.trim()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
