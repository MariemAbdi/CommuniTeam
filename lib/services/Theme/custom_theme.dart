import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTheme{
  //static const  = Color(0xFF);
  static const  darkPurple= Color(0xFF611f69);
  static const  yellow= Color(0xFFecb22e);
  static const  green= Color(0xFF2eb67d);
  static const  blue= Color(0xFF36c5f0);
  static const  pink= Color(0xFFe01e5a);
  static const  white= Color(0xFFffffff);
  static const  black= Color(0xFF000000);
  static const purplelight = Color(0xFFCE93D8);

  static final lightTheme = ThemeData.light().copyWith(
    primaryColor: darkPurple,
    brightness: Brightness.light,

    appBarTheme: const AppBarTheme(
      elevation: 2.0,
      centerTitle: true,
      toolbarHeight: 50,
      color: darkPurple
    ),

    dividerTheme: const DividerThemeData(
      thickness: 1.0,
      color: Colors.white
    ),

    drawerTheme: const DrawerThemeData(
      elevation: 2.0,
      backgroundColor: darkPurple,

    ),

    inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.robotoCondensed(),
        labelStyle: GoogleFonts.robotoCondensed(color: darkPurple),
        errorStyle: GoogleFonts.robotoCondensed(),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: darkPurple),),
        errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: darkPurple),),
        iconColor: darkPurple,
        prefixStyle: const TextStyle(fontSize: 15)
    ),

  );

  static final darkTheme = ThemeData.dark().copyWith(
    primaryColorLight: Colors.grey.shade900,
    primaryColorDark: Colors.black26,

    appBarTheme: const AppBarTheme(
      elevation: 2.0,
      centerTitle: true,
      toolbarHeight: 50,
    ),

    indicatorColor: darkPurple,

    dividerTheme: const DividerThemeData(
        thickness: 1.0,
    ),

    drawerTheme: const DrawerThemeData(
      elevation: 6.0,
    ),

    inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.robotoCondensed(),
        labelStyle: GoogleFonts.robotoCondensed(color: white),
        errorStyle: GoogleFonts.robotoCondensed(),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey),),
        errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red),),
        iconColor: white,
        prefixStyle: const TextStyle(fontSize: 15)
    ),
  );
}