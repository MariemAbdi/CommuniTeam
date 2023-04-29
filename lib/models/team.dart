import 'package:cloud_firestore/cloud_firestore.dart';

class Team{
  final String id;
  final String name;
  final List<String> members;

  Team({required this.id, required this.name, required this.members});

  Map<String,dynamic> toJson()=>{
    'id': id,
    'name': name,
    'members': members,
  };

  static Team fromJson(Map<String,dynamic> json){
    return Team(
      id: json['id'],
      name: json['name'],
      members: json['members'].cast<String>(),
    );
  }
}

