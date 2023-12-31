import 'package:aplikasi_kuis/formRegisLogin/Login.dart';
import 'package:aplikasi_kuis/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_kuis/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kuis App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Menampilkan indikator loading jika masih menunggu status otentikasi
            return CircularProgressIndicator();
          }

          if (snapshot.hasData) {
            // Pengguna sudah masuk, arahkan ke halaman Home
            return Home();
          } else {
            // Pengguna belum masuk, arahkan ke halaman Login
            return Login();
          }
        },
      ),
    );
  }
}
