import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communiteam/services/Theme/custom_theme.dart';
import 'package:communiteam/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/firebase_storage_services.dart';
import '../utils.dart';

class ProfilePicture extends StatefulWidget {
  final String userId;
  final bool isMe;
  const ProfilePicture({Key? key, required this.userId, required this.isMe}) : super(key: key);

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  Storage storage = Storage();

  final user = FirebaseAuth.instance.currentUser!;

  Uint8List? image; // IF WE USE FILE TYPE INSTEAD THEN WE WON'T BE ABLE TO USE IT ON WEB

  late String nickname="", bio="", imageURL="";

  late int randomId=3;

  late TextEditingController alertController=TextEditingController();


  @override
  void initState() {
    super.initState();
    _fetchData(context);
    setState(() {
      randomId=Random().nextInt(5);
    });
  }


  @override
  void dispose() {
    alertController.dispose();
    super.dispose();
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
        title: Text(LocaleKeys.profilePicture.tr(), style: GoogleFonts.robotoCondensed(fontWeight: FontWeight.w800),),
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
            child: Text(LocaleKeys.chooseFromGallery.tr(), style: GoogleFonts.roboto(),),
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
            child: Text(LocaleKeys.delete.tr(), style: GoogleFonts.roboto(color: Colors.red),),
          ),
        ],
      );
    });
  }

  Widget nameBio(String name, double fontSize, FontWeight fontWeight, VoidCallback function){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(name,style: GoogleFonts.robotoCondensed(textStyle: TextStyle(fontWeight: fontWeight, fontSize: fontSize),)),
        Visibility(
          visible: widget.isMe,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: function,
            icon: const Icon(Icons.edit, color: Colors.white, size: 18,),
          ),
        )
      ],
    );
  }

  Future<String?> openDialog(String title,IconData iconData,String hintText)=>
      showDialog<String>(context: context, builder: (context)=> AlertDialog(
    title: Text(title),
    content: TextField(
      autofocus: true,
      controller: alertController,
      decoration: InputDecoration(
          prefixIcon: Icon(iconData),
          hintText: hintText,
      ),
    ),
    actions: [
      TextButton(onPressed: (){
        if(alertController.text.isNotEmpty){
          Navigator.of(context).pop(alertController.text);
          //alertController.clear();
        }else{
          customSnackBar(context, LocaleKeys.fieldCantBeEmpty.tr(), Colors.red);
        }
      }, child: Text(LocaleKeys.update.tr(),style: GoogleFonts.robotoCondensed(color: Colors.red),
      ))
    ],
  ));

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
                          decoration: BoxDecoration(
                              color: CustomTheme.darkPurple,
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage("assets/images/avatar$randomId.png"),//GENERATE RANDOM PROFILE PICTURE
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
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness==CustomTheme.lightTheme.brightness ? CustomTheme.darkPurple: CustomTheme.darkTheme.primaryColorDark,
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

        //--------------------THE USER'S USERNAME--------------------
        nameBio(nickname,25,FontWeight.w600, () async {
          setState(() {
            alertController.text=nickname;
          });

          //SHOW THE DIALOG ALERT AND GET THE RETURN
          final newName = await openDialog(LocaleKeys.updateNickname.tr(), Icons.person, LocaleKeys.newNickname.tr());

          //CHECK IF WHAT WE'VE GOT IS NULL OR EMPTY
          if(newName==null || newName.isEmpty ){return;}

          //ELSE
          //UPDATE DISPLAY NAME
          user.updateDisplayName(newName);

          //UPDATE DOCUMENT IN FIRESTORE
          FirebaseFirestore.instance.collection("users").doc(user.email).update(
              {
                "nickname": newName,
              });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            //By nesting it in the callback of addPostFrameCallback you are basically saying when the widget is done building,
            // then execute the navigation code.
            customSnackBar(context, LocaleKeys.nicknameUpdatedSuccessfully.tr(), Colors.green);
          });

          //REFRESH DATA ON SCREEN
          setState(() {_fetchData(context);});
        }),


        //--------------------------THE USER'S BIO--------------------------
        nameBio(bio,20, FontWeight.w300, () async {

          setState(() {
            alertController.text=bio;
          });

          //SHOW THE DIALOG ALERT AND GET THE RETURN
          final newBio = await openDialog(LocaleKeys.updateBio.tr(), Icons.abc, LocaleKeys.newBio.tr());

          //CHECK IF WHAT WE'VE GOT IS NULL OR EMPTY
          if(newBio==null || newBio.isEmpty ){return;}

          //ELSE
          //UPDATE DOCUMENT IN FIRESTORE
          FirebaseFirestore.instance.collection("users").doc(user.email).update(
              {
                "bio": newBio,
              });

          //POP LOADING CIRCLE
          WidgetsBinding.instance.addPostFrameCallback((_) {
            //By nesting it in the callback of addPostFrameCallback you are basically saying when the widget is done building,
            // then execute the navigation code.
            customSnackBar(context, LocaleKeys.bioUpdatedSuccessfully.tr(), Colors.green);
          });

          //REFRESH DATA ON SCREEN
          setState(() {_fetchData(context);});
        }),

      ],
    );
  }
}
