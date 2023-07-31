import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/screens/profile_edit_screen.dart';
import 'package:demo_app/screens/create_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/screens/track_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  bool isLoading = true;

  void getData() async {
    //get user data
    var userSnap = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    userData = userSnap.data()!;
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            )
          : StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection("users").snapshots(),
              builder: (context, snapshot) {
                return SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          userData["position"],
                          style: const TextStyle(fontSize: 25),
                        ),
                        const SizedBox(height: 20),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${userData["name"]} ${userData["lastName"]}",
                              style: const TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text(userData["email"]),
                        const SizedBox(height: 10),
                        Text(
                          userData["position"] != "Şöför"
                              ? userData["address"] ?? "Adres Tanımlı Değil"
                              : userData["vehiclePlate"] ??
                                  "Plaka Tanımlı Değil",
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProfileEditScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                side: BorderSide.none,
                                shape: const StadiumBorder()),
                            child: const Text(
                              "Edit Profile",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        userData["position"] == "Şöför"
                            ? ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => CreateRoutePage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    side: BorderSide.none,
                                    shape: const StadiumBorder()),
                                child: const Text(
                                  "Rota Oluştur",
                                  style: TextStyle(color: Colors.black),
                                ),
                              )
                            : const SizedBox(),
                        const SizedBox(height: 10),
                        const Divider(),
                        const SizedBox(height: 10),
                        Container(
                          height: 250,
                          width: 300,
                          child: ListView.builder(
                            itemCount: userData["likedDestination"].length,
                            itemBuilder: (context, index) {
                              final likedDestination =
                                  userData["likedDestination"][index];
                              return userData["likedDestination"].length == 0
                                  ? const Column(
                                      children: [
                                        Center(
                                          child: Text(
                                            "Favori Rotanız Bulunamadı",
                                            style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red),
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        CircleAvatar(
                                          radius: 35,
                                          child: Icon(
                                            Icons.search,
                                            size: 35,
                                          ),
                                        )
                                      ],
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Card(
                                        elevation: 15,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage(
                                                    "assets/bus_logo.jpg"),
                                                opacity: 0.2,
                                              ),
                                              color: Colors.white),
                                          height: 150,
                                          child: Padding(
                                            padding: const EdgeInsets.all(15),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Text(
                                                      userData["likedDestination"]
                                                              [index] ??
                                                          "Favori Rotanız bulunmamaktaıdr",
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 25,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                            },
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            FirebaseAuth.instance.signOut();
                          },
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.red.withOpacity(0.8),
                              ),
                              child: const Icon(
                                Icons.exit_to_app,
                                color: Colors.white,
                              ),
                            ),
                            title: const Text("Çıkış Yap"),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
