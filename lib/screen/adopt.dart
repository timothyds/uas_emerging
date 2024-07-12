import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uas_project/class/pet.dart';

class AdoptScreen extends StatefulWidget {
  @override
  _AdoptScreenState createState() => _AdoptScreenState();
}

class _AdoptScreenState extends State<AdoptScreen> {
  late Future<List<Pet>> futurePets;

  @override
  void initState() {
    super.initState();
    futurePets = fetchPets();
  }

  Future<List<Pet>> fetchPets() async {
    final response = await http.get(Uri.parse('https://ubaya.me/flutter/160421125/get_pets.php'));

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      List jsonResponse = json.decode(response.body)['data'];
      return jsonResponse.map((pet) => Pet.fromJson(pet)).toList();
    } else {
      throw Exception('Failed to load pets: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adopt'),
        backgroundColor: Colors.greenAccent,
      ),
      body: FutureBuilder<List<Pet>>(
        future: futurePets,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(child: Text('Failed to load pets'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No pets found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Pet pet = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading: Image.network(pet.photoUrl, width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(pet.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pet.description),
                        Text(pet.adoptedBy.toString()),
                        SizedBox(height: 5),
                        Text('Status: ${pet.status}', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
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
