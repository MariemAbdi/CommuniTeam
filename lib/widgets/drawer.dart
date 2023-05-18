import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communiteam/screens/profile.dart';
import 'package:communiteam/services/Theme/custom_theme.dart';
import 'package:communiteam/services/firebase_storage_services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/team.dart';
import '../providers/firebase_auth_methods.dart';
import '../resources/firestore_methods.dart';
import '../screens/canal_chat.dart';
import '../screens/homepage.dart';
import '../translations/locale_keys.g.dart';
import '../utils.dart';
import 'drawer_item_canal.dart';
import 'drawer_item_direct.dart';


class DrawerWidget extends StatefulWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {

  GetStorage getStorage = GetStorage();
  final user = FirebaseAuth.instance.currentUser!;
  String dropdownValue ="General Team";
  List<Team> teams = [];
  Storage storage = Storage();

  TextEditingController memberController = TextEditingController();
  TextEditingController teamController = TextEditingController();
  List<String> emailList = [];
  late int randomId=3;


  late String selectedTeamId = "toBCHluEdzfmeoXhCxQw";

  bool publicCanals=false;
  bool privateCanals=false;
  bool directMessages=false;
  bool isMember= false;

  List<bool> usersStatus = [];
  List<dynamic> usersOutOfTeam = [];

