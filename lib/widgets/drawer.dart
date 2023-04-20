import 'package:communiteam/screens/settings.dart';
import 'package:communiteam/services/Theme/custom_theme.dart';
import 'package:communiteam/widgets/drawer_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {

  final user = FirebaseAuth.instance.currentUser!;

  String dropdownValue = "Group2";

  bool publicChannels=true;
  bool privateChannels=true;
  bool directMessages=true;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: LayoutBuilder(
        builder: (context, constraint) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraint.maxHeight),
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
                    Text(user.displayName!,style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white, overflow: TextOverflow.ellipsis),),

                    //SOME SPACE
                    const SizedBox(height: 10,),

                    //TEAM GROUP SELECTION
                    teamWidget(),

                    //---------------------------PUBLIC CHANNELS---------------------------------------
                    channelAddition("Public Channels",publicChannels, (){
                      setState(() {
                        publicChannels=!publicChannels;
                      });
                    },(){}),

                    Visibility(
                      visible: publicChannels,
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

                    //HORIZONTAL LINE
                    const Divider(),

                    //---------------------------PRIVATE CHANNELS---------------------------------------
                    channelAddition("Private Channels", privateChannels,(){
                    setState(() {
                    privateChannels=!privateChannels;
                    });
                    },(){}),

                    Visibility(
                      visible: privateChannels,
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
                    channelAddition("Direct Messages",directMessages,() {
                    setState(() {
                    directMessages=!directMessages;
                    });
                    },(){}),

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
                                    bottomListTile("Profile", Icons.account_circle, () { }),

                                    //GO TO SETTINGS
                                    bottomListTile("Settings", Icons.settings, () {
                                      Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) => const SettingsScreen()));
                                    }),

                                    //HORIZONTAL LINE
                                    const Divider(),

                                    //LOGOUT BUTTON
                                    bottomListTile("LOGOUT", Icons.power_settings_new, () {
                                      FirebaseAuth.instance.signOut();
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
  Widget channelAddition(String name,bool visibility, VoidCallback showHide,VoidCallback add){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: showHide,
          child: Row(children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, overflow: TextOverflow.ellipsis, color: Colors.white),),
            Icon(visibility?Icons.keyboard_arrow_up:Icons.keyboard_arrow_down, color: Colors.white,),
          ],),
        ),
        IconButton(onPressed: add, icon: const Icon(Icons.add_circle, color: Colors.white))
      ],);
  }

  //CUSTOM LIST TILE
  Widget bottomListTile(String name, IconData iconData, VoidCallback function){
    return ListTile(
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, overflow: TextOverflow.ellipsis, color: Colors.white),),
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
        style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w700, fontSize: 20, overflow: TextOverflow.ellipsis),
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        dropdownColor: Colors.grey,
        borderRadius: BorderRadius.circular(12),
        underline: Container(),
        items: <String>['Group1', 'Group2', 'Group3']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
            ),
          );
        }).toList(),
        onChanged: (String? newValue) async {
          setState(() {
            dropdownValue = newValue!;
          });

        });
  }
}
