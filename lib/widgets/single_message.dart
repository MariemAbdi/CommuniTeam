import 'package:flutter/material.dart';

import '../services/Theme/custom_theme.dart';


class SingleMessage extends StatelessWidget {
  final String message;
  final bool isMe;

  const SingleMessage({super.key,
    required this.message,
    required this.isMe
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 200),
          decoration: BoxDecoration(
              color: isMe ? CustomTheme.darkPurple : CustomTheme.purplelight,
              borderRadius: const BorderRadius.all(Radius.circular(12))
          ),
          child: Text(message,style: const TextStyle(color: Colors.white,),)
        ),
      ],
      
    );
  }
}