import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String email;
  final String name;
  final String photoURL;
  final String uid;

  UserModel({
    required this.email,
    required this.name,
    required this.photoURL,
    required this.uid,
  });

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      email: user.email ?? '',
      name: user.displayName ?? '',
      photoURL: user.photoURL ?? '',
      uid: user.uid,
    );
  }
}
