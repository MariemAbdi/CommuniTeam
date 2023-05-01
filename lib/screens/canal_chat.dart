import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../resources/firestore_methods.dart';
import '../services/Theme/custom_theme.dart';
import '../translations/locale_keys.g.dart';
import '../widgets/canalMessage_textfield.dart';

import '../widgets/singlemessage_canal.dart';
import 'package:fluttertoast/fluttertoast.dart';


class CanalChatScreen extends StatefulWidget {
  final String teamId;
  final String canalType;
  final String canalId;
  final String nickName;

  const CanalChatScreen({super.key, required this.teamId,required this.canalType,required this.canalId,required this.nickName});

  @override
  State<CanalChatScreen> createState() => _CanalChatScreenState();
}

class _CanalChatScreenState extends State<CanalChatScreen> {

  late User currentUser;
  List<dynamic> allUsers =[];

  getCanalUsers(String teamId, String canalType, String canalId) async {
    if (canalType == "privateCanals") {
      final canalSnapshot = await FirebaseFirestore.instance
          .collection("teams")
          .doc(teamId)
          .collection(canalType)
          .doc(canalId)
          .get();

      if (canalSnapshot.exists) {
        final List<dynamic> members = canalSnapshot.data()!['members'];

        for (int i = 0; i < members.length; i++) {
          var userId = members[i];
          var data = await FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .get();

          allUsers.add(data);
          setState(() {});
        }
      }
    } else {
      final canalSnapshot = await FirebaseFirestore.instance
          .collection("teams")
          .doc(teamId)
          .get();

      if (canalSnapshot.exists) {
        final List<dynamic> members = canalSnapshot.data()!['members'];

        for (int i = 0; i < members.length; i++) {
          var userId = members[i];
          var data = await FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .get();

          allUsers.add(data);
          setState(() {});
        }
      }
    }
  }


  @override
  void initState() {
    super.initState();
    getCanalUsers(widget.teamId, widget.canalType,widget.canalId);
     currentUser = FirebaseAuth.instance.currentUser!;
  }



  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.darkPurple,
        title: Row(
          children: [
            //PROFILE PICTURE

            const SizedBox(
              width: 5,
            ),
            Text(
              widget.nickName,
              style: const TextStyle(fontSize: 20),
            )
          ],
        ),
        actions: [
           IconButton(
            icon: Icon(Icons.group),
            onPressed: () {
              displayMembers(widget.teamId,widget.canalType,widget.canalId);
            },
          ),

        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("teams")
                        .doc(widget.teamId)
                         .collection(widget.canalType)
                         .doc(widget.canalId)
                        .collection('messages')
                        .orderBy("dateTime", descending: true)
                        .snapshots(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.docs.length < 1) {
                          return const Center(
                            child: Text("Say Hi"),
                          );
                        }
                        return ListView.builder(
                            itemCount: snapshot.data.docs.length,
                            reverse: true,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              bool isMe = snapshot.data.docs[index]['senderId'] ==
                                  user.email;
                                 String senderId = snapshot.data.docs[index]['senderId'];

                              return SingleCanalMessage(
                                  message: snapshot.data.docs[index]['message'],
                                  isMe: isMe,
                                  senderId: senderId,
                              );
                            });
                      }
                      return const Center(child: CircularProgressIndicator());
                    })),


            CanalMessageTextField(teamId:widget.teamId,canalType:widget.canalType,canalId:widget.canalId)

          ],
        ),
      ),
    );
  }



  Future<Widget> buildProfileAvatar(String userId) async {
    final storage = FirebaseStorage.instance;
    final ref = storage.ref("profile pictures/$userId");

    // Récupérer l'URL de téléchargement de la photo de profil de l'utilisateur
    final url = await ref.getDownloadURL();

    return CircleAvatar(
      backgroundImage: NetworkImage(url),
      radius: 20,
    );
  }
  void alert() {
    String userId = "";
    bool isValidEmail = true;
    final RegExp emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.start,
          title: Text(
            "Add user to this canal",
            style: GoogleFonts.robotoCondensed(),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(hintText: "userEmail"),
                onChanged: (text) {
                  userId = text;
                  isValidEmail = emailRegex.hasMatch(userId);
                },
              ),
              if (!isValidEmail)
                const Text(
                  'Please enter a valid email address',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                LocaleKeys.add.tr(),
                style: GoogleFonts.robotoCondensed(),
              ),
              onPressed: () async {
                if (isValidEmail) {
                  FirestoreMethods firestoreMethods = FirestoreMethods();
                  bool userInTeam = await firestoreMethods.isMemberOfTeam(widget.teamId, userId);
                  if (userInTeam) {
                    await firestoreMethods.addMemberToCanal(widget.teamId, widget.canalId, userId);
                    Fluttertoast.showToast(
                      msg: "User added successfully",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                    Navigator.of(context).pop();
                  } else {
                    Fluttertoast.showToast(
                      msg: "Member not exist in team!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                }
                else{
                  Fluttertoast.showToast(
                    msg: "Email not valid",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              },
            ),
            TextButton(
              child: Text(
                LocaleKeys.cancel.tr(),
                style: GoogleFonts.robotoCondensed(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

void displayMembers(String teamId,String canalType,String canalId){
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {

          return AlertDialog(
            actionsAlignment: MainAxisAlignment.start,
            title: Text(
              "Canal's members",
              style: GoogleFonts.robotoCondensed(),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: allUsers.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: FutureBuilder<Widget>(
                      future: buildProfileAvatar(allUsers[index]["email"]),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return snapshot.data!;
                        } else {
                          return const CircleAvatar(

                            backgroundImage: AssetImage("assets/images/avatar3.png"),
                          );
                        }
                      },
                    ),
                    title: Text(
                      allUsers[index]["nickname"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      allUsers[index]["email"],
                    ),

                  );
                },
              ),
            ),
            actions: [
              ( allUsers.length > 0 &&  allUsers[0]["email"] == currentUser.email ) ?

              TextButton(
                child: Text(
                  LocaleKeys.add.tr(),
                  style: GoogleFonts.robotoCondensed(),
                ),
                onPressed: () {
                  alert();
                },
              ):TextButton(
                child: Text("Ok",
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),

              TextButton(
                child: Text(
                  LocaleKeys.cancel.tr(),
                  style: GoogleFonts.robotoCondensed(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );

        });

  }


}


