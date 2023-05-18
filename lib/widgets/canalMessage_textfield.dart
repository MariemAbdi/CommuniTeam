import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communiteam/services/Theme/custom_theme.dart';
import 'package:communiteam/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class CanalMessageTextField extends StatefulWidget {
  final String teamId;
  final String canalType;
  final String canalId;

  const CanalMessageTextField({super.key, required this.teamId,required this.canalType,required this.canalId});


  @override
  State<CanalMessageTextField> createState() => _CanalMessageTextFieldState();

}

class _CanalMessageTextFieldState extends State<CanalMessageTextField> {

  final user = FirebaseAuth.instance.currentUser!;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
              child: Theme(
              data: CustomTheme.lightTheme,
              child: TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                  labelText: LocaleKeys.saySomthing.tr(),
                  fillColor: Colors.grey[100],
                  filled: true,
                  border: OutlineInputBorder(
                      borderSide: const BorderSide(width: 0),
                      gapPadding: 10,
                      borderRadius: BorderRadius.circular(25)
                  ),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                    icon: const Icon(EvaIcons.close),
                    onPressed: () {
                      setState(() {
                        _controller.clear();
                      });
                    },
                  )
              ),
            ),
          )),
          const SizedBox(width: 10,),
          GestureDetector(
            onTap: ()async{
              String message = _controller.text;
              _controller.clear();
              var newDocRef = await FirebaseFirestore.instance
                  .collection("teams")
                  .doc(widget.teamId)
                  .collection(widget.canalType)
                  .doc(widget.canalId)
                  .collection('messages')
                  .add({
                "senderId": user.email!,
                "message": message,
                "dateTime": DateTime.now(),
              });

              String newDocId = newDocRef.id;

              await newDocRef.update({
                "documentId": newDocId,
              });
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).brightness==CustomTheme.lightTheme.brightness ? CustomTheme.darkPurple: CustomTheme.darkTheme.primaryColorDark,
              ),
              child: const Icon(Icons.send,color: Colors.white,),
            ),
          )
        ],
      ),

    );
  }
}