import 'package:flutter/material.dart';

import '../services/Theme/custom_theme.dart';


class SingleMessage extends StatelessWidget {
  final String message;
  final String dateTime;
  final bool isMe;

  const SingleMessage({super.key,
    required this.message,
    required this.dateTime,
    required this.isMe
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 200),
          decoration: BoxDecoration(
              color: isMe ? CustomTheme.darkPurple : CustomTheme.purplelight,
              borderRadius: const BorderRadius.all(Radius.circular(12))
          ),
          child:
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message,style: const TextStyle(color: Colors.white, fontSize: 16),),
              Text(dateTime,style: TextStyle(color: isMe ? Colors.grey: Colors.black, fontSize: 12),)
          ],
          )
        ),
      ],
      
    );
  }
}