import 'package:communiteam/widgets/drawer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../resources/firestore_methods.dart';
import '../translations/locale_keys.g.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/email_field.dart';



class AddNewTeamScreen extends StatefulWidget {
  static String routeName = '/add_new_team';
  const AddNewTeamScreen({Key? key}) : super(key: key);

  @override
  State<AddNewTeamScreen> createState() => _AddNewTeamScreenState();
}

class _AddNewTeamScreenState extends State<AddNewTeamScreen> {
  late User user;
  TextEditingController memberController = TextEditingController();
  TextEditingController teamController = TextEditingController();
  List<String> emailList = [];

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    emailList.add(user.email!);

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(title: "Add Team",),
      drawer: const DrawerWidget(),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery
              .of(context)
              .size
              .height,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Add team here
                        addTeam( teamController.text.trim(),emailList);
                      },
                      child: const Text('Add Team'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        addUser(emailList);
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
  }

  Widget _buildEmailList() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: emailList.length - 1 ,
      itemBuilder: (context, index)  {
        return ListTile(
          leading: Icon(Icons.email),
          title: Text(emailList[index+1]),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                emailList.removeAt(index+1);
              });
            },
          ),
        );
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
    );
  }

  addUser(List<String> emailList) {
    TextEditingController memberController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(

          title: Text("Add User ${teamController.text.trim()}"),

          content: EmailField(emailController: memberController),

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

                // Check if the email is valid and doesn't exist in the list
                if (isValidEmail(newEmail) &&
                    !isEmailExist(newEmail, emailList)) {
                  setState(() {
                    emailList.insert(1, newEmail);
                  });
                }
                memberController.clear();
                Navigator.of(context).pop();
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


  addTeam(String teamName,emails){
    if (teamName.isNotEmpty) {
      FirestoreMethods firestoreMethods = FirestoreMethods();
      firestoreMethods.addTeam(context,teamName,user.email!).then((teamId) {
        for (var email in emails) {
          firestoreMethods.addMemberToTeam(teamId, email);
        }

        //emailList.clear();

        setState(() {
          teamController.clear();
          emailList=[user.email!];
        });

      });

    }
  }



}