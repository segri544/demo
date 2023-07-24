import 'package:demo_app/components/bus_card.dart';
import 'package:flutter/material.dart';

class BusListScreen extends StatelessWidget {
  const BusListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) {
                return const BusCard(busId: "06 ab 015");
              },
            ),
          )
        ],
      ),
    );
  }
}
