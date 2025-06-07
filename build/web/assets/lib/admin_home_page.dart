import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  Future<void> _createGame(BuildContext context, String gameName, String shortDescription, String longDescription , String prizeMoney , String entryFee , String limit , String link) async {
    try {
      // Reference to the matches collection
      CollectionReference matches = FirebaseFirestore.instance.collection('matches');

      // Add a new document with the form data
      await matches.add({
        'gameName': gameName,
        'shortDescription': shortDescription,
        'longDescription': longDescription,
        'createdAt': FieldValue.serverTimestamp(), // Optional: add timestamp
        'prizeMoney': prizeMoney,
        'entryFee': entryFee,
        'limit': limit,
        'link': link,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Game created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating game: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameName = TextEditingController();
    final shortDescription = TextEditingController();
    final longDescription = TextEditingController();
    final regestrationFee = TextEditingController();
    final winningPrize = TextEditingController();
    final limit = TextEditingController();
    final link = TextEditingController();

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Admin Panel",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: gameName,
                  decoration: const InputDecoration(
                    hintText: "Game Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: shortDescription,
                  decoration: const InputDecoration(
                    hintText: "Short Description",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: longDescription,
                  decoration: const InputDecoration(
                    hintText: "Long Description",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 100,
                ),
                TextField(
                  controller: regestrationFee,
                  decoration: const InputDecoration(
                    hintText: "Entry fee",
                    border: OutlineInputBorder(),
                  ),
                ),
                TextField(
                  controller: winningPrize,
                  decoration: const InputDecoration(
                    hintText: "Prize Money",
                    border: OutlineInputBorder(),
                  ),
                ),
                TextField(
                  controller: limit,
                  decoration: const InputDecoration(
                    hintText: "limit",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                TextField(
                  controller: link,
                  decoration: const InputDecoration(
                    hintText: "link",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // Validate that fields are not empty
                    if (gameName.text.trim().isEmpty ||
                        shortDescription.text.trim().isEmpty ||
                        longDescription.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all fields'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    // Call the create game function
                    await _createGame(
                      context,
                      gameName.text.trim(),
                      shortDescription.text.trim(),
                      longDescription.text.trim(),
                      winningPrize.text.trim(),
                      regestrationFee.text.trim(),
                      limit.text.trim(),
                      link.text.trim()
                    );

                    // Clear the form after successful submission
                    gameName.clear();
                    shortDescription.clear();
                    longDescription.clear();
                  },
                  child: const Text("Create Game"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}