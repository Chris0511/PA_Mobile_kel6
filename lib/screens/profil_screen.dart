import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilScreen extends StatefulWidget {
  @override
  _ProfilScreenState createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  String _username = "";
  String _email = "";
  String _fotoProfil = "assets/foto_profil.jpg";

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the screen initializes
  }

  Future<void> _loadUserData() async {
    // Get the current user ID
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    // Check if the user is signed in
    if (userId != null) {
      // Fetch user data from Firestore
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      // Update the state with the fetched data
      setState(() {
        _username = userSnapshot['username'];
        _email = userSnapshot['email'];
        // Assuming 'username' and 'email' are the fields in your 'users' collection
      });

      // Update the controller texts
      _usernameController.text = _username;
      _emailController.text = _email;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(_fotoProfil),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Nama (Username)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Validate the form
                  if (_formKey.currentState?.validate() ?? false) {
                    // If the form is valid, save changes
                    _saveProfileChanges();
                  }
                },
                child: Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProfileChanges() async {
    // Get the current user ID
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    // Check if the user is signed in
    if (userId != null) {
      // Update user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'username': _usernameController.text,
        'email': _emailController.text,
      });

      // Update the state with the new data
      setState(() {
        _username = _usernameController.text;
        _email = _emailController.text;
      });

      // Show an alert dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Perubahan Profil'),
            content: Text('Perubahan profil disimpan!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
