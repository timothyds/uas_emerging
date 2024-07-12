import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Propose extends StatefulWidget {
  final int petId;

  Propose({required this.petId});

  @override
  _ProposeState createState() => _ProposeState();
}

class _ProposeState extends State<Propose> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  Future<void> submitProposal() async {
    if (_formKey.currentState?.validate() ?? false) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');
      final description = _descriptionController.text;

      final response = await http.post(
        Uri.parse("https://ubaya.me/flutter/160421125/propose.php"),
        body: {
          'pet_id': widget.petId.toString(),
          'user_id': userId,
          'description': description,
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['result'] == 'success') {
          Navigator.pop(context); // Go back to the BrowseScreen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Proposal failed: ${result['message']}')));
        }
      } else {
        throw Exception('Failed to submit proposal');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Propose Adoption'),
        backgroundColor: Colors.greenAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitProposal,
                child: Text('Submit Proposal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
