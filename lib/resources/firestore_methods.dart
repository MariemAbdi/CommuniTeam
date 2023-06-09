import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communiteam/translations/locale_keys.g.dart';
import 'package:communiteam/utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../screens/canal_chat.dart';
import '../screens/homepage.dart';

class FirestoreMethods{
  // Create a CollectionReference called users that references the firestore collection
  CollectionReference teams = FirebaseFirestore.instance.collection('teams');

  //CREATE TEAM
  Future<String> addTeam(BuildContext context, String teamName, String owner) {
    // Call the CollectionReference to add a new document
    return teams.add({
      'name': teamName,
      'members': [owner],
      'defaultCanal': ""
    }).then((value) {
      // Update the id
      teams.doc(value.id).update({
        "id": value.id
      });

      GetStorage getStorage=GetStorage();
      getStorage.write("selectedTeamId",value.id);
      getStorage.write("selectedTeamName", teamName);
      addCanal(context, value.id, "General", false, owner);
      //addGeneralCanal(context,value.id, owner);
      return value.id; // Return the new team ID
    });

  }

  // //CREATE NEW CHANNEL
  // Future<void> addGeneralCanal(BuildContext context, String teamID, String owner) async {
  //   CollectionReference publicCanal = teams.doc(teamID).collection("publicCanals");
  //
  //     await publicCanal.add({
  //       'name': "General",
  //       'owner': owner,
  //     }).then((value) {
  //       //update the id
  //       publicCanal.doc(value.id).update({
  //         "id": value.id
  //       });
  //
  //       //Update the TEAM'S DEFAULT CANAL
  //       teams.doc(teamID).update({
  //         "defaultCanal": value.id
  //       });
  //     });
  //
  // }

  addMemberToTeam(String teamId,String userId ){
    teams.doc(teamId).update({
      "members": FieldValue.arrayUnion([userId])
    });
  }

  addMemberToCanal(String teamId,String canalId,String userId){
    teams.doc(teamId)
        .collection("privateCanals")
        .doc(canalId)
        .update({
       "members": FieldValue.arrayUnion([userId])
    });
  }


  Future<bool> isMemberOfTeam(String teamId, String userId) async {
    final documentSnapshot = await FirebaseFirestore.instance
        .collection('teams')
        .doc(teamId)
        .get();

    final List<dynamic> members = documentSnapshot.data()!['members'];

    return members.contains(userId);
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

        // Update the TEAM'S DEFAULT CANAL
        teams.doc(teamID).update({
          "defaultCanal": value.id
        });

        //GOING TO THE NEW TEAM'S SCREEN
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage(isCanal: true,title: canalName ,canalId:value.id, teamId: teamID, collectionName: 'publicCanals',
            widget: CanalChatScreen( teamId:teamID, canalType:"publicCanals", canalId: value.id, nickName: canalName , ) )
        ));
        customSnackBar(context, LocaleKeys.canalCreatedSuccessfully.tr(), Colors.green);
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
/*
        //Update the TEAM'S DEFAULT CANAL
        teams.doc(teamID).update({
        "defaultCanal": value.id
        });

 */
       // Navigator.pop(context);
      //  Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => HomePage(isCanal: true,title: canalName ,teamId: teamID, canalId: value.id, collectionName: 'privateCanals',
                widget: CanalChatScreen( teamId:teamID, canalType:"privateCanals" , canalId:value.id, nickName: canalName, ),
              )));


        customSnackBar(context, LocaleKeys.canalCreatedSuccessfully.tr(), Colors.green);
      });
    }else{
      WidgetsBinding.instance.addPostFrameCallback((_) {
        //By nesting it in the callback of addPostFrameCallback you are basically saying when the widget is done building,
        // then execute the navigation code.
        customSnackBar(context, LocaleKeys.canalExistsAlready.tr(), Colors.red);
      });
    }
  }


  //DELETE CHANNEL
  Future<void> deleteCanal(BuildContext context, String teamID,String collectionName, String canalID) async {
    try {

      // Supprimer les messages du canal
      QuerySnapshot messagesSnapshot = await teams.doc(teamID)
          .collection(collectionName)
          .doc(canalID)
          .collection("messages")
          .get();

      for (QueryDocumentSnapshot message in messagesSnapshot.docs) {
        await message.reference.delete();
      }


      await teams.doc(teamID).collection(collectionName).doc(canalID).delete();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        //By nesting it in the callback of addPostFrameCallback you are basically saying when the widget is done building,
        // then execute the navigation code.
        customSnackBar(context, LocaleKeys.canalSuccessfullyDeleted.tr(), Colors.red);
      });
    } catch (error) {
      debugPrint("ERROR: $error");
    }
  }

  //DELETE TEAM
  Future<void> deleteTeam(BuildContext context, String teamID) async {
    try {

      await teams.doc(teamID).delete();

      QuerySnapshot privateCanalsSnapshot = await teams.doc(teamID).collection("privateCanals").get();
      for (QueryDocumentSnapshot canal in privateCanalsSnapshot.docs) {
        // Supprimer les messages du canal privé
        QuerySnapshot messagesSnapshot = await canal.reference.collection("messages").get();
        for (QueryDocumentSnapshot message in messagesSnapshot.docs) {
          await message.reference.delete();
        }

        // Supprimer le canal privé
        await canal.reference.delete();
      }

      // Supprimer les canaux publics
      QuerySnapshot publicCanalsSnapshot =
      await teams.doc(teamID).collection("publicCanals").get();
      for (QueryDocumentSnapshot canal in publicCanalsSnapshot.docs) {
        String canalId = canal.id;

        // Supprimer les messages du canal public
        QuerySnapshot messagesSnapshot = await canal.reference.collection("messages").get();
        for (QueryDocumentSnapshot message in messagesSnapshot.docs) {
          await message.reference.delete();
        }

        // Supprimer le canal public
        await canal.reference.delete();
      }

      // Afficher un message de succès
    } catch (error) {
      debugPrint("ERROR: $error");
    }
  }


  Future<void> editCanal(BuildContext context,String teamId, String channelId,String collectionName,String newName) async{
    DocumentReference channelDoc = teams.doc(teamId).collection(collectionName).doc(channelId);

    return channelDoc.update({'name': newName}).then((value) => customSnackBar(context, LocaleKeys.canalRenamedSuccessfully.tr(), Colors.green))
        .catchError((error) => debugPrint('Error when updating name: $error'));
  }
}


