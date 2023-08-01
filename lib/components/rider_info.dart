/// >>>>>> Author: Berke Gürel <<<<<<<

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../resources/constants.dart'; // Importing custom constants (e.g., defaultPadding, primaryColor)

// Custom widget for displaying rider information
class RiderInfo extends StatelessWidget {
  const RiderInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        // Container to hold the rider info section
        color: Colors.white, // Background color of the container
        padding: const EdgeInsets.only(
            top: defaultPadding), // Padding at the top of the container
        child: ListTile(
          // ListTile to organize the rider info items (avatar, name, distance, and chat button)
          leading: const CircleAvatar(
            // Leading widget for the avatar (a circular image)
            radius: 24, // Radius of the circular avatar
            backgroundImage:
                AssetImage("assets/Avatar.png"), // Avatar image asset
          ),
          title: const Text(
            "Mike Rojnidoost", // Rider name displayed as the title text
            style: TextStyle(
              fontWeight:
                  FontWeight.w500, // Font weight for the rider name (medium)
            ),
          ),
          subtitle: const Text(
              "860m - 28min"), // Rider's distance and time displayed as the subtitle text
          trailing: ElevatedButton(
            // Trailing widget for the chat button
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  primaryColor, // Background color of the chat button (defined in constants.dart)
              shape: const CircleBorder(), // Shape of the button (a circle)
              minimumSize: const Size(48, 48), // Minimum size of the button
            ),
            onPressed: () {
              // Action to be performed when the chat button is pressed (currently empty)
            },
            child: SvgPicture.asset(
              "assets/icons/chat.svg", // SVG asset for the chat icon
              // ignore: deprecated_member_use
              color: Colors.white, // Color of the chat icon (white)
            ),
          ),
        ),
      ),
    );
  }
}
