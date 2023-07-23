import 'package:flutter/material.dart';

class TrackPage extends StatelessWidget {
  final Map<String, dynamic> documentData;

  // Constructor to receive the document data
  TrackPage({required this.documentData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Track Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display all the information from the document dynamically
            for (var entry in documentData.entries)
              Text('${entry.key}: ${entry.value}'),
          ],
        ),
      ),
    );
  }
}
