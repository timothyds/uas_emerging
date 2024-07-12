import 'package:flutter/material.dart';
import 'package:uas_project/class/pet.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uas_project/screen/propose.dart';

class BrowseScreen extends StatefulWidget {
  @override
  _BrowseScreenState createState() => _BrowseScreenState();
}
// Future<List<Pet>> fetchAvailablePets() async {
//   final response = await http.get(Uri.parse("https://ubaya.me/flutter/160421125/petlist.php"));

//   if (response.statusCode == 200) {
//     List<dynamic> data = jsonDecode(response.body);
//     return data
//         .where((item) => item['status'] == 'new')
//         .map((item) => Pet.fromJson(item))
//         .toList();
//   } else {
//     throw Exception('Failed to load pets');
//   }
// }
Future<List<Pet>> fetchAvailablePets() async {
  final response = await http.get(Uri.parse("https://ubaya.me/flutter/160421125/petlist.php"));

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    if (jsonResponse['result'] == 'success') {
      List<dynamic> petsJson = jsonResponse['data'];
      return petsJson.map((json) => Pet.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load pets: ${jsonResponse['message']}');
    }
  } else {
    throw Exception('Failed to fetch data from API');
  }
}
class _BrowseScreenState extends State<BrowseScreen> {
  late Future<List<Pet>> futurePets;

  @override
  void initState() {
    super.initState();
    futurePets = fetchAvailablePets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Browse Animals'),
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
            return Center(child: Text('No animals available for adoption.'));
          } else {
            final pets = snapshot.data!;
            return ListView.builder(
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                return AnimalCard(pet: pet);
              },
            );
          }
        },
      ),
    );
  }
}

class AnimalCard extends StatelessWidget {
  final Pet pet;

  AnimalCard({required this.pet});

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
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Propose(petId: pet.petId),
                      ),
                    );
                  },
                  child: Text('Propose'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
