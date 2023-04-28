import 'package:cloud_firestore/cloud_firestore.dart';

class Team{
  final String name;
  final List<String> members;

  Team({required this.name, required this.members});

  Map<String,dynamic> toJson()=>{
    'name': name,
    'members': members,
  };

  static Team fromJson(Map<String,dynamic> json){
    return Team(
      name: json['name'],
      members: json['members'].cast<String>(),
    );
  }
}

//GET A LIST OF ALL THE TEAMS
Stream<List<Team>> getAllTeams()=>
    FirebaseFirestore.instance.collection('teams').orderBy('name').snapshots().map((snapshot) => snapshot.docs.map((doc) => Team.fromJson(doc.data())).toList());