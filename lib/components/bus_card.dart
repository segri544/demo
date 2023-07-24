import 'package:flutter/material.dart';

class BusCard extends StatelessWidget {
  final String carPlate;
  const BusCard({super.key, required this.carPlate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 15,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/bus_logo.jpg"), opacity: 0.2),
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
                      carPlate,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text("HAVELSAN teknoloji kampüsü - Çankaya")],
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
                  thickness: 2,
                ),
                const Icon(
                  Icons.favorite_border,
                  color: Colors.pink,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
