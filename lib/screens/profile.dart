import 'package:communiteam/translations/locale_keys.g.dart';
import 'package:communiteam/widgets/custom_button.dart';
import 'package:communiteam/widgets/drawer.dart';
import 'package:communiteam/widgets/profile_picture.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/custom_appbar.dart';

class ProfileScreen extends StatefulWidget {
  static String routeName = '/profile';
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(title: "Profile",),
      drawer: const DrawerWidget(),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,

          child: Padding(

            padding: const EdgeInsets.all(20),

            child: Column(

              children: [

                ProfilePicture(userId: user.email!,),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
