import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/Theme/custom_theme.dart';

class SingleCanalMessage extends StatelessWidget {
  final String message;
  final bool isMe;
  final String senderId;
  final Future<String?> nickname;

  SingleCanalMessage({
    Key? key,
    required this.message,
    required this.isMe,
    required this.senderId,
  }) : nickname = FirebaseFirestore.instance
      .collection("users")
      .doc(senderId)
      .get()
      .then((doc) => doc.data()?['nickname'] as String?),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          width: double.infinity,
          //constraints: const BoxConstraints(maxWidth: 200),
          decoration: BoxDecoration(
              color: isMe ? CustomTheme.darkPurple : CustomTheme.purplelight,
              borderRadius: const BorderRadius.all(Radius.circular(12))
          ),
          child: FutureBuilder<String?>(
            future: nickname,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white,),
                  ),
                  Text(
                    snapshot.data ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
