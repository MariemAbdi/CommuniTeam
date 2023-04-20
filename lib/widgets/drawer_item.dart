import 'package:communiteam/screens/homepage.dart';
import 'package:flutter/material.dart';


class DrawerItem extends StatefulWidget {
  final String name;
  const DrawerItem({Key? key, required this.name}) : super(key: key);

  @override
  State<DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends State<DrawerItem> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (){
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const HomePage()));
    },
      child: Align(
          alignment: Alignment.centerLeft,
          child: Text("#${widget.name}", style:  const TextStyle(fontSize: 14,fontWeight: FontWeight.w600, color: Colors.white,))),);
  }
}
