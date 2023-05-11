import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communiteam/services/Theme/custom_theme.dart';
import 'package:communiteam/services/firebase_storage_services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/team.dart';
import '../providers/firebase_auth_methods.dart';
import '../resources/firestore_methods.dart';
import '../translations/locale_keys.g.dart';
import 'drawer_item_canal.dart';
import 'drawer_item_direct.dart';
import 'email_field.dart';


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

  late String selectedTeamId = "toBCHluEdzfmeoXhCxQw";

  bool publicCanals=false;
  bool privateCanals=false;
  bool directMessages=false;
  bool isMember= false;

  List<bool> usersStatus = [];
  List<dynamic> usersOutOfTeam = [];

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

    getTeams();


    //GET THE LAST VISITED TEAM
    if(getStorage.read("selectedTeamId")!=null){
      setState(() {
        selectedTeamId=getStorage.read("selectedTeamId");
      });
    }
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
                            //Navigator.pop(context);
                           // Navigator.of(context).pushReplacementNamed('/add_new_team');
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
                                        //members.sort(true);
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
                  onPressed: () async {
                    if (canalName.isNotEmpty) {
                      FirestoreMethods firestoreMethods = FirestoreMethods();
                      firestoreMethods.addCanal(context, selectedTeamId, canalName, isPrivate, user.email!);
                    //  Navigator.pop(context);
                      await getTeams();
                      /*Navigator.pop(context);
                      Navigator.of(context).pop();*/
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        addingTeammate(value.id);
                      },
                      icon: const Icon(
                        Icons.add_road_sharp,
                        color: CustomTheme.white,
                        size: 20,
                      ),
                    ),
                    IconButton(
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

  void addSelectedUsersToTeam(String teamID) {
    List<String> selectedUserIds = [];
    // Loop through usersStatus and add selected user ids to selectedUserIds
    for (int i = 0; i < usersStatus.length; i++) {
      if (usersStatus[i]) {
        selectedUserIds.add(usersOutOfTeam[i]["email"]);
      }
    }
    if (selectedUserIds.isEmpty) {
      Fluttertoast.showToast(
        msg: "Any User Selected!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      // Add selected users to team
      FirebaseFirestore.instance
          .collection("teams")
          .doc(teamID)
          .update({"members": FieldValue.arrayUnion(selectedUserIds)}).then(
              (value) {
            // Clear selectedUserIds and usersStatus
            selectedUserIds.clear();

            Fluttertoast.showToast(
              msg: "User added successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            //refrech list users
            getUsers(teamID);
          }).catchError((onError) {
        Fluttertoast.showToast(
          msg: "Failed to Add Users, Try Again!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
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

  Future<void> addingTeammate(String teamID) async {
    await getUsers(teamID);
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.start,
            title: Text(
              "Add a teammate",
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
                              return const CircleAvatar(
                                backgroundImage:
                                AssetImage("assets/images/avatar3.png"),
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
                  "Add",
                  style: GoogleFonts.robotoCondensed(),
                ),
                onPressed: () {
                  addSelectedUsersToTeam(teamID);

                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(
                  "Cancel",
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

  addTeamDialog(){

    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            title: Text(
              "Add a new Team",
              style: GoogleFonts.robotoCondensed(),
            ),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SizedBox(
                  width: double.maxFinite,
                  child:SingleChildScrollView(
                    child: SizedBox(

                      height: MediaQuery.of(context).size.height * 0.4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const SizedBox(height: 8),
                            TextFormField(
                              validator: (name) {
                                if (name!.isEmpty) {
                                  return "Team's name can't be empty";
                                }
                                return null;
                              },
                              controller: teamController,
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                  labelText: "team Name",
                                  hintText: "Team Name",
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
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [

                                ElevatedButton.icon(
                                  onPressed: () {
                                    addUserToNewTeam();

                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('User'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: _buildEmailList(),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
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
                  addNewTeam( teamController.text.trim(),emailList);
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

  Widget _buildEmailList() {
    return Builder(
      builder: (BuildContext context) {
        return ListView.separated(
          shrinkWrap: true,
          itemCount: emailList.length - 1,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(Icons.email),
              title: Text(emailList[index + 1]),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    emailList.removeAt(index + 1);
                  });
                },
              ),
            );
          },
          separatorBuilder: (context, index) {
            return Divider();
          },
        );
      },
    );
  }


  addUserToNewTeam() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(

          title: Text("Add User ${teamController.text.trim()}"),

          content:StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return EmailField(emailController: memberController);

          }
          ),


          actions: [
            TextButton(
              child: Text(LocaleKeys.cancel.tr()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),

            TextButton(
              child: Text(LocaleKeys.add.tr()),
              onPressed: () {
                String newEmail = memberController.text.trim();
                if (isValidEmail(newEmail) &&
                    !isEmailExist(newEmail, emailList)) {
                  setState(() {
                    emailList.insert(1, newEmail);
                  });
                  Fluttertoast.showToast(
                    msg: "Email added to the list!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  memberController.clear();
                  Navigator.of(context).pop();
                }
                else{
                  if(!isValidEmail(newEmail)){
                    Fluttertoast.showToast(
                      msg: "Invalid Email!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                  else{
                    Fluttertoast.showToast(
                      msg: "Email already exist in the list!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                }

              },
            ),
          ],
        );
      },
    );
  }



  bool isValidEmail(String email) {
    RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  bool isEmailExist(String email, List<String> list) {
    return list.contains(email);
  }

  addNewTeam(String teamName,emails){
    if (teamName.isNotEmpty) {
      FirestoreMethods firestoreMethods = FirestoreMethods();
      firestoreMethods.addTeam(context,teamName,user.email!).then((teamId) async {
        for (var email in emails) {
           firestoreMethods.addMemberToTeam(teamId, email);
        }
        //emailList.clear();
        setState(() {
          teamController.clear();
          emailList=[user.email!];
        });
        Fluttertoast.showToast(
          msg: "Team added successefull!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        //
        Navigator.of(context).pop();
        await getTeams();
      });
    }
    else{

      Fluttertoast.showToast(
        msg: "Team's name can't be empty!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );

    }


  }
  deleteTeam(teamId,teamName){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(

          title: Text("Are you sure to delete '$teamName' ?"),

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
                //getTeams();
                //si le team supprimé est le team selectionné , on selectionne General Team
                if(selectedTeamId == teamId){
                  setState( () {
                    selectedTeamId = "toBCHluEdzfmeoXhCxQw";
                    getStorage.write("selectedTeamId", selectedTeamId);
                    dropdownValue = "General Team";
                    getStorage.write("selectedTeamName", dropdownValue);
                  });
                }



                Navigator.of(context).pop(); // Fermer la boîte de dialogue
                setState(() {});
                Navigator.pop(context);// Mettre à jour l'état pour fermer la liste déroulante
              },
            ),

          ],
        );
      },
    );
  }
}
