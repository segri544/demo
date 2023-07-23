import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'track_page.dart'; // Import the TrackPage

class ListRoutesPage extends StatefulWidget {
  @override
  _ListRoutesPageState createState() => _ListRoutesPageState();
}

class _ListRoutesPageState extends State<ListRoutesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Routes'),
        backgroundColor: Colors.grey,
        titleTextStyle: TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
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
                final documentId = documents[index].id; // Get the document ID
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    child: ListTile(
                      title: Text(documentId),
                      // Add any other UI elements you want to display for each document
                      onTap: () {
                        // Navigate to the TrackPage and pass the document ID
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TrackPage(documentId: documentId),
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
