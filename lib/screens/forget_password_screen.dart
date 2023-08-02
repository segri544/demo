// Authors: Berke GÜREL

// This page is not using by app (but it will - should be)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future resetPassword() async {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TextFormField(
              controller: emailController,
            ),
            const SizedBox(height: 25),
            ElevatedButton(
                onPressed: resetPassword, child: const Text("Sifremi Yenile"))
          ],
        ),
      ),
    );
  }
}
