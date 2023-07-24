import 'package:demo_app/screens/home_page.dart';
import 'package:demo_app/screens/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); //firebase_core

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //if statement in the bellow check if user loged in
          if (snapshot.hasData) {
            return HomePage();
          } else {
            return LoginPage();
          }
        },
      ),
    );
  }
}
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:demo_app/screens/create_route.dart';
// import 'package:demo_app/screens/ListRoute.dart';

// import 'firebase_options.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     name: "havelsan-auth-map",
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MyApp());
// }

// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.grey,
//         title: Text(
//           'Home Page',
//         ),
//         titleTextStyle: TextStyle(
//             color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 // Navigate to the CreateRoutePage when the button is pressed
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => CreateRoutePage()),
//                 );
//               },
//               child: Text('Create Route'),
//             ),
//             SizedBox(height: 20), // Add some spacing between buttons
//             ElevatedButton(
//               onPressed: () {
//                 // Navigate to the ListRoutesPage when the button is pressed
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => ListRoutesPage()),
//                 );
//               },
//               child: Text('List Routes'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'HAVELSAN ULAŞIM',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.white,
//           elevation: 0,
//         ),
//       ),
//       home: HomePage(),
//     );
//   }
// }
