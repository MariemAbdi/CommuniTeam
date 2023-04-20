// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>> load(String fullPath, Locale locale ) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String,dynamic> ar = {
  "emailfieldcantbeempty": "لا يمكن أن يكون البريد الإلكتروني فارغًا",
  "pleaseenteravalidemail": "يرجى إدخال بريد الإلكتروني صحيح",
  "email": "بريد إلكتروني",
  "enteryouremail": "أدخل بريدك الإلكتروني",
  "passwordfieldcantbeempty": "لا يمكن أن تكون كلمة السرفارغة",
  "passwordmustbeatleast6characters": "يجب أن تتكون كلمة المرور من 6 أحرف على الأقل",
  "password": "كلمة السر",
  "enteryourpassword": "ادخل كلمة السر",
  "nicknamecantbeempty": "لا يمكن أن يكون الاسم المستعار فارغًا",
  "nickname": "اسم مستعار",
  "enteryournickname": "أدخل اسمك المستعار"
};
static const Map<String,dynamic> en = {
  "emailfieldcantbeempty": "Email Field Can't Be Empty",
  "pleaseenteravalidemail": "Please Enter A Valid Email",
  "email": "Email",
  "enteryouremail": "Enter Your Email",
  "passwordfieldcantbeempty": "Password Field Can't Be Empty",
  "passwordmustbeatleast6characters": "Password Must Be At Least 6 Characters",
  "password": "Password",
  "enteryourpassword": "Enter Your Password",
  "nicknamecantbeempty": "Username Field Can't Be Empty",
  "nickname": "Username",
  "enteryournickname": "Enter Your Username"
};
static const Map<String,dynamic> fr = {
  "emailfieldcantbeempty": "E-mail Ne Peut Pas Être Vide",
  "pleaseenteravalidemail": "Veuillez Saisir Un E-mail Valide",
  "email": "E-mail",
  "enteryouremail": "Entrer Votre E-mail",
  "passwordfieldcantbeempty": "Mot De Passe Ne Peut Pas Être Vide",
  "passwordmustbeatleast6characters": "Le Mot De Passe Doit Être Au Moins De 6 Caractères",
  "password": "Mot De Passe",
  "enteryourpassword": "Entrer Votre Mot De Passe",
  "nicknamecantbeempty": "Le Surnom Ne Peut Pas Être Vide",
  "nickname": "Surnom",
  "enteryournickname": "Entrer Votre Surnom"
};
static const Map<String, Map<String,dynamic>> mapLocales = {"ar": ar, "en": en, "fr": fr};
}
