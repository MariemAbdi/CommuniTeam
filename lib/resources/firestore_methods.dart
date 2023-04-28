import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreMethods{
  // Create a CollectionReference called users that references the firestore collection
  CollectionReference teams = FirebaseFirestore.instance.collection('teams');

  //CREATE NEW TEAM
  Future<void> addTeam(String teamName) {
    // Call the  CollectionReference to add a new document
    return teams.add({
      'name': teamName,
      'members': [],
    });
  }

  //CREATE NEW CHANNEL
  Future<void> addCanal(String teamID, String channelName, bool isPrivate, String owner) {
    CollectionReference channel = teams.doc(teamID).collection("channels");
    // Call the  CollectionReference to add a new document
    return channel.add({
      'name': channelName,
      'private': isPrivate,
      'members': [owner],
    }).then((documentSnapshot) => debugPrint("Added Data with ID: ${documentSnapshot.id}"));
  }
}