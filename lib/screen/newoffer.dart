import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewOfferScreen extends StatefulWidget {
  @override
  _NewOfferScreenState createState() => _NewOfferScreenState();
}

class _NewOfferScreenState extends State<NewOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  String _species = '';
  String _name = '';
  String _photoUrl = '';
  String _description = '';

  void _submitOffer() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');
      final response = await http.post(
        Uri.parse("https://ubaya.me/flutter/160421125/new_offer.php"),
        body: {
          'species': _species,
          'name': _name,
          'photo_url': _photoUrl,
          'description': _description,
          'owner_id': userId, 
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['result'] == 'success') {
          Navigator.pop(context); // Return to Offer screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add offer: ${jsonResponse['message']}')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit offer')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Offer'),
        backgroundColor: Colors.greenAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Species'),
                validator: (value) => value!.isEmpty ? 'Please enter species' : null,
                onChanged: (value) => _species = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Name (optional)'),
                onChanged: (value) => _name = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Photo URL'),
                validator: (value) => value!.isEmpty ? 'Please enter photo URL' : null,
                onChanged: (value) => _photoUrl = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Please enter description' : null,
                onChanged: (value) => _description = value,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitOffer,
                child: Text('Submit Offer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
