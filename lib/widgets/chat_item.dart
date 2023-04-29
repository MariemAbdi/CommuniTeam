import 'package:communiteam/services/Theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatItem extends StatefulWidget {
  final String message;
  final String username;
  final String userId;
  final bool isMe;
  const ChatItem({Key? key,required this.isMe,required this.userId, required this.username, required this.message}) : super(key: key);

  @override
  State<ChatItem> createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        minLeadingWidth:2, //THE SPACE BETWEEN THE LEADING PICTURE AND TEXT
        visualDensity: const VisualDensity(vertical: 1), //
        leading: Image.asset('assets/images/placeholder.png'),
        title: Text(widget.username, style: GoogleFonts.robotoCondensed(fontWeight: widget.isMe ? FontWeight.w800 : FontWeight.w600 , color: widget.isMe ? CustomTheme.darkPurple : CustomTheme.blue),),
        subtitle: Text(widget.message, style: GoogleFonts.robotoCondensed(),),
      ),
    );
  }
}
