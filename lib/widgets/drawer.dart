import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communiteam/services/Theme/custom_theme.dart';
import 'package:communiteam/services/firebase_storage_services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/team.dart';
import '../providers/firebase_auth_methods.dart';
import '../resources/firestore_methods.dart';
import '../translations/locale_keys.g.dart';
import 'drawer_item_canal.dart';
import 'drawer_item_direct.dart';


class DrawerWidget extends StatefulWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final user = FirebaseAuth.instance.currentUser!;
  String dropdownValue ="Iset Rades";
  List<Team> teams = [];
  Storage storage = Storage();

  late String selectedTeamId = "toBCHluEdzfmeoXhCxQw";

  bool publicCanals=false;
  bool privateCanals=false;
  bool directMessages=false;
  bool isMember= false;

  getTeams() async {
    await FirebaseFirestore.instance
        .collection("teams").where("members", arrayContains: user.email!)
        .snapshots()
        .forEach((element) {
      List<Team> list = [];
      for (var value in element.docs) {
        Team team = Team(
            id: value['id'],
            name: value['name'],
            members: value['members'].cast<String>());
          list.add(team);
      }
      setState(() {

        teams = list;
      });
    });
  }


  @override
  void initState() {
    super.initState();
    getTeams();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: LayoutBuilder(
        builder: (context, constraint) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: constraint.maxHeight * 0.95),
              //IntrinsicHeight IS USED SO THAT EXPANDED DOES NOT TAKE THE WHOLE DRAWER
              child: IntrinsicHeight(
                child: Column(
                  children: [

                    //---------------------------PROFILE PICTURE & NAME---------------------------------------
                    FutureBuilder(
                      future: storage.downloadURL("profile pictures", user.email!),
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                        if(!snapshot.hasData){
                          return Container(
                              width: MediaQuery.of(context).size.width*0.3,
                              height: MediaQuery.of(context).size.width*0.3,
                              decoration: const BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage("assets/images/avatar3.png"),
                                  )));
                        }
                        if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
                          return  Container(
                              width: MediaQuery.of(context).size.width*0.3,
                              height: MediaQuery.of(context).size.width*0.3,
                              decoration: BoxDecoration(
                                  color: CustomTheme.green,
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(snapshot.data!),
                                  )));
                        }

                        return const Center(child: CircularProgressIndicator(color: CustomTheme.white,),);
                      },
                    ),

                    const SizedBox(height: 10,),

                    //THE USER'S USERNAME
                    Text(user.displayName!,style: GoogleFonts.robotoCondensed(textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white, overflow: TextOverflow.ellipsis),)),
                    //---------------------------TEAMS---------------------------------------

                    teamRow(Icons.group, LocaleKeys.team.tr(), () {
                          //GO TO ADD TEAM Screen
                            Navigator.pop(context);
                            Navigator.of(context).pushReplacementNamed('/add_new_team');

                      }),

                    teamDropDown(),

                    const Divider(),
                    //---------------------------PUBLIC CANALS---------------------------------------
                    canalRow(Icons.public,LocaleKeys.publicCanals.tr(),publicCanals, (){
                      setState(() {
                        publicCanals=!publicCanals;
                      });
                    },false),

                    Visibility(
                      visible: publicCanals,
                      child: SizedBox(height: MediaQuery.of(context).size.height*0.2,
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection("teams")
                                .doc(selectedTeamId).collection("publicCanals").orderBy("name").snapshots(),
                            builder: (context, AsyncSnapshot snapshot){
                              if(snapshot.hasData){
                                final canals = snapshot.data!.docs;
                                return ListView.builder(
                                    itemCount: canals.length,
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    physics: const ClampingScrollPhysics(),
                                    itemBuilder: (BuildContext context, int index){
                                      return DrawerItemCanal(canalId:canals[index]["id"], canalName: canals[index]['name'], isOwner: user.email == canals[index]['owner'], collectionName: 'publicCanals', teamId: selectedTeamId,);
                                    });
                              }
                              return const Center(child: CircularProgressIndicator(color: CustomTheme.darkPurple,),);
                            },
                          )
                      ),),

                    //HORIZONTAL LINE
                    const Divider(),

                    //---------------------------PRIVATE CANALS---------------------------------------
                    canalRow(Icons.lock,LocaleKeys.privateCanals.tr(),privateCanals, (){
                      setState(() {
                        privateCanals=!privateCanals;
                      });
                    },true),

                    Visibility(
                      visible: privateCanals,
                      child: SizedBox(height: MediaQuery.of(context).size.height*0.2,
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection("teams")
                                .doc(selectedTeamId).collection("privateCanals").where("members", arrayContains: user.email!).orderBy("name").snapshots(),
                            builder: (context, AsyncSnapshot snapshot){
                              if(snapshot.hasData){
                                final canals = snapshot.data!.docs;
                                return ListView.builder(
                                    itemCount: canals.length,
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    physics: const ClampingScrollPhysics(),
                                    itemBuilder: (BuildContext context, int index){
                                      return Visibility(
                                        visible: true,
                                          child: DrawerItemCanal(canalId: canals[index]['id'], canalName: canals[index]['name'], isOwner: user.email! == canals[index]["members"][0], collectionName: "privateCanals", teamId: selectedTeamId,));
                                    });
                              }
                              return const Center(child: CircularProgressIndicator(color: CustomTheme.darkPurple,),);
                            },
                          )
                      ),),

                    //HORIZONTAL LINE
                    const Divider(),

                    //---------------------------DIRECT MESSAGES---------------------------------------
                    canalRow(Icons.message, LocaleKeys.directMessages.tr(), directMessages, () {
                      setState(() {
                        directMessages=!directMessages;
                      });
                    }, false),

                    Visibility(
                                visible: directMessages,
                                child: SizedBox(height: MediaQuery.of(context).size.height*0.2,
                                  child: StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection("teams")
                                        .doc(selectedTeamId).snapshots(),
                                    builder: (context, AsyncSnapshot snapshot){
                                      if(snapshot.hasData){
                                        DocumentSnapshot item = snapshot.data!;
                                        List<String> members = item['members'].cast<String>();
                                        //REMOVE THE CURRENT USER
                                        members.removeWhere((element) => element==user.email!);
                                        return ListView.builder(
                                            itemCount: members.length,
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            physics: const ClampingScrollPhysics(),
                                            itemBuilder: (BuildContext context, int index){
                                              return FutureBuilder<DocumentSnapshot>(
                                                  future: FirebaseFirestore.instance
                                                      .collection("users")
                                                      .doc(members[index]).get(),
                                                  builder:(BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
                                                    if(snapshot.hasData){
                                                      Map<String, dynamic> usersList = snapshot.data!.data() as Map<String, dynamic>;

                                                      return DrawerItemDirect(name: usersList["nickname"]!, receiverId: usersList["email"]!);
                                                    }
                                                    return const Center(child: CircularProgressIndicator(color: CustomTheme.darkPurple,),);
                                              });

                                            });
                                      }
                                      return const Center(child: CircularProgressIndicator(color: CustomTheme.darkPurple,),);
                                    },
                                  )
                              ),),

                    //SOME SPACE
                    const Expanded(child: SizedBox()),

                    //---------------------------PROFILE, SETTINGS & LOGOUT BUTTONS---------------------------
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        children: [
                          //HORIZONTAL LINE
                          const Divider(),

                          //GO TO PROFILE
                          bottomListTile(LocaleKeys.myProfile.tr(), Icons.account_circle, () {
                            Navigator.pop(context);
                            Navigator.of(context).pushReplacementNamed('/profile');
                          }),

                          //GO TO SETTINGS
                          bottomListTile(LocaleKeys.settings.tr(), Icons.settings, () {
                            Navigator.pop(context);
                            Navigator.of(context).pushReplacementNamed('/settings');
                          }),

                          const Divider(),

                          //LOGOUT
                          bottomListTile(LocaleKeys.logout.tr(), Icons.power_settings_new, () {
                            showCupertinoModalPopup(context: context, builder: (BuildContext context){
                              return AlertDialog(
                                actionsAlignment: MainAxisAlignment.start,
                                title: Text(
                                  LocaleKeys.logout.tr(),
                                  style:
                                  GoogleFonts.robotoCondensed(),
                                ),
                                content: const Text("Would you like to logout?"),
                                actions: [
                                  TextButton(
                                    child: Text(
                                      LocaleKeys.yes.tr(),
                                      style: GoogleFonts
                                          .robotoCondensed(),
                                    ),
                                    onPressed: () {
                                      context.read<FirebaseAuthMethods>().signOut(context);
                                    },
                                  ),
                                  TextButton(
                                    child: Text(
                                      LocaleKeys.cancel.tr(),
                                      style:
                                      GoogleFonts.robotoCondensed(
                                          color:
                                          Colors.red),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop();
                                    },
                                  ),
                                ],
                              );

                            });
                          }),


                        ],
                      ),),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  //CANAL ICON, NAME AND ADD FUNCTION
  Widget canalRow(IconData icon,String name,bool visibility, VoidCallback showHide,bool isPrivate){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: showHide,
          child: Row(children: [
            Row(
              children: [
                Icon(icon ,color: Colors.white, size: 20,),
                const SizedBox(
                  width: 5,
                ),
                Text(name, style: GoogleFonts.robotoCondensed(textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, overflow: TextOverflow.ellipsis, color: Colors.white)),),
              ],
            ),
            Icon(visibility?Icons.keyboard_arrow_up:Icons.keyboard_arrow_down, color: Colors.white, size: 18,),
          ],),
        ),
        IconButton(onPressed: (){
          showCupertinoModalPopup(context: context, builder: (BuildContext context){
            String canalName = "";
            return AlertDialog(
              actionsAlignment: MainAxisAlignment.start,
              title: Text(
                LocaleKeys.createNewCanal.tr(),
                style: GoogleFonts.robotoCondensed(),
              ),
              content: TextFormField(
                decoration: InputDecoration(hintText: LocaleKeys.canalName.tr()),
                onChanged: (name) {
                  canalName = name;
                },
              ),
              actions: [
                TextButton(
                  child: Text(
                    LocaleKeys.add.tr(),
                    style: GoogleFonts.robotoCondensed(),
                  ),
                  onPressed: () {
                    if (canalName.isNotEmpty) {
                      FirestoreMethods firestoreMethods = FirestoreMethods();
                      firestoreMethods.addCanal(context, selectedTeamId, canalName, isPrivate, user.email!);
                    }
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                    LocaleKeys.cancel.tr(),
                    style: GoogleFonts.robotoCondensed(color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
        }, icon: const Icon(Icons.add_circle, color: Colors.white, size: 20,))
      ],);
  }

  //TEAM NAME AND FUNCTION
  Widget teamRow(IconData icon,String name,VoidCallback function){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon,color: Colors.white,size: 20,),
            const SizedBox(
              width: 5,
            ),
            Text(name, style: GoogleFonts.robotoCondensed(textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, overflow: TextOverflow.ellipsis, color: Colors.white)),),
          ],
        ),
        IconButton(onPressed: function, icon: const Icon(Icons.add_circle, color: Colors.white, size: 20,))
      ],);
  }

  //TEAM DROPDOWN WIDGET
  Widget teamDropDown(){
    return DropdownButton<String>(
        value: dropdownValue,
        style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 19,
            overflow: TextOverflow.ellipsis),
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down,
            color: Colors.white),
        iconSize: 20,
        dropdownColor: Colors.grey,
        borderRadius: BorderRadius.circular(12),
        underline: Container(),
        items: teams.map<DropdownMenuItem<String>>((Team value) {
          return DropdownMenuItem<String>(
            value: value.name,
            child: Text(
              value.name,
              style: GoogleFonts.robotoCondensed(),
            ),
            onTap: () {
              setState(() {
                selectedTeamId = value.id;
              });
            },
          );
        }).toList(),
        onChanged: (String? newValue) async {
          setState(() {
            dropdownValue = newValue!;
          });
        });
  }

  //CUSTOM LIST TILE
  Widget bottomListTile(String name, IconData iconData, VoidCallback function){
    return ListTile(
      title: Text(name, style: GoogleFonts.robotoCondensed(textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, overflow: TextOverflow.ellipsis, color: Colors.white),)),
      leading: Icon(iconData, color: Colors.white),
      contentPadding: const EdgeInsets.all(0),
      minLeadingWidth: 5,
      onTap: function,
    );
  }





}
