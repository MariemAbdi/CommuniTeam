import 'package:cloud_firestore/cloud_firestore.dart';

class User{
  late String email;
  late String nickname;
  late String bio;

  User({required this.email, required this.nickname, this.bio="Hello World!"});

  Map<String,dynamic> toJson()=>{
    'email': email,
    'nickname': nickname,
    'bio': bio,
  };

  static User fromJson(Map<String,dynamic> json){
    return User(
      email: json['email'],
      nickname: json['nickname'],
      bio: json['bio'],
    );}

}

Future<void> createUser(User user,String userID) async {
  //REFERENCE TO A DOCUMENT
  final docUser= FirebaseFirestore.instance.collection('users').doc(userID);
  //GET USER
  final docSnapshot = await docUser.get();

  //IF IT DOESN'T EXIST THEN WE ADD IT TO THE FIRESTORE
  if(!docSnapshot.exists) {
    //CREATE DOCUMENT AND WRITE DATA TO FIREBASE
    await docUser.set(user.toJson());
  }

}

