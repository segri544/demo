// Author: Berke GÜREL

import 'package:demo_app/screens/bus_list_screen.dart';
import 'package:demo_app/screens/map_screen.dart';
import 'package:demo_app/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0; // Variable to track the index of the selected tab
  final titles = const ["Servis Listesi", "Profil"]; // Titles for each tab
  final screens = const [
    BusListScreen(),
    ProfileScreen()
  ]; // Screens for each tab

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance
        .currentUser; // Get the current user from Firebase Authentication
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 8,
        toolbarHeight: 60,
        title: Text(
          titles[selectedIndex], // Display the title based on the selected tab
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 16, 99, 166),
                Colors.blue
              ], // Gradient for the app bar
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: screens[
            selectedIndex], // Display the selected screen based on the selected tab
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  MapScreen(), // Navigate to the MapScreen when the floating action button is pressed
            ),
          );
        },
        child: const Icon(
          Icons.map,
          size: 40,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            selectedIndex =
                index; // Update the selected index when a tab is tapped
          });
        },
        currentIndex: selectedIndex, // Set the current selected tab index
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: "Liste"), // Bottom navigation bar items
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil")
        ],
      ),
    );
  }
}
