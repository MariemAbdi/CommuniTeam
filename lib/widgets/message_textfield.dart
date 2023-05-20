import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communiteam/services/Theme/custom_theme.dart';
import 'package:communiteam/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class MessageTextField extends StatefulWidget {
  final String receiverId;
  const MessageTextField({Key? key, required this.receiverId}) : super(key: key);

  @override
  MessageTextFieldState createState() => MessageTextFieldState();
}

class MessageTextFieldState extends State<MessageTextField> {

  final user = FirebaseAuth.instance.currentUser!;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
       padding: const EdgeInsetsDirectional.all(8),
       child: Row(
         children: [
           Expanded(child: Theme(
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
           const SizedBox(width: 20,),
           GestureDetector(
             onTap: ()async{
               String message = _controller.text;
               if(message.isNotEmpty){
                 _controller.clear();
                 await FirebaseFirestore.instance.collection('users').doc(user.email!).collection('messages').doc(widget.receiverId).collection('chats').add({
                   "senderId": user.email!,
                   "receiverId": widget.receiverId,
                   "message": message,
                   "type": "text",
                   "date": DateTime.now(),
                 });

                 await FirebaseFirestore.instance.collection('users').doc(widget.receiverId).collection('messages').doc(user.email!).collection("chats").add({
                   "senderId": user.email!,
                   "receiverId": widget.receiverId,
                   "message" :message,
                   "type": "text",
                   "date": DateTime.now(),

                 });
               }
             },
             child: Container(
               padding: const EdgeInsets.all(8),
               decoration: const BoxDecoration(
                 shape: BoxShape.circle,
                 color: CustomTheme.darkPurple,
               ),
               child: const Icon(Icons.send,color: Colors.white,),
             ),
           )
         ],
       ),

    );
  }
}