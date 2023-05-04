import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class AddingAppbar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String itemId;


  const AddingAppbar({Key? key, required this.title,required this.itemId,}) : super(key: key);

  @override
  State<AddingAppbar> createState() => _AddingAppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

class _AddingAppbarState extends State<AddingAppbar> {
  List<bool> usersStatus = [];
  List<dynamic> usersOutOfTeam = [];

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
      List<String> itemUsersIds = List.from(value.data()!["members"]);

      // loop through all ids and get associated user object by userID/followerID
      for (int i = 0; i < allUsersIds.length; i++) {
        var userId = allUsersIds[i];
        if (!itemUsersIds.contains(userId)) {
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

  @override
  void initState() {
    super.initState();
    getUsers("toBCHluEdzfmeoXhCxQw");
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
                  addSelectedUsersToTeam();

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

  void addSelectedUsersToTeam() {
    List<String> selectedUserIds = [];
    // Loop through usersStatus and add selected user ids to selectedUserIds
    for (int i = 0; i < usersStatus.length; i++) {
      if (usersStatus[i]) {
        selectedUserIds.add(usersOutOfTeam[i]["email"]);
      }
    }
    if (selectedUserIds.length == 0) {
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
          .doc("toBCHluEdzfmeoXhCxQw")
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
            getUsers("toBCHluEdzfmeoXhCxQw");
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

  @override
  Widget build(BuildContext context) {
    return AppBar(
      //automaticallyImplyLeading: false,
      title: Text(widget.title),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {  },
          //onPressed: addingTeammate,
        ),
      ],
    );
  }
}
