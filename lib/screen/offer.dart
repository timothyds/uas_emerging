import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_project/class/pet.dart';
import 'package:uas_project/screen/decision.dart';
import 'package:uas_project/screen/editoffer.dart';
import 'package:uas_project/screen/newoffer.dart';
import 'dart:convert';

class OfferScreen extends StatefulWidget {
  @override
  _OfferScreenState createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  late Future<List<Pet>> futurePets;

  @override
  void initState() {
    super.initState();
    futurePets = _fetchUserOffers();
  }

  Future<List<Pet>> _fetchUserOffers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

    final response = await http.post(
      Uri.parse("https://ubaya.me/flutter/160421125/myoffer.php"),
      body: {'user_id': userId},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse['result'] == 'success') {
        List<dynamic> petsJson = jsonResponse['data'];
        return petsJson.map((json) => Pet.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load offers: ${jsonResponse['message']}');
      }
    } else {
      throw Exception('Failed to fetch data from API');
    }
  }

  Future<void> _deleteOffer(int petId) async {
    final response = await http.post(
      Uri.parse("https://ubaya.me/flutter/160421125/delete_offer.php"),
      body: {'pet_id': petId.toString()},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse['result'] == 'success') {
        setState(() {
          futurePets = _fetchUserOffers(); // Refresh the list
        });
      } else {
        throw Exception('Failed to delete offer: ${jsonResponse['message']}');
      }
    } else {
      throw Exception('Failed to fetch data from API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Offers'),
        backgroundColor: Colors.greenAccent,
      ),
      body: FutureBuilder<List<Pet>>(
        future: futurePets,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No offers found.'));
          } else {
            final pets = snapshot.data!;
            return ListView.builder(
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                return PetCard(
                  pet: pet,
                  onDelete: _deleteOffer,
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewOfferScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.greenAccent,
      ),
    );
  }
}

class PetCard extends StatelessWidget {
  final Pet pet;
  final Future<void> Function(int petId) onDelete;

  PetCard({required this.pet, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            pet.photoUrl,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              pet.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              pet.description,
              style: TextStyle(fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  'Interested: ${pet.interestedCount}',
                  style: TextStyle(fontSize: 16),
                ),
                Spacer(),
                if (pet.status == 'proposed')
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditOfferScreen(pet: pet),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteConfirmationDialog(context, pet.petId);
                        },
                      ),
                    ],
                  ),
                if (pet.status == 'proposed')
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DecisionScreen(pet: pet),
                        ),
                      );
                    },
                    child: Text('Choose Adopter'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int petId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Offer'),
          content: Text('Are you sure you want to delete this offer?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete(petId); // Call the delete function
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
