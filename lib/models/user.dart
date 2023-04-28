import 'package:cloud_firestore/cloud_firestore.dart';

class User{
  late String nickname;
  late String bio;

  User({required this.nickname, this.bio="Hello World!"});

  Map<String,dynamic> toJson()=>{
    'nickname': nickname,
    'bio': bio,
  };

  static User fromJson(Map<String,dynamic> json){
    return User(
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

//GET A LIST OF ALL THE DOCUMENTS IN THE COLLECTION
Stream<List<User>> getAllUsers()=>
    FirebaseFirestore.instance.collection('users').orderBy('nickname').snapshots().map((snapshot) => snapshot.docs.map((doc) =>
        User.fromJson(doc.data())).toList());
