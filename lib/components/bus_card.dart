import 'package:flutter/material.dart';

class BusCard extends StatelessWidget {
  final String busId;
  const BusCard({super.key, required this.busId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        height: 150,
        color: Colors.blue[300],
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    busId,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bus_alert_rounded,
                        size: 50,
                        color: Colors.white,
                      ),
                      SizedBox(width: 15),
                      Text("HAVELSAN teknoloji kampüsü - Çankaya")
                    ],
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Şöför : Selim"),
                      SizedBox(width: 15),
                      Text("Araç Kapasitesi : 18/24")
                    ],
                  ),
                ],
              ),
              const VerticalDivider(
                color: Colors.white,
                thickness: 2,
              ),
              const Icon(
                Icons.favorite,
                color: Colors.pink,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
