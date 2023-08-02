// Author: Berke GÜREL

import 'package:demo_app/components/button_large.dart';
import 'package:demo_app/components/my_textfield.dart';
import 'package:demo_app/resources/auth_method.dart';
import 'package:demo_app/screens/signup_screen.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController =
      TextEditingController(); // Controller for email text field
  final _passwordController =
      TextEditingController(); // Controller for password text field
  bool _isLoading = false; // Variable to track the loading state during login

  void logInUser() async {
    setState(() {
      _isLoading = true; // Show loading indicator while logging in
    });

    // Call the logInUser method from AuthMethods to log in the user
    String res = await AuthMethods().logInUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim());

    if (mounted) {
      setState(() {
        _isLoading =
            false; // Hide loading indicator after login process is complete
      });
    }

    // Show a snackbar with an error message if login is not successful
    if (res != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Email veya Şifre yanlış Girilmiştir"),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _emailController
        .dispose(); // Dispose of the email text field controller to avoid memory leaks
    _passwordController
        .dispose(); // Dispose of the password text field controller to avoid memory leaks
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(
                  color: Color.fromARGB(255, 16, 99,
                      166)) // Show a circular progress indicator while loading
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      const Image(
                        width: 300,
                        image: AssetImage(
                            "assets/Havelsan_logo.svg.png"), // Display the HAVELSAN logo image
                      ),
                      Text(
                        "HAVELSAN Personel Servis Takip Sistemi", // Display the app title
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 25),
                      MyTextField(
                        controller:
                            _emailController, // Pass the email text field controller to the custom text field
                        hintText:
                            "E-mail", // Display a hint text for the email text field
                        icon: const Icon(Icons
                            .person_2_outlined), // Display an icon for the email text field
                        isObscure:
                            false, // Set the obscure flag to false as it is not a password field
                      ),
                      const SizedBox(height: 10),
                      MyTextField(
                        controller:
                            _passwordController, // Pass the password text field controller to the custom text field
                        hintText:
                            "Password", // Display a hint text for the password text field
                        icon: const Icon(Icons
                            .lock), // Display an icon for the password text field
                        isObscure:
                            true, // Set the obscure flag to true as it is a password field
                      ),
                      const SizedBox(height: 10),
                      const SizedBox(height: 25),
                      ButtonLarge(
                          title: "Giriş Yap",
                          onTapFunction:
                              logInUser), // Display a large button for login with the logInUser function as the onTapFunction
                      const SizedBox(height: 50),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Üye Değil Misiniz?", // Display a text indicating user registration
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SignUpScreen(), // Navigate to the SignUpScreen when the "Kaydol" button is pressed
                                ),
                              );
                            },
                            child: const Text(
                              "Kaydol", // Display the text "Kaydol" on the button
                              style: TextStyle(
                                  color: Color.fromARGB(255, 16, 99, 166)),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
