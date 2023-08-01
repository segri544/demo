/// >>>>>> Author: Berke Gürel <<<<<<<
import 'package:flutter/material.dart';

// Custom widget for a large button with a title
class ButtonLarge extends StatelessWidget {
  final Function()?
      onTapFunction; // Function to be called when the button is tapped
  final String title; // The title/text to be displayed on the button

  // Constructor to receive the function and title as parameters
  const ButtonLarge(
      {Key? key, required this.onTapFunction, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // GestureDetector to detect the tap on the button
      onTap:
          onTapFunction, // The function to be called when the button is tapped
      child: Container(
        // Container to define the appearance of the button
        margin: const EdgeInsets.symmetric(
            horizontal: 25), // Margin around the button
        padding: const EdgeInsets.all(25), // Padding inside the button
        decoration: BoxDecoration(
          // Decoration to style the button's appearance
          color: const Color.fromARGB(
              255, 16, 99, 166), // Background color of the button
          borderRadius:
              BorderRadius.circular(8), // Border radius for rounded corners
        ),
        child: Center(
          // Center widget to center the title text within the button
          child: Text(
            title, // The title text to be displayed on the button
            style: const TextStyle(
              color: Colors.white, // Text color (white)
              fontWeight: FontWeight.bold, // Text font weight (bold)
            ),
          ),
        ),
      ),
    );
  }
}
