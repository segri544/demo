/// >>>>>> Author: Berke Gürel <<<<<<<
///
import 'package:flutter/material.dart';

// Custom widget for a styled text input field
class MyTextField extends StatelessWidget {
  final TextEditingController controller; // Controller to manage the text input
  final String hintText; // Hint text to be displayed in the text field
  final bool
      isObscure; // Flag to indicate if the text should be obscured (for passwords)
  final Icon?
      icon; // Icon to be displayed as a prefix in the text field (optional)

  // Constructor to receive the controller, hint text, obscured flag, and optional icon
  const MyTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.isObscure,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 25), // Padding around the text field
      child: TextField(
        controller:
            controller, // Assigning the provided text controller to the text field
        obscureText:
            isObscure, // Setting the obscure text flag for password fields

        decoration: InputDecoration(
          // Decoration for the text field's appearance
          prefixIcon:
              icon, // Prefix icon to be displayed (e.g., lock icon for passwords)
          labelText:
              hintText, // Label text to be displayed above the text field
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ), // Border style when the field is not focused
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ), // Border style when the field is focused
          fillColor: Colors.grey.shade200, // Background color of the text field
          filled:
              true, // Set to true to fill the background with the specified color
          hintText:
              hintText, // The hint text to be displayed when the field is empty
          hintStyle: TextStyle(
            color: Colors.grey[500], // The color of the hint text
          ),
        ),
      ),
    );
  }
}