  //GET ALL THE TEAMS THAT THE CURRENT USER IS A MEMBER IN
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
            defaultCanal: value['defaultCanal'],
            members: value['members'].cast<String>());
          list.add(team);
      }
      setState(() {
        teams = list;
      });

    });
  }

  bool isGeneralCanal(List<Team> teams,String teamId,String canalId){
    bool result = false;
    int i=0;
    while(!result && i<teams.length){
      Team currentTeam = teams[i];
      result = ( (currentTeam.id ==teamId) && (currentTeam.defaultCanal==canalId) ) ;
        i++;
    }
    return result;
  }

  @override
  void initState() {
    super.initState();

    //FILL THE LIST OF TEAMS
    getTeams();

    //GET THE LAST VISITED TEAM ID
    if(getStorage.read("selectedTeamId")!=null){
      setState(() {
        selectedTeamId=getStorage.read("selectedTeamId");
      });
    }
    //GET THE LAST VISITED TEAM NAME
    if(getStorage.read("selectedTeamName")!=null){
      setState(() {
        dropdownValue=getStorage.read("selectedTeamName");
      });
    }
    //-------------SETTING IF THE CANALS/USERS LIST ARE SHOWING OR HIDDEN------------------
    if(getStorage.read("publicCanals")!=null){
      setState(() {
        publicCanals=getStorage.read("publicCanals");
      });
    }
    if(getStorage.read("privateCanals")!=null){
      setState(() {
        privateCanals=getStorage.read("privateCanals");
      });
    }
    if(getStorage.read("directMessages")!=null){
      setState(() {
        directMessages=getStorage.read("directMessages");
      });
    }

    //USED TO RANDOMLY SELECT AN AVATAR IF USER DOESN'T HAVE A PROFILE PICTURE
    setState(() {
      randomId=Random().nextInt(5);
    });


    //get users of team General Team
    getUsers("toBCHluEdzfmeoXhCxQw");
    emailList.add(user.email!);

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
                          addTeamDialog();
                      }),

                    teamDropDown(),

                    const Divider(),
                    //---------------------------PUBLIC CANALS---------------------------------------
                    canalRow(Icons.public,LocaleKeys.publicCanals.tr(),publicCanals, (){
                      setState(() {
                        publicCanals=!publicCanals;
                        getStorage.write("publicCanals", publicCanals);
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
                                      return DrawerItemCanal(canalId:canals[index]["id"], canalName: canals[index]['name'], isOwner: user.email == canals[index]['owner'], collectionName: 'publicCanals', teamId: selectedTeamId,
                                      isGeneral: isGeneralCanal(teams,selectedTeamId, canals[index]["id"]) );
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
                        getStorage.write("privateCanals", privateCanals);
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
                                          child: DrawerItemCanal(canalId: canals[index]['id'], canalName: canals[index]['name'], isOwner: user.email! == canals[index]["members"][0], collectionName: "privateCanals", teamId: selectedTeamId,
                                          isGeneral: false));

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
                        getStorage.write("directMessages", directMessages);
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
                            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ProfileScreen(isMe: true, userId: user.email!)));
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
                                content: Text(LocaleKeys.areYouSureYouWantToLogout.tr()),
                                actions: [
                                  TextButton(
                                    child: Text(
                                      LocaleKeys.yes.tr(),
                                      style: GoogleFonts
                                          .robotoCondensed(),
                                    ),
                                    onPressed: () {
                                      getStorage.erase();
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
                  onPressed: () async {
                    if (canalName.isNotEmpty) {
                      FirestoreMethods firestoreMethods = FirestoreMethods();
                      firestoreMethods.addCanal(context, selectedTeamId, canalName, isPrivate, user.email!);
                      // Navigator.pop(context);
                      //
                      // await getTeams();
                      Navigator.pop(context);
                      Navigator.of(context).pop();
                    }
                   /* Navigator.pop(context);
                    Navigator.of(context).pop();*/
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
  Widget teamDropDown() {
    return DropdownButton<String>(
      value: dropdownValue,
      style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 19,
          overflow: TextOverflow.ellipsis),
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
      iconSize: 20,
      dropdownColor: Colors.grey,
      borderRadius: BorderRadius.circular(12),
      underline: Container(),
      items: teams.map<DropdownMenuItem<String>>((Team value) {
        return DropdownMenuItem<String>(
          value: value.name,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value.name,
                  style: GoogleFonts.robotoCondensed(),
                  maxLines: 1,
                ),
              ),
              if ((value.id != "toBCHluEdzfmeoXhCxQw") &&
                  (value.members[0] == user.email!))
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      constraints: BoxConstraints.tight(const Size.fromWidth(30)),
                      padding: const EdgeInsets.all(0),
                      onPressed: () {
                        addingTeammate(value.id);
                      },
                      icon: const Icon(
                        Icons.person_add,
                        color: CustomTheme.white,
                        size: 20,
                      ),
                    ),
                    IconButton(
                      constraints: BoxConstraints.tight(const Size.fromWidth(30)),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        deleteTeam(value.id, value.name);
                      },
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          onTap: () {
            setState(() {
              selectedTeamId = value.id;
              getStorage.write("selectedTeamId", selectedTeamId);
            });
          },
        );
      }).toList(),
      onChanged: (String? newValue) async {
        setState(() {
          dropdownValue = newValue!;
          getStorage.write("selectedTeamName", dropdownValue);
        });
      },
    );
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

  //ALERT DIALOG TO ADD A NEW TEAM
  addTeamDialog(){
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.start,
            title: Text(
              LocaleKeys.addNewTeam.tr(),
              style: GoogleFonts.robotoCondensed(),
            ),
            content: TextFormField(
              validator: (name) {
                if (name!.isEmpty) {
                  return LocaleKeys.teamNameCantBeEmpty.tr();
                }
                return null;
              },
              controller: teamController,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                  labelText: LocaleKeys.teamName.tr(),
                  hintText: LocaleKeys.teamName.tr(),
                  prefixIcon: const Icon(CupertinoIcons.group_solid),
                  border: const OutlineInputBorder(),
                  suffixIcon: teamController.text.isEmpty
                      ? null
                      : IconButton(
                    icon: const Icon(EvaIcons.close),
                    onPressed: () {
                      setState(() {
                        teamController.clear();
                      });
                    },
                  )),
              onChanged: (value) {
                setState(() {});
              },

            ),
            actions: [
              TextButton(
                child: Text(
                  LocaleKeys.add.tr(),
                  style: GoogleFonts.robotoCondensed(),
                ),
                onPressed: () {
                  FirestoreMethods firestoreMethods = FirestoreMethods();
                  firestoreMethods.addTeam(context,teamController.text.trim(),user.email!);

                  customSnackBar(context, LocaleKeys.teamAddedSuccessully.tr(), Colors.green);
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
  }

  //ALERT DIALOG TO DELETE A TEAM
  deleteTeam(teamId,teamName){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(

          title: Text(LocaleKeys.areYouSureYouWantToDeleteTeam.tr()),

          actions: [
            TextButton(
              child: Text(LocaleKeys.cancel.tr()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),

            TextButton(
              child: Text(LocaleKeys.yes.tr()),
              onPressed: ()  {
                FirestoreMethods firestoreMethods = FirestoreMethods();
                firestoreMethods.deleteTeam(context,teamId);
                //si le team supprimé est le team selectionné , on selectionne General Team
                if(selectedTeamId == teamId){
                  setState( () {
                    selectedTeamId = "toBCHluEdzfmeoXhCxQw";
                    getStorage.write("selectedTeamId", selectedTeamId);
                    dropdownValue = "General Team";
                    getStorage.write("selectedTeamName", dropdownValue);
                  });

                  Navigator.of(context).pop(); // Fermer la boîte de dialogue
                  Navigator.pop(context);// Mettre à jour l'état pour fermer la liste déroulante

                  //GOING TO THE DEFAULT TEAM'S SCREEN
                  Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const HomePage(isCanal: true, title: "General Team" ,widget: CanalChatScreen( teamId: "toBCHluEdzfmeoXhCxQw", canalType: "publicCanals" , canalId: "lTfMN0DfWD4SvUvmfgHZ", nickName: "General", ))
                  ));
                }

                customSnackBar(context, LocaleKeys.teamDeletedSuccessfully.tr(), Colors.red);

                Navigator.of(context).pop(); // Fermer la boîte de dialogue
                Navigator.pop(context);// Mettre à jour l'état pour fermer la liste déroulante
              },
            ),

          ],
        );
      },
    );
  }

  //AVATAR WIDGET
  Future<Widget> buildProfileAvatar(String userId) async {
    final storage = FirebaseStorage.instance;
    final ref = storage.ref("profile pictures/$userId");

    // Récupérer l'URL de téléchargement de la photo de profil de l'utilisateur
    final url = await ref.getDownloadURL();

    return CircleAvatar(
      backgroundImage: NetworkImage(url),
      radius: 20,
    );
  }

  //ALERT DIALOG TO ADD A NEW TEAM MEMBER
  Future<void> addingTeammate(String teamID) async {
    await getUsers(teamID);
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.start,
            title: Text(
              LocaleKeys.addTeamMember.tr(),
              style: GoogleFonts.robotoCondensed(),
            ),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: usersOutOfTeam.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: FutureBuilder<Widget>(
                          future: buildProfileAvatar(
                              usersOutOfTeam[index]["email"]),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return snapshot.data!;
                            } else {
                              return CircleAvatar(
                                backgroundImage:
                                AssetImage("assets/images/avatar$randomId.png"),
                              );
                            }
                          },
                        ),
                        title: Text(
                          usersOutOfTeam[index]["nickname"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          usersOutOfTeam[index]["email"],
                        ),
                        trailing: Checkbox(
                          value: usersStatus[index],
                          onChanged: (bool? value) {
                            setState(() {
                              usersStatus[index] = value ?? false;
                            });
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                child: Text(
                  LocaleKeys.add.tr(),
                  style: GoogleFonts.robotoCondensed(),
                ),
                onPressed: () {
                  addSelectedUsersToTeam(teamID);

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

  }


  void addSelectedUsersToTeam(String teamID) {
    List<String> selectedUserIds = [];
    // Loop through usersStatus and add selected user ids to selectedUserIds
    for (int i = 0; i < usersStatus.length; i++) {
      if (usersStatus[i]) {
        selectedUserIds.add(usersOutOfTeam[i]["email"]);
      }
    }
    if (selectedUserIds.isEmpty) {
      customSnackBar(context, LocaleKeys.noUserSelected.tr(), Colors.red);
    } else {
      // Add selected users to team
      FirebaseFirestore.instance
          .collection("teams")
          .doc(teamID)
          .update({"members": FieldValue.arrayUnion(selectedUserIds)}).then(
              (value) {
            // Clear selectedUserIds and usersStatus
            selectedUserIds.clear();

            customSnackBar(context, LocaleKeys.memberAddedSuccessfully, Colors.green);

            //refrech list users
            getUsers(teamID);
          }).catchError((onError) {
            customSnackBar(context, LocaleKeys.failedToAddUser.tr(), Colors.red);
      });
    }
  }

  getUsers(String teamId) async {
    usersStatus = [];
    usersOutOfTeam = [];
    List<String> allUsersIds = [];

    var userDocs = await FirebaseFirestore.instance.collection("users").get();
    for (var doc in userDocs.docs) {
      // do something with the doc here
      allUsersIds.add(doc.id);
    }

    await FirebaseFirestore.instance
        .collection("teams")
        .doc(teamId)
        .get()
        .then((value) async {

      // get users Ids
      List<String> teamUsersIds = List.from(value.data()!["members"]);

      // loop through all ids and get associated user object by userID/followerID
      for (int i = 0; i < allUsersIds.length; i++) {
        var userId = allUsersIds[i];
        if (!teamUsersIds.contains(userId)) {
          var data = await FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .get();
          usersOutOfTeam.add(data);
          usersStatus.add(false);
        }
      }
      setState(() {});
    });
  }
}
