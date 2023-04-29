import 'dart:ffi';

import 'package:communiteam/screens/direct_chat.dart';
import 'package:communiteam/screens/homepage.dart';
import 'package:flutter/material.dart';

typedef void EditChannelCallback(String text);

class DrawerItemCanal extends StatefulWidget {
  final String name,id;
  final bool isOwner;
  final VoidCallback onDeleteChannel;
  final EditChannelCallback onEditChannel;



  const DrawerItemCanal({Key? key,
    required this.name,
    required this.id,
    required this.isOwner,
    required this.onDeleteChannel,
    required this.onEditChannel,

  }) : super(key: key);

  @override
  State<DrawerItemCanal> createState() => _DrawerItemCanalState();
}

class _DrawerItemCanalState extends State<DrawerItemCanal> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "#${widget.name}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Visibility(
            visible: widget.isOwner,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Edit Canal ${widget.name}"),
                          content: TextFormField(
                            decoration: const InputDecoration(
                              hintText: "name",
                            ),
                            controller: _textEditingController,
                            onChanged: (text) {
                              setState(() {});
                            },
                          ),
                          actions: [
                            TextButton(
                              child: const Text("Cancel"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text("Edit"),
                              onPressed: () {
                                // Ajoutez ici votre code pour editer le canal
                                widget.onEditChannel(_textEditingController.text);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.edit, color: Colors.white),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirmation"),
                          content: Text("Do you really want to delete this channel: ${widget.name}?"),
                          actions: [
                            TextButton(
                              child: const Text("Annuler"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text("Delete"),
                              onPressed: () {
                                widget.onDeleteChannel();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.delete, color: Colors.white),
                ),
              ],
            ),
          ),
        ],

      ),
    );
  }
}







