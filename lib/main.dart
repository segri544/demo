/// >>>>>> Author: Berke Gürel <<<<<<<

// Importing required packages and files
import 'package:demo_app/screens/home_page.dart';
import 'package:demo_app/screens/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// Main function to run the app
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase - mandatory
  await Firebase.initializeApp(); //firebase_core

  runApp(const MyApp());
}

// The main app widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Defining the app's theme
      theme: ThemeData(
        // primarySwatch: Colors.red, // You can set the primary color if needed
        appBarTheme: const AppBarTheme(
            color: Color.fromARGB(255, 16, 99,
                166)), // Setting the color for the app bar blue of HAVELSAN
      ),
      debugShowCheckedModeBanner:
          false, // Disabling the debug banner in the app

      // Defining the app's home page using StreamBuilder
      home: StreamBuilder<User?>(
        // The stream to listen to the user authentication state changes
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If statement below checks if the user is logged in or not and returns the corresponding page
          if (snapshot.connectionState == ConnectionState.waiting) {
            // If the connection state is waiting, show a progress indicator
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // If there is an error in the snapshot, display the error message
            return Text('Error: ${snapshot.error}');
          } else {
            // If there is no error and data is available in the snapshot
            if (snapshot.hasData && snapshot.data != null) {
              // User is logged in, show the HomePage
              return HomePage();
            } else {
              // User is not logged in, show the LoginPage
              return LoginPage();
            }
          }
        },
      ),
    );
  }
}
