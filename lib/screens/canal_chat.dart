import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communiteam/utils.dart';
import 'package:communiteam/widgets/chat_item.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../resources/firestore_methods.dart';
import '../translations/locale_keys.g.dart';
import '../widgets/canalMessage_textfield.dart';


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
        List<dynamic> tempUsers =[];
        for (int i = 0; i < members.length; i++) {
          var userId = members[i];
          var data = await FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .get();

          tempUsers.add(data);
          setState(() {});
        }
        allUsers=tempUsers;
      }
    } else {
      final canalSnapshot = await FirebaseFirestore.instance
          .collection("teams")
          .doc(teamId)
          .get();

      if (canalSnapshot.exists) {
        final List<dynamic> members = canalSnapshot.data()!['members'];
        List<dynamic> tempUsers =[];
        for (int i = 0; i < members.length; i++) {
          var userId = members[i];
          var data = await FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .get();
          tempUsers.add(data);
          setState(() {});
        }
        allUsers=tempUsers;
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
      body: Column(
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
                          String senderId = snapshot.data.docs[index]['senderId'];
                          bool isMe = senderId == user.email;
                          String message= snapshot.data.docs[index]['message'];
                          String dateTime= DateFormat('dd/MM/yyyy HH:mm').format((snapshot.data.docs[index]['dateTime']).toDate());
                          return ChatItem(isMe: isMe, userId: senderId, message: message, dateTime: dateTime);
                        }
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                }
            ),
          ),
          CanalMessageTextField(teamId:widget.teamId,canalType:widget.canalType,canalId:widget.canalId),
        ],
      ),
    );
  }


}


