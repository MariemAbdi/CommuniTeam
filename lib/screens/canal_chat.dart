import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/Theme/custom_theme.dart';
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
}
