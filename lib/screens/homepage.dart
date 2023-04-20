import 'package:communiteam/widgets/custom_appbar.dart';
import 'package:communiteam/widgets/drawer.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  static String routeName = '/home';
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(title: "Channel Name",),
      drawer: const DrawerWidget(),
      body: Container(),
    );
  }
}
