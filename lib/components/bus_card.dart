/// >>>>>> Author: Berke Gürel <<<<<<<
///
import 'package:demo_app/resources/firestore_method.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// A custom widget to display a bus card
class BusCard extends StatefulWidget {
  final Map<String, dynamic> snap; // Data for the bus card

  // Constructor to receive the data as a parameter
  const BusCard({Key? key, required this.snap}) : super(key: key);

  @override
  State<BusCard> createState() => _BusCardState();
}

class _BusCardState extends State<BusCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 15, // Card elevation (shadow)
        child: Container(
          // Container to hold the bus card content
          decoration: const BoxDecoration(
            // Decoration for the container (image and background color)
            image: DecorationImage(
              image: AssetImage(
                  "assets/bus_logo.jpg"), // Background image for the container
              opacity: 0.2, // Opacity of the background image
            ),
            color: Colors.white, // Background color for the container
          ),
          height: 150, // Height of the container
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Column for the left side content of the bus card
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      widget.snap["sabah"]["name"].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.snap["sabah"]["numberPlate"],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            "Şoför : ${widget.snap["sabah"]["driverName"].toUpperCase()}"),
                        const SizedBox(width: 15),
                        Text("Tel : ${widget.snap["sabah"]["phone"]}"),
                      ],
                    ),
                  ],
                ),
                const VerticalDivider(
                  thickness: 2, // Thickness of the vertical divider
                ),
                // Expanded widget to take the remaining space for the right side content
                Expanded(
                  child: IconButton(
                    onPressed: () async {
                      // Function to handle the like button click and update the likes count
                      await FireStoreMethods().likeDestination(
                          widget.snap["destinationId"],
                          FirebaseAuth.instance.currentUser!.uid,
                          widget.snap["likes"]);
                    },
                    icon: Icon(
                      // Icon based on whether the user has liked the destination or not
                      widget.snap["likes"]
                              .contains(FirebaseAuth.instance.currentUser?.uid)
                          ? Icons
                              .favorite // If liked, show the filled heart icon
                          : Icons
                              .favorite_border, // If not liked, show the empty heart icon
                      color: Colors.red, // Heart icon color (red)
                    ),
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
