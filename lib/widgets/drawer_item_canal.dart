import 'package:communiteam/screens/direct_chat.dart';
import 'package:communiteam/screens/homepage.dart';
import 'package:flutter/material.dart';

class DrawerItemCanal extends StatefulWidget {
  final String name;
  const DrawerItemCanal({Key? key, required this.name}) : super(key: key);

  @override
  State<DrawerItemCanal> createState() => _DrawerItemCanalState();
}

class _DrawerItemCanalState extends State<DrawerItemCanal> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        
      },
      child: Align(
          alignment: Alignment.centerLeft,
          child: Text("#${widget.name}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ))),
    );
  }
}
