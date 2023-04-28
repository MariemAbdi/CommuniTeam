import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communiteam/services/Theme/custom_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/firebase_storage_services.dart';
import '../utils.dart';

class ProfilePicture extends StatefulWidget {
  final String userId;
  const ProfilePicture({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  Storage storage = Storage();
  final user = FirebaseAuth.instance.currentUser!;
  Uint8List? image; // IF WE USE FILE TYPE INSTEAD THEN WE WON'T BE ABLE TO USE IT ON WEB
  late String nickname="", bio="";
  late String imageURL="";

  @override
  void initState() {
    super.initState();
    _fetchData(context);
  }

  //GET THE USER'S DATA
  void _fetchData(BuildContext context) async{
    FirebaseFirestore.instance.collection("users").doc(widget.userId).get().then((DocumentSnapshot documentSnapshot) {
      setState(() {
        nickname=documentSnapshot["nickname"];
        bio=documentSnapshot["bio"];
      });
    }
    );
  }

  //LET THE USER CHOOSE TO ADD PROFILE PICTURE FROM GALLERY OR REMOVE IT -> AVATAR
  void uploadImage(String fileName) async{
    showCupertinoModalPopup(context: context, builder: (BuildContext context){
      return CupertinoActionSheet(
        title: Text("Profile Picture", style: GoogleFonts.robotoCondensed(fontWeight: FontWeight.w800),),
        actions: [
          //CHOOSE IMAGE FROM GALLERY
          CupertinoActionSheetAction(
            onPressed: () async {

              Navigator.pop(context);

              Uint8List? pickedImage = await pickImage(context);
              if(pickedImage!=null){
                setState(() {
                  image=pickedImage;
                });
                //UPLOAD IMAGE TO FIREBASE STORAGE
                storage.uploadFile("profile pictures", pickedImage, fileName);

                //REFRESH SCREEN
                setState(() {
                });
              }

            },
            child: Text("Choose Image From Gallery", style: GoogleFonts.roboto(),),
          ),

          // REMOVE CURRENT PHOTO : DEFAULT
          CupertinoActionSheetAction(
            onPressed: () async {

              Navigator.pop(context);

              //DELETE IMAGE FROM DATA STORAGE
              storage.deleteFile("profile pictures", widget.userId);

              //REFRESH SCREEN
              setState(() {
              });

            },
            child: Text("Remove", style: GoogleFonts.roboto(color: Colors.red),),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    //CHECK IF THE CURRENT USER IS ACCESSING THEIR OWN PROFILE OR SOMEONE ELSE'S
    final isMe= widget.userId == user.email!;

    return Column(
      children: [
        //PROFILE PICTURE + PEN
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [

                //PROFILE PICTURE
                FutureBuilder(
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
                      if(image==null){
                        return Container(
                            decoration: BoxDecoration(
                                color: CustomTheme.darkPurple,
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(snapshot.data!),
                                )));
                      }else{
                        return Container(
                            decoration: BoxDecoration(
                                color: CustomTheme.darkPurple,
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: MemoryImage(image!),
                                )));
                      }
                    }

                    return const Center(child: CircularProgressIndicator(color: CustomTheme.darkPurple,),);
                  },
                ),

                //EDIT PROFILE PICTURE => PEN
                Visibility(
                  visible: isMe,
                  child: Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      child: Container(
                        margin: const EdgeInsets.all(3.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: const BoxDecoration(
                          color: CustomTheme.darkPurple,
                          shape: BoxShape.circle,),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: (){
                            uploadImage(user.email!);
                          },
                          icon: const Icon(Icons.edit, color: Colors.white, size: 20,),
                        ),
                      ),
                    ),
                  ),),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10,),

        //THE USER'S USERNAME
        Text(nickname,style: GoogleFonts.robotoCondensed(textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 30),)),

        //THE USER'S BIO
        Text(bio,style: GoogleFonts.robotoCondensed(textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),)),
      ],
    );
  }
}
