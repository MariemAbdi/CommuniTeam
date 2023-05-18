import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communiteam/services/Theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/firebase_storage_services.dart';

class ChatItem extends StatefulWidget {
  final String message;
  final String userId;
  final bool isMe;
  final String dateTime;
  const ChatItem({Key? key,required this.isMe,required this.userId, required this.message, required this.dateTime}) : super(key: key);

  @override
  State<ChatItem> createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  Storage storage = Storage();
  late String nickname="";

  //GET THE USER'S DATA
  void _fetchData(BuildContext context) async{
    FirebaseFirestore.instance.collection("users").doc(widget.userId).get().then((DocumentSnapshot documentSnapshot) {
      setState(() {
        nickname=documentSnapshot["nickname"];
      });
    }
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchData(context);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      child: ListTile(
        visualDensity: const VisualDensity(vertical: 3),
        leading: SizedBox(
          height: MediaQuery.of(context).size.width*0.1,
          width:  MediaQuery.of(context).size.width*0.1,
          child: FutureBuilder(
            future: storage.downloadURL("profile pictures", widget.userId),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if(!snapshot.hasData){
                return Container(
                    decoration: const BoxDecoration(
                        color: CustomTheme.darkPurple,
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage("assets/images/avatar3.png"),
                        )));
              }
              if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
                return Container(
                    decoration: BoxDecoration(
                        color: CustomTheme.darkPurple,
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(snapshot.data!),
                        )));
              }
              return Container(
                decoration: const BoxDecoration(
                  color: CustomTheme.darkPurple,
                  shape: BoxShape.circle,),
                child: const CircularProgressIndicator(color: CustomTheme.darkPurple,),);

            },
          ),
        ),
        title: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance.collection("users").doc(widget.userId).get(),
          builder: (context, snapshot){
            if(snapshot.hasData){
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(snapshot.data!["nickname"], style: GoogleFonts.robotoCondensed(fontWeight: widget.isMe ? FontWeight.w800 : FontWeight.w600 , color: widget.isMe ? CustomTheme.darkPurple : CustomTheme.blue),),

                  Text(widget.dateTime, style: GoogleFonts.robotoCondensed(fontWeight: FontWeight.w400, color: Colors.grey, fontSize: 12),),

            ],
              );
            }
            return const Text("...");
          },
        ),
        subtitle: Text(widget.message, style: GoogleFonts.robotoCondensed(),),
      ),
    );
  }
}
