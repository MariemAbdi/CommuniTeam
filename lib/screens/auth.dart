import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:communiteam/screens/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'homepage.dart';

class Auth extends StatelessWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          //USER IS LOGGED IN
          if(snapshot.hasData){
            return const HomePage();
          }
          return const LoginScreen();
        },

      ),
    );
  }
}