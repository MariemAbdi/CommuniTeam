import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communiteam/utils.dart';
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
    }).then((value) {
      //update the id
      teams.doc(value.id).update({
        "id": value.id
      });
    });
  }

  addMemberToTeam(String userId){
    teams.doc("toBCHluEdzfmeoXhCxQw").update({
      "members": FieldValue.arrayUnion([userId])
    });
  }

  //CREATE NEW CHANNEL
  Future<void> addCanal(BuildContext context, String teamID, String canalName, bool isPrivate, String owner) async {
    CollectionReference publicCanal = teams.doc(teamID).collection("publicCanals");
    CollectionReference privateCanal = teams.doc(teamID).collection("privateCanals");

    //-------------------------CHECK IF CANAL EXISTS-------------------------------
    //REFERENCE TO A DOCUMENT
    final docPublicCanal= publicCanal.doc(canalName);
    //GET CANAL
    final docPublicSnapshot = await docPublicCanal.get();

    //REFERENCE TO A DOCUMENT
    final docPrivateCanal= privateCanal.doc(canalName);
    //GET CANAL
    final docPrivateSnapshot = await docPrivateCanal.get();

    //IF IT DOESN'T EXIST THEN WE ADD IT TO THE FIRESTORE
    if(!docPublicSnapshot.exists && !isPrivate) {
      //IF PUBLIC
      await publicCanal.add({
        'name': canalName,
        'owner': owner,
      }).then((value) {
        //update the id
        publicCanal.doc(value.id).update({
          "id": value.id
        });

        customSnackBar(context, "Canal Created Successfully!", Colors.green);
      });
    }else if(!docPrivateSnapshot.exists && isPrivate) {
      //IF PRIVATE
      await privateCanal.add({
        'name': canalName,
        'members': [owner],
      }).then((value) {
        //update the id
        privateCanal.doc(value.id).update({
          "id": value.id
        });

        customSnackBar(context, "Canal Created Successfully!", Colors.green);
      });
    }else{
      customSnackBar(context, "Canal With This Name Exists Already!", Colors.red);
    }
  }

  //DELETE CHANNEL
  Future<void> deleteCanal(BuildContext context,String teamID,String collectionName,String canalId) {
    // Call the  CollectionReference to delete the document
    return teams.doc(teamID)
        .collection(collectionName)
        .doc(canalId)
        .delete()
        .then((value) => customSnackBar(context, "Canal Successfully Deleted!", Colors.green))
        .catchError((error) => debugPrint("ERROR: $error"));
  }


  Future<void> editCanal(BuildContext context,String teamId, String channelId,String collectionName,String newName) async{
    DocumentReference channelDoc = teams.doc(teamId).collection(collectionName).doc(channelId);

    return channelDoc.update({'name': newName}).then((value) => customSnackBar(context, "Canal Was Modified Successfully!", Colors.green))
        .catchError((error) => debugPrint('Error when updating name: $error'));
  }
}


