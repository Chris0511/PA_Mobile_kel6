import 'package:aplikasi_kuis/formRegisLogin/Login.dart';
import 'package:aplikasi_kuis/screens/crud_screen.dart';
import 'package:aplikasi_kuis/screens/pilihkuis_screen.dart';
import 'package:aplikasi_kuis/screens/profil_screen.dart';
import 'package:aplikasi_kuis/ui/shared/color.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatelessWidget {
  Home({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondaryColor,
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0), // Adjust the padding here

        // Container with white border
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white), // Border styling
          borderRadius:
              BorderRadius.circular(8.0), // Optional: Adjust border radius
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "Kuis App",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),

            // Image widget for quiz.jpg
            Image.asset(
              'assets/quiz.jpg',
              height: 300,
              width: 500,
              fit: BoxFit.cover,
            ),

            SizedBox(height: 16),

            Expanded(
              child: Center(
                child: RawMaterialButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PilihKuisScreen(),
                      ),
                    );
                  },
                  shape: StadiumBorder(),
                  fillColor: AppColor.primaryColor,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 24.0,
                    ),
                    child: Text(
                      "Mulai Kuis",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColor.secondaryColor,
              ),
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      var userData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      String username = userData['username'] ?? 'Your Name';
                      String email =
                          userData['email'] ?? 'your.email@example.com';

                      return Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                AssetImage('assets/foto_profil.jpg'),
                          ),
                          Text(
                            username,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            email,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Handle the case where user data is not available
                      return Text('Error loading user data');
                    }
                  } else {
                    // Handle the case where the stream is still connecting
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Home(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Buat Kuis'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CrudScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                Navigator.pop(context); // Tutup drawer terlebih dahulu
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  // Gunakan pushReplacement agar tidak bisa kembali ke halaman sebelumnya
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Login(), // Ganti dengan halaman login atau halaman lain yang diinginkan
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
