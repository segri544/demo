import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import the Firestore plugin
import 'package:google_mao/screens/track_page.dart';

class ListRoutesPage extends StatefulWidget {
  @override
  _ListRoutesPageState createState() => _ListRoutesPageState();
}

class _ListRoutesPageState extends State<ListRoutesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('List Routes')),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('Maps')
            .get(), // Fetch the documents from the "Maps" collection
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for data to load, display a loading indicator
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // If there's an error, display an error message
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // If data is available, display the list of document IDs
            final documents = snapshot.data!.docs;
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                // Build a widget for each document in the collection
                final documentData =
                    documents[index].data() as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    child: ListTile(
                      title: Text(documents[index].id),
                      // Add any other UI elements you want to display for each document
                      onTap: () {
                        // Navigate to the TrackPage and pass the document data
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TrackPage(documentData: documentData),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
