import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/screens/profile_edit_screen.dart';
import 'package:demo_app/screens/create_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors
                                .blue, // Customize the background color here
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.person,
                                size: 65,
                                color: Colors.white70,
                              ),
                              Text(
                                "${userData['position']} - ${userData['name']} ${userData['lastName']}",
                                style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                userData["email"],
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                userData["position"] != "Şöför"
                                    ? userData["address"] ??
                                        "Adres Tanımlı Değil"
                                    : userData["vehiclePlate"] ??
                                        "Plaka Tanımlı Değil",
                                style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Favori Rotalar",
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 25),
                        userData["likedDestinations"] == null ||
                                userData["likedDestinations"].length == 0
                            ? const Column(
                                children: [
                                  Text("Favori Rota Bulunamadı"),
                                  Icon(
                                    Icons.not_listed_location_outlined,
                                    size: 86,
                                  )
                                ],
                              )
                            : Container(
                                height: 200,
                                width: 300,
                                child: ListView.builder(
                                  itemCount: userData["likedDestinations"] ==
                                          null
                                      ? 0
                                      : userData["likedDestinations"].length,
                                  itemBuilder: (context, index) {
                                    return userData["likedDestinations"]
                                                .length ==
                                            0
                                        ? const Column(
                                            children: [
                                              Center(
                                                child: Text(
                                                  "Favori Rotanız Bulunamadı",
                                                  style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                  padding:
                                                      const EdgeInsets.all(15),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          Text(
                                                            userData["likedDestinations"]
                                                                    [index] ??
                                                                "Favori Rotanız bulunmamaktaıdr",
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 25,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                        const Divider(),
                        //--- Edit Profile---
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProfileEditScreen(),
                              ),
                            );
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
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),
                            title: const Text("Profili Düzenle"),
                          ),
                        ),
                        //--Rota Oluştur--
                        userData["position"] == "Şöför"
                            ? InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => CreateRoutePage(),
                                    ),
                                  );
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
                                      Icons.create,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: const Text("Rota Oluştur"),
                                ),
                              )
                            : SizedBox(),
                        //-----Çıkış Yap-----
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
