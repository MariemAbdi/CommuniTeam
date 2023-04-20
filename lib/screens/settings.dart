import 'package:animate_icons/animate_icons.dart';
import 'package:communiteam/widgets/custom_appbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

import '../services/Theme/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  static String routeName = '/settings';
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AnimateIconController controller = AnimateIconController();
  String dropdownValue="English";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(title: "Settings",),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                themeSwitch(),
                languageDropDown(),
              ],
            ),
          ),

        ),
      ),
    );
  }

  Widget themeSwitch(){
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          const Text("Theme Mode", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),),

          //CHANGE THE APP'S THEME ICON
          AnimateIcons(
            startIcon: EvaIcons.moon,
            endIcon: EvaIcons.sun,
            size: 30.0,
            controller: controller,
            // add this tooltip for the start icon
            startTooltip: 'Icons.add_circle',
            // add this tooltip for the end icon
            endTooltip: 'Icons.add_circle_outline',
            onStartIconPress: () {
              ThemeService().switchTheme();
              return true;
            },
            onEndIconPress: () {
              ThemeService().switchTheme();
              return true;
            },
            duration: const Duration(milliseconds: 1000),
            startIconColor: Colors.white,
            endIconColor: Colors.yellow,
            clockwise: true,
          ),
        ],

      ),
    );
  }

  Widget languageDropDown(){
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

        const Text("Language", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),),

        DropdownButton<String>(
        value: dropdownValue,
            icon: const Icon(Icons.keyboard_arrow_down),
            borderRadius: BorderRadius.circular(12),
            underline: Container(),
            items: <String>['English', 'Français', 'العربية']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  //style: GoogleFonts.ptSans(),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) async {
              setState(() {
                dropdownValue = newValue!;
                //language.write("language", newValue);
              });

              if (dropdownValue.compareTo("English") == 0) {
                await context.setLocale(const Locale('en')); // change `easy_localization` locale
                await Get.updateLocale(const Locale('en')); // change `Get` locale direction

                setState((){});
              } else if (dropdownValue.compareTo("Français") == 0) {
                await context.setLocale(const Locale('fr')); // change `easy_localization` locale
                await Get.updateLocale(const Locale('fr')); // change `Get` locale direction

                setState((){});
              } else {
                await context.setLocale(const Locale('ar')); // change `easy_localization` locale
                await Get.updateLocale(const Locale('ar')); // change `Get` locale direction

                setState((){});
              }
            })
        ],
      ),
    );
  }
}
