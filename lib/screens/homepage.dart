import 'package:communiteam/widgets/adding_appbar.dart';
import 'package:communiteam/widgets/drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../resources/firestore_methods.dart';
import '../widgets/custom_appbar.dart';

class HomePage extends StatefulWidget {
  static String routeName = '/home';

  final Widget widget;
  final String title;
  final bool isCanal;
  const HomePage({Key? key,required this.isCanal, required this.title, required this.widget, }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  FirestoreMethods firestoreMethods= FirestoreMethods();

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget addingAppBar = AddingAppbar(title: widget.title, itemId: '',);
    PreferredSizeWidget customAppBar = CustomAppbar(title: widget.title,);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: widget.isCanal?  addingAppBar: customAppBar,
        drawer: const DrawerWidget(),
        body:widget.widget,
      ),
    );
  }
}
