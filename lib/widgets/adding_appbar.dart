import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class AddingAppbar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  const AddingAppbar({Key? key, required this.title}) : super(key: key);

  @override
  State<AddingAppbar> createState() => _AddingAppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

class _AddingAppbarState extends State<AddingAppbar> {


  List<dynamic> allUsers =[];

  getUsers() async {
    await FirebaseFirestore.instance
        .collection("teams")
        .doc("toBCHluEdzfmeoXhCxQw")
        .get()
        .then((value) async {
      // get users Ids
      List<String> followersIds = List.from(value.data()!["members"]);

      // loop through all ids and get associated user object by userID/followerID
      for (int i = 0; i < followersIds.length; i++) {
        var userId = followersIds[i];
        var data = await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .get();

        allUsers.add(data);
      }
      setState(() {
      });
    });
  }
  @override
  void initState() {
    super.initState();
    getUsers();
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
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: allUsers.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: FutureBuilder<Widget>(
                      future: buildProfileAvatar(allUsers[index]["email"]),
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
                      allUsers[index]["nickname"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      allUsers[index]["email"],
                    ),
                    trailing: Checkbox(
                      value: false,
                      onChanged: (bool? value) {},
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                child: Text(
                  "Add",
                  style: GoogleFonts.robotoCondensed(),
                ),
                onPressed: () {
                  // FirebaseAuth.instance.signOut();
                  //  context.read<FirebaseAuthMethods>().signOut(context);
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

  @override
  Widget build(BuildContext context) {
    return AppBar(
      //automaticallyImplyLeading: false,
      title: Text(widget.title),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: addingTeammate,
        ),
      ],
    );
  }
}
