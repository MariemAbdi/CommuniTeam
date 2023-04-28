import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatItem extends StatefulWidget {

  const ChatItem({Key? key}) : super(key: key);

  @override
  State<ChatItem> createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: ListTile(
        leading: Image.asset('assets/images/placeholder.png'),
        title: Text("Name", style: GoogleFonts.robotoCondensed(fontWeight: FontWeight.w800),),
        subtitle: Text("Message Message Message Message Message.", style: GoogleFonts.robotoCondensed(),),
      ),
    );
  }
}
