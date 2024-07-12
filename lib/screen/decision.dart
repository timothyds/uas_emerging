import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uas_project/class/pet.dart';

class DecisionScreen extends StatefulWidget {
  final Pet pet;

  DecisionScreen({required this.pet});

  @override
  _DecisionScreenState createState() => _DecisionScreenState();
}

class _DecisionScreenState extends State<DecisionScreen> {
  late Future<List<Map<String, dynamic>>> futureProposals;

  @override
  void initState() {
    super.initState();
    futureProposals = fetchProposals(widget.pet.petId);
  }

  Future<List<Map<String, dynamic>>> fetchProposals(int petId) async {
    final response = await http.post(
      Uri.parse("https://ubaya.me/flutter/160421125/proposals.php"),
      body: {'pet_id': petId.toString()},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse['result'] == 'success') {
        List<dynamic> proposalsJson = jsonResponse['data'];
        return proposalsJson
            .map((json) => json as Map<String, dynamic>)
            .toList();
      } else {
        throw Exception('Failed to load proposals: ${jsonResponse['message']}');
      }
    } else {
      throw Exception('Failed to fetch data from API');
    }
  }

  void selectAdopter(int proposalId) async {
    final response = await http.post(
      Uri.parse("https://ubaya.me/flutter/160421125/accept_proposal.php"),
      body: {'proposal_id': proposalId.toString()},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse['result'] == 'success') {
        Navigator.pop(context);
      } else {
        throw Exception(
            'Failed to accept proposal: ${jsonResponse['message']}');
      }
    } else {
      throw Exception('Failed to fetch data from API');
    }
  }

  void rejectAdopter(int proposalId) async {
    final response = await http.post(
      Uri.parse("https://ubaya.me/flutter/160421125/reject_proposal.php"),
      body: {'proposal_id': proposalId.toString()},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse['result'] == 'success') {
        setState(() {
          futureProposals =
              fetchProposals(widget.pet.petId); // Refresh proposals
        });
      } else {
        throw Exception(
            'Failed to reject proposal: ${jsonResponse['message']}');
      }
    } else {
      throw Exception('Failed to fetch data from API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Decision for ${widget.pet.name}'),
        backgroundColor: Colors.greenAccent,
      ),
      body: Column(
        children: [
          Image.network(
            widget.pet.photoUrl,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.pet.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.pet.description,
              style: TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: futureProposals,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No proposals yet.'));
                } else {
                  final proposals = snapshot.data!;
                  return ListView.builder(
                    itemCount: proposals.length,
                    itemBuilder: (context, index) {
                      final proposal = proposals[index];
                      return Card(
                        margin: EdgeInsets.all(10),
                        elevation: 5,
                        child: ListTile(
                          title: Text('User ID: ${proposal['user_id']}'),
                          subtitle:
                              Text('Description: ${proposal['description']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    selectAdopter(proposal['proposal_id']),
                                child: Text('Select'),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () =>
                                    rejectAdopter(proposal['proposal_id']),
                                child: Text('Reject'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
