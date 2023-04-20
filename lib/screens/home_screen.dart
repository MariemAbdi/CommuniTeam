import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hello, You are signed in', style: TextStyle(fontSize: 22)),
            Text(user.email!, style: TextStyle(fontSize: 22)),
            MaterialButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                color: const Color.fromARGB(255, 97, 31, 105),
                
                child: Text(
                  'Sign out',
                  style: GoogleFonts.robotoCondensed(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
