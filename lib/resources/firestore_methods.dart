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

  //DELETE CHANNEL
  Future<void> deleteCanal(String teamID, String channelId) {
    // Call the  CollectionReference to delete the document
    return teams.doc(teamID)
        .collection('channels')
        .doc(channelId)
        .delete()
        .then((value) => debugPrint("Canal Deleting success"))
        .catchError((error) => print("Erreur lors de la suppression du canal: $error"));
  }

  Future<void> editCanal(String teamId, String channelId, String newName) {

    if (newName.isEmpty) {
      print('name can not be empty');
      return Future.error('name can not be empty');
    }

    CollectionReference channel = FirebaseFirestore.instance.collection('teams').doc(teamId).collection('channels');
    DocumentReference channelDoc = channel.doc(channelId);

    return channelDoc.update({'name': newName}).then((value) => print('updating success'))
        .catchError((error) => print('Error when updating name: $error'));
  }



}