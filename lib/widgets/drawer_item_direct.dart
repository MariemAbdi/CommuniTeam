import 'package:communiteam/screens/direct_chat.dart';
import 'package:communiteam/screens/homepage.dart';
import 'package:flutter/material.dart';


class DrawerItemDirect extends StatefulWidget {
  final String name;
  final String receiverId;
  const DrawerItemDirect({Key? key, required this.name,required this.receiverId}) : super(key: key);

  @override
  State<DrawerItemDirect> createState() => _DrawerItemDirectState();
}

class _DrawerItemDirectState extends State<DrawerItemDirect> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (){
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => DirectChatScreen(receiverId: widget.receiverId)));
    },
      child: Align(
          alignment: Alignment.centerLeft,
          child: Text("#${widget.name}", style:  const TextStyle(fontSize: 14,fontWeight: FontWeight.w600, color: Colors.white,))),);
  }
}
