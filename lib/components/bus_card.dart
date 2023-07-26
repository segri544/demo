import 'package:demo_app/resources/firestore_method.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BusCard extends StatefulWidget {
  final Map<String, dynamic> snap;

  const BusCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<BusCard> createState() => _BusCardState();
}

class _BusCardState extends State<BusCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 15,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bus_logo.jpg"),
              opacity: 0.2,
            ),
          ),
          height: 150,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      widget.snap["sabah"]["numberPlate"],
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
                          widget.snap["sabah"]["name"].toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            "Şöför : ${widget.snap["sabah"]["driverName"].toUpperCase()}"),
                        SizedBox(width: 15),
                        Text("Tel : ${widget.snap["sabah"]["phone"]}"),
                      ],
                    ),
                  ],
                ),
                const VerticalDivider(
                  thickness: 2,
                ),
                IconButton(
                  onPressed: () async {
                    await FireStoreMethods().likeDestination(
                        widget.snap["destinationId"],
                        FirebaseAuth.instance.currentUser!.uid,
                        widget.snap["likes"]);
                  },
                  icon: Icon(
                    widget.snap["likes"]
                            .contains(FirebaseAuth.instance.currentUser?.uid)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.red,
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
