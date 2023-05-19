import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communiteam/translations/locale_keys.g.dart';
import 'package:communiteam/utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class AddingAppbar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String canalId;
  final String teamId;
  final String collectionName;


  const AddingAppbar({Key? key, required this.title,required this.teamId,required this.collectionName,required this.canalId,}) : super(key: key);

  @override
  State<AddingAppbar> createState() => _AddingAppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

class _AddingAppbarState extends State<AddingAppbar> {

  late User currentUser;

  List<bool> usersStatus = [];
  List<dynamic> usersOfCanal = [];
  List<dynamic> usersOutOfCanal = [];
  List<dynamic> usersOfTeam = [];

  getCanalUsers(String teamId,String canalId) async {
    usersStatus = [];
    usersOfCanal = [];
    usersOutOfCanal = [];
    usersOfTeam = [];

    List<String> allUsersIds = [];

    await FirebaseFirestore.instance
        .collection("teams")
        .doc(teamId)
        .get()
        .then((value) async {
       allUsersIds = List.from(value.data()!["members"]);

       for (int i = 0; i < allUsersIds.length; i++) {
         var userId = allUsersIds[i];

         var data = await FirebaseFirestore.instance
             .collection("users")
             .doc(userId)
             .get();
         usersOfTeam.add(data);
       }

      setState(() {});
    });


    await FirebaseFirestore.instance
        .collection("teams")
        .doc(teamId)
        .collection("privateCanals")
        .doc(canalId)
        .get()
        .then((value) async {

      List<String> itemUsersIds = List.from(value.data()!["members"]);

      for (int i = 0; i < itemUsersIds.length; i++) {
        var userId = itemUsersIds[i];
          var data = await FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .get();
          usersOfCanal.add(data);
      }

      for (int i = 0; i < allUsersIds.length; i++) {
        var userId = allUsersIds[i];

        if (!itemUsersIds.contains(userId)) {
          var data = await FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .get();
          usersOutOfCanal.add(data);
          usersStatus.add(false);
        }
      }
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser!;
    getCanalUsers(widget.teamId,widget.canalId);
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

  void addingTeammate() {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.start,
            title: Text(
              "Add member to this Canal",
              style: GoogleFonts.robotoCondensed(),
            ),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: usersOutOfCanal.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: FutureBuilder<Widget>(
                          future: buildProfileAvatar(
                              usersOutOfCanal[index]["email"]),
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
                          usersOutOfCanal[index]["nickname"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          usersOutOfCanal[index]["email"],
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
                  addSelectedUsersToCanal();

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

  void addSelectedUsersToCanal() {
    List<String> selectedUserIds = [];
    // Loop through usersStatus and add selected user ids to selectedUserIds
    for (int i = 0; i < usersStatus.length; i++) {
      if (usersStatus[i]) {
        selectedUserIds.add(usersOutOfCanal[i]["email"]);
      }
    }
    if (selectedUserIds.isEmpty) {
      customSnackBar(context, LocaleKeys.noUserSelected.tr(), Colors.red);
    } else {
      // Add selected users to team
      FirebaseFirestore.instance
          .collection("teams")
          .doc(widget.teamId)
          .collection(widget.collectionName)
          .doc(widget.canalId)
          .update({"members": FieldValue.arrayUnion(selectedUserIds)}).then(
              (value) {
            // Clear selectedUserIds and usersStatus
            selectedUserIds.clear();

            customSnackBar(context, LocaleKeys.memberAddedSuccessfully, Colors.green);
            //refrech list users
            getCanalUsers(widget.teamId,widget.canalId);
          }).catchError((onError) {
            customSnackBar(context, LocaleKeys.failedToAddUser, Colors.red);
      });
    }
  }




  void displayMembers(){
    List<dynamic> users = widget.collectionName=="publicCanals" ?
        usersOfTeam: usersOfCanal ;

    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {

          return AlertDialog(
            actionsAlignment: MainAxisAlignment.start,
            title: Text(
              "Canal's members",
              style: GoogleFonts.robotoCondensed(),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: FutureBuilder<Widget>(
                      future: buildProfileAvatar(users[index]["email"]),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return snapshot.data!;
                        } else {
                          return const CircleAvatar(

                            backgroundImage: AssetImage("assets/images/avatar3.png"),
                          );
                        }
                      },
                    ),
                    title: Text(
                      users[index]["nickname"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      users[index]["email"],
                    ),

                  );
                },
              ),
            ),
            actions: [

              ( users.length > 0 &&  users[0]["email"] == currentUser.email ) ?

              TextButton(
                child: Text(
                  LocaleKeys.add.tr(),
                  style: GoogleFonts.robotoCondensed(),
                ),
                onPressed: () {
                  Navigator.pop(context);
                 addingTeammate();

                },
              ):TextButton(
                child: Text("Ok",
                ),
                onPressed: () {
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

  @override
  Widget build(BuildContext context) {
    return AppBar(
      //automaticallyImplyLeading: false,
      title: Text(widget.title),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.people),
          onPressed: () {
            //addingTeammate();
            displayMembers();
          },
        ),
      ],
    );
  }
}
