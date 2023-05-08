import 'dart:math';

import 'package:communiteam/resources/firestore_methods.dart';
import 'package:communiteam/services/Theme/custom_theme.dart';
import 'package:communiteam/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user.dart' as user_model;

class FirebaseAuthMethods{
  final FirebaseAuth _auth;
  FirebaseAuthMethods(this._auth);

  User get user => _auth.currentUser!;

  // FOR EVERY FUNCTION HERE
  // POP THE ROUTE USING: Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);

  void popRoute(BuildContext context){
    Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }

  //STATE PERSISTENCE
  Stream<User?> get authState => _auth.authStateChanges();

  //EMAIL & PASSWORD SIGNUP
  Future<void> signUpWithEmailAndPassword({required String nickname, required String email, required String password, required BuildContext context}) async{
    try{
      //SHOW LOADING CIRCLE
      showDialog(context: context, builder: (context){
        return const Center(child: CircularProgressIndicator(color: CustomTheme.darkPurple,),);
      });

      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      user.updateDisplayName(nickname);

      //Create A New User & Add It To The Firestore Database
      user_model.createUser(user_model.User(email: email,nickname:nickname,bio: "Hello World!"), email);

      //ADD THE NEW USER TO THE GLOBAL TEAM CALLED ISET RADES
      FirestoreMethods firestoreMethods =FirestoreMethods();
      firestoreMethods.addMemberToTeam("toBCHluEdzfmeoXhCxQw",email);

      //POP LOADING CIRCLE
      WidgetsBinding.instance.addPostFrameCallback((_) {
        //By nesting it in the callback of addPostFrameCallback you are basically saying when the widget is done building,
        // then execute the navigation code.
        Navigator.pop(context);
      });

    }on FirebaseAuthException catch(e){
        customSnackBar(context, e.message!, Colors.red);
    } catch(e){
      debugPrint(e.toString());
    }
  }


  //EMAIL & PASSWORD LOGIN
  Future<void> signInWithEmailAndPassword({required String email, required String password, required BuildContext context}) async {
    try{
      //SHOW LOADING CIRCLE
      showDialog(context: context, builder: (context){
        return const Center(child: CircularProgressIndicator(color: CustomTheme.darkPurple,),);
      });
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      //POP LOADING CIRCLE
      Navigator.pop(context);

      popRoute(context);

    }on FirebaseAuthException catch(e){
      if (e.code == 'user-not-found') {
        customSnackBar(context, "Error: User Not Found.", Colors.red);
      }else{
        customSnackBar(context, "Error: Please Check Your Credentials", Colors.red);
      }
    } catch(e){
      debugPrint(e.toString());
    }
  }


  //SIGN OUT FROM ANY TYPE OF AUTHENTICATION
  Future<void> signOut(BuildContext context) async{
    try{
      //SHOW LOADING CIRCLE
      showDialog(context: context, builder: (context){
        return const Center(child: CircularProgressIndicator(color: CustomTheme.darkPurple,),);
      });

      await _auth.signOut().whenComplete(()=> popRoute(context));
      //popRoute(context);
    }on FirebaseAuthException catch(e){
      customSnackBar(context, e.message!, Colors.red);
    }
  }

  //SEND RESET PASSWORD EMAIL
  Future<void> resetPassword(BuildContext context, String email) async{
    try{
      await _auth.sendPasswordResetEmail(email: email).whenComplete(() => customSnackBar(context, "The Email Was Sent Successfully", Colors.green));
    }on FirebaseAuthException catch(e){
      customSnackBar(context, e.message!, Colors.red);
    }
  }

}