import 'package:communiteam/screens/homepage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../resources/firestore_methods.dart';
import '../screens/canal_chat.dart';

import '../services/Theme/custom_theme.dart';
import '../translations/locale_keys.g.dart';

class DrawerItemCanal extends StatefulWidget {
  final String canalId;
  final String canalName;
  final bool isOwner;
  final String collectionName;
  final String teamId;
  final bool isGeneral;



  const DrawerItemCanal({Key? key, required this.canalId, required this.canalName,
    required this.collectionName, required this.isOwner, required this.teamId, required this.isGeneral}) : super(key: key);

  @override
  State<DrawerItemCanal> createState() => _DrawerItemCanalState();
}

class _DrawerItemCanalState extends State<DrawerItemCanal> {
  final TextEditingController _textEditingController= TextEditingController();

  void deleteCanal() {
    FirestoreMethods firestoreMethods= FirestoreMethods();
    firestoreMethods.deleteCanal(context,widget.teamId,widget.collectionName, widget.canalId);
  }

  void editCanal() {
  FirestoreMethods firestoreMethods= FirestoreMethods();
  firestoreMethods.editCanal(context,widget.teamId,widget.canalId,widget.collectionName,_textEditingController.text.trim());
  }

  @override
  void initState() {
    super.initState();
    _textEditingController.text= widget.canalName;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minLeadingWidth:2, //THE SPACE BETWEEN THE LEADING PICTURE AND TEXT
      visualDensity: const VisualDensity(vertical: 1), //
      leading: Text(
        "#${widget.canalName}",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          overflow: TextOverflow.ellipsis,
        ),
        maxLines: 1,
      ),
      trailing: Visibility(
        visible: widget.isOwner,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            //Edit
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(LocaleKeys.renameCanal.tr()),
                      content: TextFormField(
                        controller: _textEditingController,
                        onChanged: (text) {
                          setState(() {});
                        },
                      ),
                      actions: [
                        TextButton(
                          child: Text(LocaleKeys.cancel.tr()),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text(LocaleKeys.rename.tr()),
                          onPressed: () {
                            if(_textEditingController.text.trim().isNotEmpty){
                              editCanal();
                            }
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.edit, color: CustomTheme.green, size: 20,),
            ),
            //Delete
            if (!widget.isGeneral)
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(LocaleKeys.yes.tr()),
                      content: Text(LocaleKeys.areYouSureYouWantToDeleteTeam.tr()),
                      actions: [
                        TextButton(
                          child: Text(LocaleKeys.cancel.tr()),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text(LocaleKeys.delete.tr()),
                          onPressed: () {
                            deleteCanal();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.delete, color: CustomTheme.pink, size: 20,),
            ),
          ],
        ),
      ),

      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => HomePage(isCanal: true,title: widget.canalName ,widget: CanalChatScreen( teamId:widget.teamId, canalType:widget.collectionName , canalId:widget.canalId, nickName: widget.canalName, ))));


      },
    );
  }
}

