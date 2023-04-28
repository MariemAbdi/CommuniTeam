import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/Theme/custom_theme.dart';
import '../widgets/message_textfield.dart';
import '../widgets/single_message.dart';

class DirectChatScreen extends StatefulWidget {
  final String receiverId;

  DirectChatScreen({
    required this.receiverId,
  });

  @override
  State<DirectChatScreen> createState() => _DirectChatScreenState();
}

class _DirectChatScreenState extends State<DirectChatScreen> {
  String nickname = "";

  @override
  void initState() {
    super.initState();
    _fetchData(context);
  }

  //GET THE USER'S DATA
  void _fetchData(BuildContext context) async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.receiverId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      setState(() {
        nickname = documentSnapshot["nickname"];
      });
    });
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
            
            SizedBox(
              width: 5,
            ),
            Text(
              nickname,
              style: TextStyle(fontSize: 20),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25))),
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(user.email)
                    .collection('messages')
                    .doc(widget.receiverId)
                    .collection('chats')
                    .orderBy("date", descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.docs.length < 1) {
                      return Center(
                        child: Text("Say Hi"),
                      );
                    }
                    return ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        reverse: true,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          bool isMe = snapshot.data.docs[index]['senderId'] ==
                              user.email;
                          return SingleMessage(
                              message: snapshot.data.docs[index]['message'],
                              isMe: isMe);
                        });
                  }
                  return Center(child: CircularProgressIndicator());
                }),
          )),
          MessageTextField(user.email!, widget.receiverId),
        ],
      ),
    );
  }
}
