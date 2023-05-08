import 'package:cloud_firestore/cloud_firestore.dart';

class Team{
  final String id;
  final String name;
  final String defaultCanal;
  final List<String> members;

  Team({this.id = "", required this.name, this.defaultCanal="", this.members = const []});

  Map<String,dynamic> toJson()=>{
    'id': id,
    'name': name,
    'defaultCanal': defaultCanal,
    'members': members,
  };

  static Team fromJson(Map<String,dynamic> json){
    return Team(
      id: json['id'],
      name: json['name'],
      defaultCanal: json['defaultCanal'],
      members: json['members'].cast<String>(),
    );
  }
}

