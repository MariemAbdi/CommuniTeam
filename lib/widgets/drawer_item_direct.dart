import 'package:communiteam/screens/direct_chat.dart';
import 'package:communiteam/screens/homepage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/Theme/custom_theme.dart';
import '../services/firebase_storage_services.dart';


class DrawerItemDirect extends StatefulWidget {
  final String name;
  final String receiverId;
  const DrawerItemDirect({Key? key, required this.name,required this.receiverId}) : super(key: key);

  @override
  State<DrawerItemDirect> createState() => _DrawerItemDirectState();
}

class _DrawerItemDirectState extends State<DrawerItemDirect> {
  Storage storage = Storage();
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minLeadingWidth:2, //THE SPACE BETWEEN THE LEADING PICTURE AND TEXT
      visualDensity: const VisualDensity(vertical: 1), // to expand
      leading: SizedBox(
        height: 30,
        width: 30,
        child: FutureBuilder(
          future: storage.downloadURL("profile pictures", widget.receiverId),
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
      title: Text(widget.name, style: GoogleFonts.robotoCondensed(textStyle: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis)),),

      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => HomePage(isCanal: false, title: widget.name, widget: DirectChatScreen(receiverId: widget.receiverId))));
      },

    );
  }
}
