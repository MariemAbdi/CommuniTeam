import 'package:communiteam/widgets/adding_appbar.dart';
import 'package:communiteam/widgets/chat_item.dart';
import 'package:communiteam/widgets/custom_appbar.dart';
import 'package:communiteam/widgets/drawer.dart';
import 'package:flutter/material.dart';

import '../resources/firestore_methods.dart';

class HomePage extends StatefulWidget {
  static String routeName = '/home';
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  FirestoreMethods firestoreMethods= FirestoreMethods();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: const AddingAppbar(title: "Channel Name",),
        drawer: const DrawerWidget(),
        body: Container(),
      ),
    );
  }
}
