import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../resources/firestore_methods.dart';
import '../services/Theme/custom_theme.dart';
import '../translations/locale_keys.g.dart';
import '../widgets/canalMessage_textfield.dart';
import '../widgets/message_textfield.dart';
import '../widgets/single_message.dart';
import '../widgets/singlemessage_canal.dart';

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


  @override
  void initState() {
    super.initState();
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
            icon: Icon(Icons.add),
            onPressed: () {
              alert();
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
  alert(){
    showCupertinoModalPopup(context: context, builder: (BuildContext context){
      String userId = "";
      bool isValidEmail = true; // Ajout de la variable pour suivre la validation

      return AlertDialog(
        actionsAlignment: MainAxisAlignment.start,
        title: Text("Add user to this canal",
          style: GoogleFonts.robotoCondensed(),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(hintText: "userEmail"  ),
              onChanged: (text) {
                userId = text;
                // Vérification de la validité de l'e-mail
                final RegExp emailRegex = RegExp(
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
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
                bool userInTeam = await firestoreMethods.isMemberOfTeam( widget.teamId, userId);
                if(userInTeam){
                  firestoreMethods.addMemberToCanal(widget.teamId, widget.canalId, userId);
                }
                else{
                  const Text(
                    'Memeber not exist in team!',
                    style: TextStyle(color: Colors.red),
                  );
                }

              }
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
