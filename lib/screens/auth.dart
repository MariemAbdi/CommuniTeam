import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:communiteam/screens/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import 'canal_chat.dart';
import 'direct_chat.dart';
import 'homepage.dart';

class Auth extends StatelessWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          //USER IS LOGGED IN
          if(snapshot.hasData){
            //ALWAYS OPENS TO THE DEFAULT TEAM'S GENERAL CANAL
            return const HomePage(isCanal: true, title: "General Team" ,teamId: 'toBCHluEdzfmeoXhCxQw',canalId: 'lTfMN0DfWD4SvUvmfgHZ',
                collectionName: 'publicCanals',
                widget: CanalChatScreen( teamId: "toBCHluEdzfmeoXhCxQw", canalType: "publicCanals" , canalId: "lTfMN0DfWD4SvUvmfgHZ", nickName: "General", ));
          }else{
            return const LoginScreen();
          }
        },
      ),
    );
  }
}