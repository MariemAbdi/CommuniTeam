import 'package:communiteam/resources/firestore_methods.dart';
import 'package:communiteam/services/Theme/custom_theme.dart';
import 'package:communiteam/widgets/drawer_item.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_auth_methods.dart';
import '../translations/locale_keys.g.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {

  final user = FirebaseAuth.instance.currentUser!;
  List<String> teams=[];

  String dropdownValue = "Group2";

  bool publicCanals=false;
  bool privateCanals=false;
  bool directMessages=false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: LayoutBuilder(
        builder: (context, constraint) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraint.maxHeight * 0.95),
              child: IntrinsicHeight(
                child: Column(
                  children: <Widget>[

                    //PROFILE PICTURE
                    Container(
                      width: MediaQuery.of(context).size.width*0.3,
                      height: MediaQuery.of(context).size.width*0.3,
                      decoration: const BoxDecoration(
                        color: CustomTheme.green,
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage("assets/images/placeholder.png"),
                        ))),

                    const SizedBox(height: 10,),

                    //THE USER'S USERNAME
                    Text(user.displayName!,style: GoogleFonts.robotoCondensed(textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white, overflow: TextOverflow.ellipsis),)),

                    //SOME SPACE
                    const SizedBox(height: 10,),

                    //---------------------------PUBLIC CHANNELS---------------------------------------

                    //TEAM DROPDOWN
                    teamWidget(),

                    //---------------------------PUBLIC CHANNELS---------------------------------------
                    channelAddition(LocaleKeys.publicCanals.tr(),publicCanals, (){
                      setState(() {
                        publicCanals=!publicCanals;
                      });
                    },false),

                    Visibility(
                      visible: publicCanals,
                      child: SizedBox(height: MediaQuery.of(context).size.height*0.2,
                      child: ListView.builder(
                          itemCount: 3,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemBuilder: (BuildContext context, int index){
                            return const DrawerItem(name: "name");
                          }),
                      ),
                    ),

                    //HORIZONTAL LINE
                    const Divider(),

                    //---------------------------PRIVATE CHANNELS---------------------------------------
                    channelAddition(LocaleKeys.privateCanals.tr(), privateCanals,(){
                    setState(() {
                    privateCanals=!privateCanals;
                    });
                    },true),

                    Visibility(
                      visible: privateCanals,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height*0.2,
                        child: ListView.builder(
                            itemCount: 2,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemBuilder: (BuildContext context, int index){
                              return const DrawerItem(name: "name");
                            }),
                      ),
                    ),

                    //HORIZONTAL LINE
                    const Divider(),

                    //---------------------------DIRECT MESSAGES---------------------------------------
                    channelAddition(LocaleKeys.directMessages.tr(),directMessages,() {
                    setState(() {
                    directMessages=!directMessages;
                    });
                    },true),

                    Visibility(
                      visible: directMessages,
                      child: SizedBox(height: MediaQuery.of(context).size.height*0.2,
                        child: ListView.builder(
                            itemCount: 3,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemBuilder: (BuildContext context, int index){
                              return const DrawerItem(name: "name");
                            }),),
                    ),

                    //SOME SPACE
                    const Expanded(child: SizedBox()),

                    //PROFILE AND SETTINGS BUTTONS
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

                                      // Navigator.of(context).push(MaterialPageRoute(
                                      //     builder: (context) => const ProfileScreen()));
                                    }),

                                    //GO TO SETTINGS
                                    bottomListTile(LocaleKeys.settings.tr(), Icons.settings, () {
                                      // Navigator.pop(context);
                                      // Navigator.of(context).push(MaterialPageRoute(
                                      //     builder: (context) => const SettingsScreen()));
                                      Navigator.pop(context);
                                      Navigator.of(context).pushReplacementNamed('/settings');
                                    }),

                                    const Divider(),

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
                                  // FirebaseAuth.instance.signOut();
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

  //CHANNEL NAME AND FUNCTION
  Widget channelAddition(String name,bool visibility, VoidCallback showHide,bool isPrivate){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: showHide,
          child: Row(children: [
            Text(name, style: GoogleFonts.robotoCondensed(textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, overflow: TextOverflow.ellipsis, color: Colors.white)),),
            Icon(visibility?Icons.keyboard_arrow_up:Icons.keyboard_arrow_down, color: Colors.white,),
          ],),
        ),
        IconButton(onPressed: (){
          showCupertinoModalPopup(context: context, builder: (BuildContext context){
            return createCanal(isPrivate);
          });

        }, icon: const Icon(Icons.add_circle, color: Colors.white))
      ],);
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

  //TEAM GROUP DROPDOWN
  Widget teamWidget(){
    return DropdownButton<String>(
        value: dropdownValue,
        style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w700, fontSize: 19, overflow: TextOverflow.ellipsis),
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        dropdownColor: Colors.grey,
        borderRadius: BorderRadius.circular(12),
        underline: Container(),
        items: <String>['Group1', 'Group2', 'Group3','Add New Team +']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: GoogleFonts.robotoCondensed(),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) async {
          setState(() {
            dropdownValue = newValue!;
          });

        });
  }

  //CANAL CREATION
  createCanal(bool isPrivate){
    String channelName="";
    return AlertDialog(
      actionsAlignment:
      MainAxisAlignment.start,
      title: Text(
        LocaleKeys.createNewCanal.tr(),
        style:
        GoogleFonts.robotoCondensed(),
      ),
      content: TextFormField(
        decoration: InputDecoration(
          hintText: LocaleKeys.canalName.tr()
        ),
        onChanged: (name) {
          channelName = name;
        },
      ),
      actions: [
        TextButton(
          child: Text(
            LocaleKeys.add.tr(),
            style: GoogleFonts
                .robotoCondensed(),
          ),
          onPressed: () {
            if(channelName.isNotEmpty){
              FirestoreMethods firestoreMethods= FirestoreMethods();
              firestoreMethods.addCanal("toBCHluEdzfmeoXhCxQw", channelName, isPrivate,user.email!);

              //customSnackBar(context, "Canal Created Successfully!", Colors.green);
            }
            Navigator.of(context)
                .pop();
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
  }
}
