import 'package:communiteam/translations/locale_keys.g.dart';
import 'package:communiteam/widgets/profile_picture.dart';
import 'package:communiteam/widgets/drawer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_appbar.dart';

class ProfileScreen extends StatefulWidget {
  static String routeName = '/profile';
  final bool isMe;
  final String? userId;
  const ProfileScreen({Key? key, required this.isMe, required this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: LocaleKeys.profile.tr(),),
      drawer: const DrawerWidget(),
      body: SingleChildScrollView(
        child: Padding(

          padding: const EdgeInsets.all(20),

          child: Column(

            children: [

              ProfilePicture(userId: widget.userId!, isMe: widget.isMe,),

            ],
          ),
        ),
      ),
    );
  }
}
